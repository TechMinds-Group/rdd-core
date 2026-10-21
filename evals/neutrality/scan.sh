#!/usr/bin/env bash
# scan.sh — Gate de neutralidade do open core (Fase 1 — Apache-2.0 + DCO).
#
# Scanner determinístico: falha se conteúdo identificado de organização/cliente
# aparecer na base aberta do workflow (agents/, skills/, registry, templates,
# evals/). Determinístico: mesma árvore => mesma saída.
#
# Escopo (a partir da raiz do repo, resolvida relativa a este script):
#   agents/rdd-*.md, skills/**/* (qualquer arquivo), registry.yaml,
#   rules/stack-templates.yaml, AGENTS.template.md, evals/ (recursivo).
#
# Exclusões explícitas (motivo entre parênteses):
#   evals/reports/     (histórico de execuções — não é base)
#   evals/trends/      (dados acumulados — não é base)
#   evals/golden-human/(casos humanos — IMP-100; fora do core por definição)
#   evals/neutrality/  (o próprio scanner contém a wordlist)
#   evals/run-evals.sh (apenas delega a este scanner)
#   rules/packs/*.md, packs/ (instalados de pack — fonte no repo do pack, IMP-112)
#   *.md da raiz, incl. README (docs vivos — branding do dono mantido por
#     decisão IMP-105; sanitização só na publicação, Fase 3)
#   quality/           (operacional)
#   plugins/           (extensões locais)
#   MANIFEST.sha256    (checksums — não é conteúdo)
#
# Saída: uma linha por hit `caminho:linha: trecho`; no fim
#   `neutrality: FALHOU (<N> hits)` + exit 1, ou
#   `neutrality: OK (<A> arquivos varridos)` + exit 0.

set -euo pipefail
export LC_ALL=C

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$REPO_ROOT"

# Wordlist de neutralidade (ERE, case-insensitive): org, clientes, produtos e
# identificadores que NÃO podem vazar para o open core.
WORDLIST='techminds|procergs|rpg[-_ ]?maker|TM\.RDD\.DOCS|groom|\bPOL\.[0-9]|\bSDA\.[0-9]|\bsda-'

LIST="$(mktemp)"
trap 'rm -f "$LIST"' EXIT
: > "$LIST"

# --- montagem determinística da lista de arquivos (escopo fechado) ---
# agents: primary/subagents da base
find agents -maxdepth 1 -type f -name 'rdd-*.md' 2>/dev/null >> "$LIST" || true
# skills: todo o conteúdo, qualquer arquivo
find skills -type f 2>/dev/null >> "$LIST" || true
# manifestos e templates de raiz
for f in registry.yaml rules/stack-templates.yaml AGENTS.template.md; do
  [ -f "$f" ] && printf '%s\n' "$f" >> "$LIST"
done
# evals: recursivo, com as exclusões comentadas no cabeçalho
find evals -type f \
  -not -path 'evals/reports/*' \
  -not -path 'evals/trends/*' \
  -not -path 'evals/golden-human/*' \
  -not -path 'evals/neutrality/*' \
  -not -path 'evals/run-evals.sh' \
  2>/dev/null >> "$LIST" || true

# Fora do escopo por construção (nunca entram na lista): rules/packs/ e packs/
# (instalados de pack — IMP-112; nota futura: excluir via sources.yaml skills de
# pack instaladas em skills/), docs vivos da raiz (*.md), quality/, plugins/,
# MANIFEST.sha256.

sort -u "$LIST" -o "$LIST"

HITS=0
SCANNED=0
while IFS= read -r f; do
  [ -n "$f" ] || continue
  SCANNED=$((SCANNED + 1))
  out="$(grep -HniE "$WORDLIST" "$f" 2>/dev/null || true)"
  if [ -n "$out" ]; then
    printf '%s\n' "$out"
    n="$(printf '%s\n' "$out" | wc -l | tr -d ' ')"
    HITS=$((HITS + n))
  fi
done < "$LIST"

if [ "$HITS" -gt 0 ]; then
  echo "neutrality: FALHOU ($HITS hits)"
  exit 1
fi
echo "neutrality: OK ($SCANNED arquivos varridos)"
exit 0
