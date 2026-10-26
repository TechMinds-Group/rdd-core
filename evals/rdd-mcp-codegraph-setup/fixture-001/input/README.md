# Grafos Locais

Projeto interno de inventário de ativos. Sem stack de backend definida ainda —
o foco atual é mapear a estrutura do código existente antes de escrever specs.

## Contexto

O operador pediu a configuração do MCP codebase-memory-mcp (codegraph) para
auxiliar na engenharia reversa deste projeto.

- **Escopo de projeto confirmado pelo operador**: gravar a entrada MCP em
  `.opencode/opencode.json` DESTA pasta (não no config global) — o time pode
  compartilhar o projeto sem afetar outras ferramentas.
- O binário `codebase-memory-mcp.exe` já foi instalado e verificado nesta
  máquina em `C:\Users\victo\AppData\Local\Programs\cbm\codebase-memory-mcp.exe`
  (supply-chain conferida: SHA-256, attestation SLSA, Defender) — NÃO baixar
  novamente.
- O `install.ps1` que vem no zip da release NÃO foi executado e NÃO deve ser.

Configurar o MCP para este projeto.
