# PUBLISH — Processo de Release Pública do Open Core

Como publicar um snapshot do `TM.CORE.RDD` (privado) no repositório público
`victor-souza-dev/RDD-CORE`. O modelo é **snapshot**: o repo público nunca
recebe o histórico interno — cada release substitui o conteúdo público pelo
subset essencial limpo da HEAD atual do core.

---

## Pré-condições (no TM.CORE.RDD, antes de publicar)

1. **Evals verdes** na HEAD a publicar:
   - `--all` → **810/810**
   - `--registry` → **6/6**
   - `--neutrality` → **OK**
2. **Mudanças IMP registradas** — toda alteração relevante do ciclo já está em
   `WORKFLOW_IMPROVEMENTS.md` (formato IMP-XXX). O que não foi registrado não
   está pronto para publicar.
3. **MANIFEST regenerado** — `MANIFEST.sha256` atualizado para a HEAD.

Se qualquer pré-condição falhar, **pare** — não se publica core vermelho.

## Subset essencial (o único que atravessa o gate)

Lista explícita — **a mesma** codificada em `publish/publish-core.sh`. Qualquer
arquivo fora dela **nunca** é publicado:

| Entrada | Observação |
|---------|------------|
| `.gitignore` | adotador clona o runtime já limpo (reports/trends/packs/instalados ignorados) |
| `agents/` | primaries e subagents |
| `skills/` | todas as skills |
| `registry.yaml` | manifesto canônico |
| `rules/stack-templates.yaml` | registry de boilerplates |
| `rules/client-profile.template.md` | template do perfil (o `client-profile.md` real **nunca** sai) |
| `AGENTS.template.md` | template de AGENTS.md |
| `evals/` | **exceto** `evals/reports/`, `evals/trends/`, `evals/golden-human/` |
| `README.md` | visão do produto |
| `LICENSE` | Apache-2.0 |
| `CONTRIBUTING.md` | guia de contribuição (open core + DCO + anonimização) |
| `PUBLISH.md` | este processo |
| `PACK_SCHEMA.md` | schema de packs |
| `BREAKING-CHANGES.md` | log de breaking changes |
| `.github/workflows/evals.yml` | CI de evals |
| `patterns/` | hub de patterns cross-empresa (TEMPLATE.md, INDEX.md e patterns aceites); `patterns/validate.sh` é gate do CI |

## Passos

1. Rode o script a partir da raiz do core (via WSL):

   ```bash
   bash publish/publish-core.sh --target /caminho/do/clone/local/rdd-core
   ```

   O script: monta uma **cópia temporária** só com o subset → roda
   `bash evals/neutrality/scan.sh` **dentro da cópia** → espelha no clone do
   `rdd-core` (limpa tudo exceto `.git`) → commit
   `release: snapshot TM.CORE.RDD@<sha> (<data UTC>)` → push `origin main`.

2. **Conferir o scan no copy** — o gate roda no snapshot e aborta em caso de
   `FALHOU`. Confirme no output que a linha final é
   `neutrality: OK (<N> arquivos varridos)`. Gate vermelho = release abortada
   sem publicar nada.

3. **Push do público** — o script faz `git push origin main` no clone do
   `rdd-core`. Confira o diff da release no público antes de anunciar.

## Regras inegociáveis

- **NUNCA publicar arquivo que falhe o gate** — `neutrality: FALHOU` aborta o
  release inteiro, sem exceção e sem "só dessa vez".
- **Nunca entram** no público: `WORKFLOW_IMPROVEMENTS.md` (IMPs), `DECISIONS.md`
  (ADRs), `quality/`, `evals/reports/`, `evals/trends/`,
  `evals/golden-human/`, `rules/client-profile.md`, `packs/`, `.rdd/` e
  `MANIFEST.sha256` do core.
- **Release versionada por tag de data** no repo público: `vYYYY-MM-DD`
  (ex.: `v2026-10-20`), criada no `rdd-core` após o push.

## Após o push

```bash
git -C /caminho/do/rdd-core tag v$(date -u +%Y-%m-%d)
git -C /caminho/do/rdd-core push origin v$(date -u +%Y-%m-%d)
```
