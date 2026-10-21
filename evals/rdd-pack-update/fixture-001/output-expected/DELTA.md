# Relatório — rdd-pack-update (pack demo)

Update executado com movimento de pin autorizado pelo operador
(solicitação explícita — "atualize o pack demo para a última").

## Delta

| Pack | Versão | Commit | Paths |
|---|---|---|---|
| demo | 0.9.0 → 1.0.0 | abc1234 → def5678 | rules/packs/demo.md |

- Pin movido no lockfile `.rdd/sources.yaml` — `0.9.0` → `1.0.0`
  (commit `abc1234` → `def5678`); a faixa do perfil (`demo@>=0.9 <2`)
  autorizou o destino, o movimento foi pedido explícito do operador.
- Arquivos reinstalados (cópia de `provides`): `rules/packs/demo.md`
  (regra nova do clone → runtime; paths adicionados — 0, removidos — 0).
- `requires-core` (">=1 <2") validado contra a versão local do core —
  compatível; sem entradas relevantes em `BREAKING-CHANGES.md`.
- no-override — nenhum path de `provides` colide com path do core.
- `accumulation/` do pack não foi instalado nem alterado.
- `.gitignore` local — seção gerada sem alteração (mesmos paths).
- Pendências — nenhuma.
