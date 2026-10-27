#!/usr/bin/env bash
# validate.sh — Gate de CI do hub de patterns (Fase 1 open core).
#
# Valida o front matter de patterns/*.md — patlets (isentos: TEMPLATE.md e
# INDEX.md — infraestrutura do hub):
#   - campos obrigatórios presentes
#   - status dentro do enum (proposed|validated|accepted|superseded)
#   - categoria dentro do enum (codigo|arquitetura|processo|ui|dados|teste)
#   - datas em formato AAAA-MM-DD (criado_em, ultima_revisao, warranty_ate)
#   - superseded_by obrigatório se status=superseded
#   - shepherd obrigatório se status=validated|accepted
#   - warranty_ate obrigatório se status=accepted
#
# Determinístico: mesma árvore => mesma saída. Bash puro, sem dependências.
# Saída: `patterns: OK (<N> patterns validados)` + exit 0, ou
#        `<arquivo>:<linha>: <motivo>` acumulado + `patterns: FALHOU` + exit 1.
#
# Uso: bash patterns/validate.sh   (roda de qualquer diretório)

set -euo pipefail
export LC_ALL=C

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ERROS=0
N=0

trim() {
  local s="$1"
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  printf '%s' "$s"
}

erro() { # erro <arquivo> <linha> <motivo>
  echo "$1:$2: $3" >&2
  ERROS=$((ERROS + 1))
}

# preenchido <valor>: exit 0 = tem valor (não vazio, não null)
preenchido() {
  [ -n "$1" ] && [ "$1" != "null" ]
}

data_valida() {
  [[ "$1" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]
}

validar() {
  local f="$1"
  local dentro=0 linha_no=0 linha k bruto v
  local -A VALOR=() LINHA=() VISTO=()

  while IFS= read -r linha || [ -n "$linha" ]; do
    linha="${linha%$'\r'}" # tolerante a CRLF
    linha_no=$((linha_no + 1))
    if [ "$linha_no" -eq 1 ]; then
      if [ "$linha" != "---" ]; then
        erro "$f" 1 "front matter ausente (o arquivo deve começar com ---)"
        return
      fi
      dentro=1
      continue
    fi
    [ "$dentro" -eq 1 ] || continue
    if [ "$linha" = "---" ]; then
      dentro=2
      break
    fi
    if [[ "$linha" =~ ^([a-z_]+):[[:space:]]*(.*)$ ]]; then
      k="${BASH_REMATCH[1]}"
      bruto="${BASH_REMATCH[2]}"
      v="${bruto%%[[:space:]]#*}" # remove comentário inline ` # ...`
      v="$(trim "$v")"
      VALOR["$k"]="$v"
      LINHA["$k"]="$linha_no"
      VISTO["$k"]=1
    fi
  done < "$f"

  if [ "$dentro" -ne 2 ]; then
    erro "$f" "$linha_no" "front matter não fechado (falta o --- final)"
    return
  fi

  local campo
  for campo in id titulo categoria status origem projetos_validacao shepherd criado_em ultima_revisao superseded_by warranty_ate; do
    if [ -z "${VISTO[$campo]:-}" ]; then
      erro "$f" 1 "campo obrigatório ausente: $campo"
    fi
  done

  local status="${VALOR[status]:-}"

  case "$status" in
    proposed|validated|accepted|superseded) ;;
    *) erro "$f" "${LINHA[status]:-1}" "status inválido: '$status' (enum: proposed|validated|accepted|superseded)" ;;
  esac

  case "${VALOR[categoria]:-}" in
    codigo|arquitetura|processo|ui|dados|teste) ;;
    *) erro "$f" "${LINHA[categoria]:-1}" "categoria inválida: '${VALOR[categoria]:-}' (enum: codigo|arquitetura|processo|ui|dados|teste)" ;;
  esac

  for campo in criado_em ultima_revisao; do
    if [ -n "${VALOR[$campo]:-}" ]; then
      if ! data_valida "${VALOR[$campo]}"; then
        erro "$f" "${LINHA[$campo]:-1}" "$campo fora do formato AAAA-MM-DD: '${VALOR[$campo]}'"
      fi
    fi
  done

  if preenchido "${VALOR[warranty_ate]:-}"; then
    if ! data_valida "${VALOR[warranty_ate]}"; then
      erro "$f" "${LINHA[warranty_ate]:-1}" "warranty_ate fora do formato AAAA-MM-DD: '${VALOR[warranty_ate]}'"
    fi
  fi

  if [ "$status" = "superseded" ]; then
    if ! preenchido "${VALOR[superseded_by]:-}"; then
      erro "$f" "${LINHA[superseded_by]:-1}" "status=superseded exige superseded_by (PAT-NNN que o substituiu)"
    fi
  fi

  if [ "$status" = "validated" ] || [ "$status" = "accepted" ]; then
    if ! preenchido "${VALOR[shepherd]:-}"; then
      erro "$f" "${LINHA[shepherd]:-1}" "status=$status exige shepherd (revisor de empresa != origem)"
    fi
  fi

  if [ "$status" = "accepted" ]; then
    if ! preenchido "${VALOR[warranty_ate]:-}"; then
      erro "$f" "${LINHA[warranty_ate]:-1}" "status=accepted exige warranty_ate (aceite + 30 dias)"
    fi
  fi
}

for f in "$SCRIPT_DIR"/*.md; do
  [ -e "$f" ] || continue
  base="$(basename "$f")"
  if [ "$base" = "TEMPLATE.md" ] || [ "$base" = "INDEX.md" ]; then
    continue # infraestrutura do hub (template e índice) — isentos do gate
  fi
  validar "$f"
  N=$((N + 1))
done

if [ "$ERROS" -gt 0 ]; then
  echo "patterns: FALHOU ($ERROS erro(s))" >&2
  exit 1
fi

echo "patterns: OK ($N patterns validados)"