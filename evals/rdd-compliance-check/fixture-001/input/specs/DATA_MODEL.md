# DATA_MODEL — VibeCut

## Tabela USUARIO

| Coluna | Tipo | Notas |
|---|---|---|
| ID | UUID | PK |
| EMAIL | VARCHAR(255) | dado pessoal — contato |
| ACEITE_VERSAO | VARCHAR(20) | versão do ToU/PP aceito (RN-001) |
| ACEITE_DATA | TIMESTAMP | timestamp do aceite (RN-001) |
| EXCLUIDO_EM | TIMESTAMP | data da exclusão definitiva (RN-002) |