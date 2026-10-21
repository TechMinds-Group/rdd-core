#!/usr/bin/env bash
# run-evals.sh — Golden Set Runner (Linux / macOS / Git-Bash)
# Espelho do run-evals.ps1: executa os checks dos criteria.yaml em
# baseline-mode (output-expected) ou contra um modulo (--module <path>).
#
# Uso:
#   ./run-evals.sh                             # todas as fixtures
#   ./run-evals.sh --all                       # idem
#   ./run-evals.sh --skill rdd-data-model      # uma skill
#   ./run-evals.sh --fixture rdd-data-model/fixture-001
#   ./run-evals.sh --changed                   # so skills alteradas no git
#   ./run-evals.sh --module /caminho/modulo    # valida outputs de um modulo real
#   ./run-evals.sh --neutrality                # gate de neutralidade (open core)
#
# Exit codes: 0 = sem FAIL de severity error | 1 = ha FAIL error | 2 = erro de uso
#
# NOTA MSYS/GIT-BASH: NUNCA capturar funcao custom com $() dentro de loop
# (deadlock de pipe). Todas as funcoes custom escrevem em variaveis globais
# (RD_OUT, GI_OUT, PARAM_VAL, PL_OUT, NM_OUT). Apenas pipelines de externais
# (sed/grep/cat) podem ser capturados com $().

set -u

EVALS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$EVALS_ROOT")"

SKILL=""; FIXTURE=""; MODULE=""; REGISTRY=0
while [ $# -gt 0 ]; do
  case "$1" in
    --skill)   SKILL="$2"; shift 2 ;;
    --fixture) FIXTURE="$2"; shift 2 ;;
    --module)  MODULE="$2"; shift 2 ;;
    --all)     shift ;;
    --changed) CHANGED=1; shift ;;
    --registry) REGISTRY=1; shift ;;
    --neutrality)
      # Gate de neutralidade (open core, Fase 1): delega ao scanner dedicado
      # e sai com o exit code dele (0 = OK, 1 = hit de conteudo privado).
      exec bash "$EVALS_ROOT/neutrality/scan.sh" ;;
    *) echo "uso: run-evals.sh [--skill X] [--fixture X/Y] [--changed] [--registry] [--neutrality] [--module Z]"; exit 2 ;;
  esac
done

PASS=0; FAIL=0; WARN=0; TOTAL=0; SKIPPED=0
RESULTS=()

# ---------- funcoes custom -> saida por variavel global (NUNCA $()) ----------

RD_OUT=""
read_doc() {  # $1 = path
  RD_OUT=""
  if [ -f "$1" ]; then RD_OUT="$(cat "$1")"; fi
}

GI_OUT=""
get_ids() {  # $1 = texto ; $2 = pattern com (\d+) -> GI_OUT = ids unicos por linha
  local ere
  ere="$(printf '%s' "$2" | sed 's/\\d/[0-9]/g')"
  GI_OUT="$(printf '%s' "$1" | grep -oE "$ere" | grep -oE '[0-9]+' | awk '!seen[$0]++')"
}

PARAM_VAL=""
param() {  # $1 = params blob ; $2 = key
  local blob="$1" key="$2" line rest
  PARAM_VAL=""
  while [ -n "$blob" ]; do
    rest="${blob#*$'\n'}"
    if [ "$rest" = "$blob" ]; then line="$blob"; blob=""; else line="${blob%%$'\n'*}"; blob="$rest"; fi
    case "$line" in
      "$key="*) PARAM_VAL="${line#*=}"; return 0 ;;
    esac
  done
  return 0
}

PL_OUT=""
param_list() {  # $1 = params blob ; $2 = key (inline [a,b] ou bloco)
  local blob="$1" key="$2" line rest inline="" item
  PL_OUT=""
  while [ -n "$blob" ]; do
    rest="${blob#*$'\n'}"
    if [ "$rest" = "$blob" ]; then line="$blob"; blob=""; else line="${blob%%$'\n'*}"; blob="$rest"; fi
    case "$line" in
      "$key="*)
        inline="${line#*=}"
        inline="${inline#[}"; inline="${inline%]}"
        while [ -n "$inline" ]; do
          rest="${inline#*,}"
          if [ "$rest" = "$inline" ]; then item="$inline"; inline=""; else item="${inline%%,*}"; inline="$rest"; fi
          item="${item#[[:space:]]}"; item="${item#"${item%%[![:space:]]*}"}"
          item="${item%\"}"; item="${item#\"}"
          [ -n "$item" ] && PL_OUT="$PL_OUT$item"$'\n'
        done
        return 0
        ;;
      "__list_$key="*)
        item="${line#__list_$key=}"
        item="${item%\"}"; item="${item#\"}"
        PL_OUT="$PL_OUT$item"$'\n'
        ;;
    esac
  done
  return 0
}

NM_OUT=""
normalize() {  # $1 = texto -> NM_OUT (datas, horas, espacos e blanks normalizados)
  NM_OUT="$(printf '%s' "$1" | sed -E 's/[0-9]{4}-[0-9]{2}-[0-9]{2}/<DATE>/g; s@[0-9]{2}/[0-9]{2}/[0-9]{4}@<DATE>@g; s/[0-9]{2}:[0-9]{2}/<TIME>/g' | sed 's/[ \t]*$//' | cat -s)"
}

MERMAID_OK=0
test_mermaid() {  # $1 = doc
  local doc="$1" first ob cb obk cbk
  MERMAID_OK=0
  printf '%s' "$doc" | awk '/^```mermaid/{f=1;next} /^```$/{f=0} f' > /tmp/.re_mermaid.txt
  [ -s /tmp/.re_mermaid.txt ] || return 0
  first="$(head -n1 /tmp/.re_mermaid.txt | sed 's/[[:space:]]*$//')"
  case "$first" in
    erDiagram*|flowchart*|graph*|sequenceDiagram*|classDiagram*|stateDiagram*|gantt*|pie*|mindmap*|timeline*|journey*|gitGraph*) ;;
    *) return 0 ;;
  esac
  grep -v -- '--' /tmp/.re_mermaid.txt > /tmp/.re_mermaid_code.txt
  ob="$(grep -o '{' /tmp/.re_mermaid_code.txt | wc -l | tr -d ' ')"
  cb="$(grep -o '}' /tmp/.re_mermaid_code.txt | wc -l | tr -d ' ')"
  [ "$ob" -eq "$cb" ] || return 0
  obk="$(grep -o '\[' /tmp/.re_mermaid_code.txt | wc -l | tr -d ' ')"
  cbk="$(grep -o '\]' /tmp/.re_mermaid_code.txt | wc -l | tr -d ' ')"
  [ "$obk" -eq "$cbk" ] || return 0
  MERMAID_OK=1
}

# ---------- parser mini-YAML (schema criteria.yaml) ----------

CK_N=0; CK_TYPE=(); CK_PARAMS=()
parse_criteria() {  # $1 = criteria.yaml
  local file="$1" n=0 t key val LAST_KEY="" ty
  CK_N=0; CK_TYPE=(); CK_PARAMS=()
  while IFS= read -r line || [ -n "$line" ]; do
    t="$(printf '%s' "$line" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
    case "$t" in
      "- type:"*)
        ty="${t#- type:}"
        ty="${ty#"${ty%%[![:space:]]*}"}"; ty="${ty%"${ty##*[![:space:]]}"}"
        ty="${ty%\"}"; ty="${ty#\"}"
        n=$((n+1)); CK_N=$n; CK_TYPE[$n]="$ty"; CK_PARAMS[$n]=""
        ;;
    esac
    if [ $n -gt 0 ]; then
      case "$t" in
        "- type:"*) : ;;
        "-"*)
          key="${t#- }"; key="${key%\"}"; key="${key#\"}"
          CK_PARAMS[$n]="${CK_PARAMS[$n]}__list_${LAST_KEY}=${key}"$'\n'
          ;;
        *": "*)
          key="${t%%: *}"; val="${t#*: }"
          [ "$key" = "type" ] && continue
          val="${val%\"}"; val="${val#\"}"
          sq="'"
          val="${val%$sq}"; val="${val#$sq}"
          CK_PARAMS[$n]="${CK_PARAMS[$n]}${key}=${val}"$'\n'
          ;;
        *":")
          LAST_KEY="${t%:}"
          ;;
      esac
    fi
  done < "$file"
}

# ---------- modo registry (IMP-027): consistencia registry.yaml x agentes/skills ----------

if [ "$REGISTRY" -eq 1 ]; then
  reg="$REPO_ROOT/registry.yaml"
  if [ ! -f "$reg" ]; then echo "registry.yaml nao encontrado em $REPO_ROOT"; exit 1; fi
  ids="$(mktemp)"; agent_ids="$(mktemp)"; skill_ids="$(mktemp)"; refs="$(mktemp)"; skill_dom="$(mktemp)"; dom_map="$(mktemp)"
  last_skill=""; cur_domain=""
  section=""
  while IFS= read -r line; do
    line="${line%$'\r'}"  # tolera registry.yaml com CRLF (working tree Windows)
    case "$line" in
      [A-Za-z_]*":") section="${line%:}" ;;
    esac
    case "$section" in
      skills)
        d="$(printf '%s' "$line" | sed -n 's/^[[:space:]]*domain:[[:space:]]*\([a-z_]*\).*/\1/p')"
        [ -n "$d" ] && [ -n "$last_skill" ] && printf '%s %s\n' "$last_skill" "$d" >> "$skill_dom"
        ;;
      domains)
        k="$(printf '%s' "$line" | sed -n 's/^[[:space:]]\{2\}\([a-z_]*\):[[:space:]]*$/\1/p')"
        [ -n "$k" ] && cur_domain="$k"
        r2="$(printf '%s' "$line" | sed -n 's/^[[:space:]]\{6\}-[[:space:]]*\([a-z][a-z0-9_-]*\)[[:space:]]*$/\1/p')"
        [ -n "$r2" ] && [ -n "$cur_domain" ] && printf '%s %s\n' "$r2" "$cur_domain" >> "$dom_map"
        ;;
    esac
    id="$(printf '%s' "$line" | sed -n 's/^[[:space:]]*-[[:space:]]*id:[[:space:]]*\([A-Za-z0-9_-]*\).*/\1/p')"
    if [ -n "$id" ]; then
      echo "$id" >> "$ids"
      case "$section" in
        primary_agents|subagents) echo "$id" >> "$agent_ids" ;;
        skills) echo "$id" >> "$skill_ids"; last_skill="$id" ;;
      esac
      continue
    fi
    ref="$(printf '%s' "$line" | sed -n 's/^[[:space:]]\{4,\}-[[:space:]]*\([A-Za-z][A-Za-z0-9_-]*\)[[:space:]]*$/\1/p')"
    if [ -n "$ref" ]; then echo "$ref" >> "$refs"; continue; fi
    ref="$(printf '%s' "$line" | sed -n 's/^[[:space:]]*\(owner\|registered_by\|orchestrator\):[[:space:]]*\([A-Za-z0-9_-]*\).*/\2/p')"
    # "null" = sem orquestrador fixo (legitimo) — nao é referencia
    [ -n "$ref" ] && [ "$ref" != "null" ] && echo "$ref" >> "$refs"
  done < "$reg"

  reg_check() {  # $1=nome $2=0/1 $3=detalhe
    if [ "$2" -eq 1 ]; then
      RESULTS+=("_registry|registry|$1|PASS|error|$3"); PASS=$((PASS+1))
    else
      RESULTS+=("_registry|registry|$1|FAIL|error|$3"); FAIL=$((FAIL+1))
    fi
    TOTAL=$((TOTAL+1))
  }

  dang="$(sort -u "$refs" | while IFS= read -r r; do [ -n "$r" ] || continue; grep -qxF "$r" "$ids" || echo "$r"; done | paste -sd, -)"
  if [ -z "$dang" ]; then reg_check "registry:referencias_resolvem" 1 "todas as referencias resolvem"; else reg_check "registry:referencias_resolvem" 0 "$dang"; fi

  orph=""
  for f in "$REPO_ROOT"/agents/rdd-*.md; do
    [ -e "$f" ] || continue
    b="$(basename "$f" .md)"
    grep -qxF "$b" "$ids" || orph="$orph$b,"
  done
  if [ -z "$orph" ]; then reg_check "registry:agentes_em_disco_registrados" 1 "todos os agentes em disco registrados"; else reg_check "registry:agentes_em_disco_registrados" 0 "$orph"; fi

  miss=""
  while IFS= read -r a; do
    [ -n "$a" ] || continue
    [ -f "$REPO_ROOT/agents/$a.md" ] || miss="$miss$a,"
  done < "$agent_ids"
  if [ -z "$miss" ]; then reg_check "registry:agentes_registrados_tem_arquivo" 1 "todos os agentes registrados tem arquivo"; else reg_check "registry:agentes_registrados_tem_arquivo" 0 "$miss"; fi

  orph=""
  for d in "$REPO_ROOT"/skills/rdd-*/; do
    [ -d "$d" ] || continue
    b="$(basename "$d")"
    grep -qxF "$b" "$skill_ids" || orph="$orph$b,"
  done
  if [ -z "$orph" ]; then reg_check "registry:skills_em_disco_registradas" 1 "todas as skills em disco registradas"; else reg_check "registry:skills_em_disco_registradas" 0 "$orph"; fi

  miss=""
  while IFS= read -r s; do
    [ -n "$s" ] || continue
    [ -f "$REPO_ROOT/skills/$s/SKILL.md" ] || miss="$miss$s,"
  done < "$skill_ids"
  if [ -z "$miss" ]; then reg_check "registry:skills_registradas_tem_skill_md" 1 "todas as skills registradas tem SKILL.md"; else reg_check "registry:skills_registradas_tem_skill_md" 0 "$miss"; fi

  mism=""
  while IFS= read -r pair; do
    [ -n "$pair" ] || continue
    s="${pair%% *}"; d="${pair#* }"
    # duplo registro (id tambem e subagent) nao precisa constar em domains.*.skills
    grep -qxF "$s" "$agent_ids" && continue
    grep -qxF "$s $d" "$dom_map" || mism="$mism$s($d),"
  done < "$skill_dom"
  if [ -z "$mism" ]; then reg_check "registry:dominios_consistentes" 1 "domain flat de cada skill consta em domains.*.skills (duplo registro isento)"; else reg_check "registry:dominios_consistentes" 0 "$mism"; fi

  rm -f "$ids" "$agent_ids" "$skill_ids" "$refs" "$skill_dom" "$dom_map"
fi

# ---------- selecao de fixtures ----------

if [ "$REGISTRY" -ne 1 ]; then
TARGETS=""
TARGETS_FILE="/tmp/.re_targets.$$.txt"
: > "$TARGETS_FILE"
while IFS= read -r d; do
  [ -f "$d/criteria.yaml" ] || continue
  sk="$(basename "$(dirname "$d")")"
  fx="$(basename "$d")"
  if [ -n "$FIXTURE" ]; then
    [ "$sk/$fx" = "$FIXTURE" ] && echo "$sk|$fx|$d" >> "$TARGETS_FILE"
  elif [ -n "$SKILL" ]; then
    [ "$sk" = "$SKILL" ] && echo "$sk|$fx|$d" >> "$TARGETS_FILE"
  elif [ -n "${CHANGED:-}" ]; then
    dirty="$(git -C "$REPO_ROOT" status --porcelain 2>/dev/null || true)"
    if printf '%s' "$dirty" | grep -q "evals/$sk/\|skills/$sk/SKILL.md"; then
      echo "$sk|$fx|$d" >> "$TARGETS_FILE"
    fi
  else
    echo "$sk|$fx|$d" >> "$TARGETS_FILE"
  fi
done < <(find "$EVALS_ROOT" -mindepth 2 -maxdepth 2 -type d -name 'fixture-*' | sort)

if [ ! -s "$TARGETS_FILE" ]; then
  echo "nenhuma fixture selecionada - nada a rodar"
  rm -f "$TARGETS_FILE"
  exit 0
fi

# ---------- execucao ----------

while IFS= read -r t; do
  [ -n "$t" ] || continue
  sk="${t%%|*}"; rest="${t#*|}"; fx="${rest%%|*}"; fxdir="${rest#*|}"

  if [ -n "$MODULE" ]; then modroot="$MODULE"
  elif [ -d "$fxdir/output-expected" ]; then modroot="$fxdir/output-expected"
  else modroot=""; fi

  parse_criteria "$fxdir/criteria.yaml"

  i=1
  while [ $i -le $CK_N ]; do
    ty="${CK_TYPE[$i]}"; params="${CK_PARAMS[$i]}"
    param "$params" severity; sev="${PARAM_VAL:-error}"
    param "$params" path; rel="$PARAM_VAL"

    if [ -z "$modroot" ]; then
      if [ "$ty" = "not_file_exists" ]; then
        RESULTS+=("$sk|$fx|$fx/not_file_exists|PASS|$sev|sem modulo (abort)")
        PASS=$((PASS+1)); TOTAL=$((TOTAL+1))
      else
        SKIPPED=$((SKIPPED+1))
      fi
      i=$((i+1)); continue
    fi

    abs="$modroot/$rel"
    isdir=0
    case "$rel" in */) isdir=1 ;; esac
    [ -d "$abs" ] && isdir=1

    label="$fx/$ty"
    [ -n "$rel" ] && label="$fx/$ty:$rel"
    detail=""; state="PASS"

    case "$ty" in
      file_exists)     [ -f "$abs" ] || state="FAIL" ;;
      not_file_exists) [ ! -e "$abs" ] || state="FAIL" ;;
      dir_has_files)
        n="$(find "$abs" -type f 2>/dev/null | wc -l | tr -d ' ')"
        [ "$n" -ge 1 ] || state="FAIL"; detail="arquivos=$n" ;;
      frontmatter_valid)
        read_doc "$abs"
        firstline="$(printf '%s' "$RD_OUT" | head -n1 | tr -d '\r')"
        { [ -f "$abs" ] && [ "$firstline" = "---" ]; } || state="FAIL" ;;
      contains)
        param "$params" pattern; pat="$PARAM_VAL"
        if [ $isdir -eq 1 ]; then
          found=0
          while IFS= read -r f; do
            [ -n "$f" ] || continue
            read_doc "$f"
            case "$RD_OUT" in *"$pat"*) found=1; break ;; esac
          done < <(dir_md_files() { find "$abs" -type f -name '*.md' 2>/dev/null; }; dir_md_files)
          [ $found -eq 1 ] || state="FAIL"
        else
          read_doc "$abs"
          case "$RD_OUT" in *"$pat"*) ;; *) state="FAIL" ;; esac
        fi ;;
      not_contains)
        param "$params" pattern; pat="$PARAM_VAL"
        if [ $isdir -eq 1 ]; then
          found=0
          while IFS= read -r f; do
            [ -n "$f" ] || continue
            read_doc "$f"
            case "$RD_OUT" in *"$pat"*) found=1; break ;; esac
          done < <(dir_md_files() { find "$abs" -type f -name '*.md' 2>/dev/null; }; dir_md_files)
          [ $found -eq 1 ] && state="FAIL"
        else
          read_doc "$abs"
          case "$RD_OUT" in *"$pat"*) state="FAIL" ;; esac
        fi ;;
      no_todos)
        param_list "$params" patterns
        hits=""
        while IFS= read -r p; do
          [ -n "$p" ] || continue
          read_doc "$abs"
          case "$RD_OUT" in *"$p"*) hits="$hits $p" ;; esac
        done < <(printf '%s' "$PL_OUT")
        [ -z "$hits" ] || { state="FAIL"; detail="encontrados:$hits"; } ;;
      section_exists)
        param "$params" section; sec="$PARAM_VAL"
        read_doc "$abs"
        case "$RD_OUT" in *"$sec"*) ;; *) state="FAIL" ;; esac ;;
      section_order)
        prev=0; ok=1
        param_list "$params" sections
        while IFS= read -r sec; do
          [ -n "$sec" ] || continue
          ln="$(grep -n -F -m1 -- "$sec" "$abs" | head -n1 | cut -d: -f1)"
          if [ -z "$ln" ]; then ok=0; detail="ausente: $sec"; break; fi
          if [ "$ln" -le "$prev" ]; then ok=0; detail="fora de ordem: $sec"; break; fi
          prev="$ln"
        done < <(printf '%s' "$PL_OUT")
        [ $ok -eq 1 ] || state="FAIL"
        [ -z "$detail" ] && detail="ordem ok" ;;
      line_count_range)
        if [ $isdir -eq 1 ]; then
          total=0
          while IFS= read -r f; do
            [ -n "$f" ] || continue
            total=$((total + $(wc -l < "$f" | tr -d ' ')))
          done < <(find "$abs" -type f -name '*.md' 2>/dev/null)
        else total="$(wc -l < "$abs" | tr -d ' ')"; fi
        param "$params" min; mn="$PARAM_VAL"; param "$params" max; mx="$PARAM_VAL"
        if [ "$total" -lt "$mn" ] || [ "$total" -gt "$mx" ]; then state="FAIL"; fi
        detail="linhas=$total (faixa $mn-$mx)" ;;
      id_sequence)
        read_doc "$abs"
        param "$params" pattern; pat="$PARAM_VAL"
        get_ids "$RD_OUT" "$pat"; ids="$GI_OUT"
        asc=1; nogap=1; prev=""
        while IFS= read -r v; do
          [ -n "$v" ] || continue
          if [ -n "$prev" ]; then
            [ "$v" -lt "$prev" ] && asc=0
            param "$params" allow_gaps; ag="$PARAM_VAL"
            [ "$ag" = "true" ] || { [ "$v" -ne $((prev+1)) ] && nogap=0; }
          fi
          prev="$v"
        done < <(printf '%s' "$ids")
        { [ $asc -eq 1 ] && [ $nogap -eq 1 ]; } || state="FAIL"
        detail="primeira aparicao: $(printf '%s' "$ids" | tr '\n' ',')" ;;
      cross_ref)
        if [ $isdir -eq 1 ]; then
          doc=""
          while IFS= read -r f; do
            [ -n "$f" ] || continue
            read_doc "$f"; doc="$doc$RD_OUT"$'\n'
          done < <(find "$abs" -type f -name '*.md' 2>/dev/null)
        else read_doc "$abs"; doc="$RD_OUT"; fi
        param "$params" pattern; pat="$PARAM_VAL"
        get_ids "$doc" "$pat"; ids="$GI_OUT"
        srcids=""
        param_list "$params" sources
        while IFS= read -r s; do
          [ -n "$s" ] || continue
          read_doc "$modroot/$s"
          get_ids "$RD_OUT" "$pat"
          srcids="$srcids$GI_OUT"$'\n'
        done < <(printf '%s' "$PL_OUT")
        hall=""
        while IFS= read -r v; do
          [ -n "$v" ] || continue
          case "$srcids" in
            *$'\n'"$v"$'\n'*|"$v"$'\n'*|*"$v") : ;;
            *) hall="$hall $v" ;;
          esac
        done < <(printf '%s' "$ids")
        if [ -n "$hall" ]; then state="FAIL"; detail="alucinados:$hall"; else detail="ok"; fi ;;
      mermaid_valid)
        read_doc "$abs"
        test_mermaid "$RD_OUT"
        [ $MERMAID_OK -eq 1 ] || state="FAIL" ;;
      table_has_columns)
        param_list "$params" columns
        found=0
        while IFS= read -r line; do
          [ -n "$line" ] || continue
          all=1
          while IFS= read -r col; do
            [ -n "$col" ] || continue
            case "$line" in *"$col"*) ;; *) all=0; break ;; esac
          done < <(printf '%s' "$PL_OUT")
          [ $all -eq 1 ] && { found=1; break; }
        done < <(grep '^|' "$abs")
        [ $found -eq 1 ] || state="FAIL" ;;
      reference_match)
        param "$params" expected; exp="$PARAM_VAL"
        [ -n "$exp" ] || exp="$rel"
        expfile="$fxdir/$exp"
        [ -f "$expfile" ] || expfile="$abs"
        if [ ! -f "$expfile" ]; then state="FAIL"; detail="baseline ausente: $exp"
        else
          read_doc "$abs"; normalize "$RD_OUT"; a="$NM_OUT"
          read_doc "$expfile"; normalize "$RD_OUT"; b="$NM_OUT"
          [ "$a" = "$b" ] || state="FAIL"
        fi ;;
      *)
        SKIPPED=$((SKIPPED+1)); i=$((i+1)); continue ;;
    esac

    case "$state" in
      PASS) PASS=$((PASS+1)) ;;
      FAIL) FAIL=$((FAIL+1)) ;;
      WARN) WARN=$((WARN+1)) ;;
    esac
    TOTAL=$((TOTAL+1))
    RESULTS+=("$sk|$fx|$label|$state|$sev|$detail")
    i=$((i+1))
  done
done < "$TARGETS_FILE"
rm -f "$TARGETS_FILE" /tmp/.re_mermaid.txt /tmp/.re_mermaid_code.txt
fi  # fim guarda registry (IMP-027)

# ---------- resumo ----------

echo ""
echo "================ run-evals ================"
for r in "${RESULTS[@]}"; do
  state="$(printf '%s' "$r" | cut -d'|' -f4)"
  [ "$state" = "PASS" ] && continue
  printf '%s' "$r" | awk -F'|' '{ printf "%-22s %-12s %-45s %-5s %s\n", $1, $2, $3, $4, $6 }'
done
echo ""
echo "TOTAL: $PASS PASS / $FAIL FAIL / $WARN WARN de $TOTAL checks $( [ $SKIPPED -gt 0 ] && echo "($SKIPPED skipped)" )"

# trends.json (append via python3 real, se existir)
HAS_PY=0
if command -v python3 >/dev/null 2>&1; then
  if python3 -c 'print(1)' >/dev/null 2>&1; then HAS_PY=1; fi
fi
if [ $HAS_PY -eq 1 ]; then
  python3 - "$EVALS_ROOT/trends/trends.json" "$PASS" "$FAIL" <<'PY'
import json, sys, datetime
path, passed, failed = sys.argv[1], int(sys.argv[2]), int(sys.argv[3])
try:
    # utf-8-sig: tolera BOM gravado pelo runner PS (Set-Content -Encoding UTF8, PS 5.1)
    with open(path, encoding="utf-8-sig") as fh:
        trends = json.load(fh)
except FileNotFoundError:
    trends = {}
except Exception as e:
    # fail-safe: erro de parse NUNCA reseta o historico — aborta sem escrever
    print("aviso: trends.json nao atualizado (parse falhou: %s)" % e)
    sys.exit(0)
ts = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
trends[ts] = {"trigger": "runner", "mode": "all", "skills": {
    "_suite": {"score": round(passed / max(1, passed + failed), 2), "passed": passed, "failed": failed, "skipped": 0}
}}
with open(path, "w", encoding="utf-8") as fh:
    json.dump(trends, fh, ensure_ascii=False, indent=2)
PY
else
  echo "aviso: python3 real indisponivel — trends.json nao atualizado"
fi

# relatorio markdown
tsfile="$(date +%Y-%m-%d-%H%M%S)"
report="$EVALS_ROOT/reports/EVAL_REPORT_runner_all_$tsfile.md"
{
  echo "# EVAL REPORT — runner deterministico"
  echo ""
  echo "> **Data:** $(date '+%d/%m/%Y %H:%M')"
  echo "> **Resultado:** $PASS PASS / $FAIL FAIL / $WARN WARN de $TOTAL checks"
  echo ""
  echo "| Skill | Fixture | Check | Resultado | Severidade | Detalhe |"
  echo "|---|---|---|---|---|---|"
  for r in "${RESULTS[@]}"; do
    printf '%s' "$r" | awk -F'|' '{ print "| "$1" | "$2" | "$3" | "$4" | "$5" | "$6" |" }'
  done
} > "$report"
echo "Relatorio: $report"

if [ "$FAIL" -gt 0 ]; then exit 1; fi
exit 0
