# PACK_SCHEMA — Contrato do pack.yaml (v1)

O RDD é **open core** (Apache-2.0 + DCO) com arquitetura **CORE / PACK / PROFILE**:

- **CORE** — esta base, neutra e pública (skills, agents, evals do workflow).
- **PACK** — por empresa: 1 repo privado com TODA a camada de conteúdo da org (regras, skills de pack, acúmulo).
- **PROFILE** — `rules/client-profile.md` (gitignored): defaults do cliente, incluindo `packs: [<id>@<faixa>]`.

Por empresa existem **2 repos**: o core (compartilhado) + 1 pack privado.

## Estrutura do runtime

```text
~/.config/opencode/
├── <clone do core>              # esta base
├── packs/<id>/                  # clone do pack (gitignored pelo core)
└── .rdd/sources.yaml            # lockfile — pin de commit exato por pack
```

A instalação é **por cópia**: os paths de `provides` do clone em `packs/<id>/`
são copiados para o runtime. O clone permanece como fonte; a cópia é o que roda.

## Campos do pack.yaml

| Campo | Tipo | Obrigatório | Regra |
|-------|------|-------------|-------|
| `id` | string | sim | `lowercase-hyphen` (ex.: `acme`) — identidade do pack em `packs/<id>/` e no lockfile |
| `name` | string | sim | Nome de exibição |
| `version` | semver | sim | Versão do pack (ex.: `1.2.0`) |
| `requires-core` | faixa | sim | Faixa de compatibilidade com o core (ex.: `">=1 <2"`) |
| `provides[]` | lista de paths | sim | Paths relativos à raiz do pack, instalados (copiados) no runtime — **rejeitados se colidirem com path do core** |
| `accumulation[]` | lista de paths | não | Paths versionados no repo do pack que **NUNCA são instalados** (patterns, metrics, retros) |

## Exemplo completo (pack fictício `acme`)

```yaml
# pack.yaml — raiz do repo do pack (ex.: github.com/acme/rdd-pack-acme)
id: acme
name: Acme Pack
version: 1.2.0
requires-core: ">=1 <2"

# Paths relativos à raiz do pack, copiados para ~/.config/opencode/
provides:
  - rules/acme-org.md
  - skills/rdd-acme-handbook/SKILL.md

# Versionados no repo do pack, NUNCA instalados no runtime
accumulation:
  - accumulation/patterns/
  - accumulation/metrics/
  - accumulation/retros/
```

## Contrato do installer

1. **no-override** — um path de `provides` que colida com path existente do
   core **rejeita a instalação** (falha clara; pack nunca sobrescreve path do core).
2. **`requires-core`** — validado contra a **versão local do core** (campo
   `version` do `registry.yaml` + `BREAKING-CHANGES.md`). Incompatível →
   falha clara apontando `BREAKING-CHANGES.md` (o que mudou no major e como migrar).
3. **Instalação por cópia** dos paths de `provides` a partir de `packs/<id>/`.
   `accumulation[]` nunca é copiado.
4. **Lockfile `.rdd/sources.yaml`** — pin de commit exato por pack
   (a faixa no profile **autoriza**; o pin **garante reprodutibilidade**):

```yaml
# .rdd/sources.yaml
packs:
  acme:
    version: 1.2.0
    commit: 3f9c1ab7d0e2f4a6b8c0d1e2f3a4b5c6d7e8f9a0
    paths:
      - rules/acme-org.md
      - skills/rdd-acme-handbook/SKILL.md
```

5. **`.gitignore` local gerado** — o installer mantém uma seção gerada no
   `.gitignore` do runtime com os paths instalados (cópia de pack não vira
   diff do core):

```gitignore
# --- rdd packs (gerado — não editar) ---
/rules/acme-org.md
/skills/rdd-acme-handbook/SKILL.md
```

6. **Profile** — `rules/client-profile.md` declara `packs: [<id>@<faixa>]`;
   a faixa autoriza a versão que pode ser instalada, o pin no lockfile fixa
   a que foi instalada de fato.

## Regra do acúmulo

- O acúmulo (`accumulation[]`: patterns, metrics, retros) **anda no repo do pack,
  nunca no runtime** — é conhecimento de org, não config de máquina.
- **Ponte de contribuição:** pattern do acúmulo que se revela genérico →
  generalizar e abrir **PR no core** (neutro, sem dado de cliente). O core
  aceita apenas conteúdo neutro; o específico permanece no pack.
