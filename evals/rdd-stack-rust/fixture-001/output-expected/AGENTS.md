# AGENTS — Motor.CORE

Instruções do agente para o repo Motor.CORE (Rust, actix-web, tokio, sqlx).

## Comandos

- Build: `cargo build`
- Testes: `cargo test`

## Qualidade (Rust)

- `cargo clippy -- -D warnings` com **zero warnings** antes de concluir.
- Em código async, usar `tokio::sync::Mutex` — `std::sync::Mutex` trava a
  thread do runtime (pitfall).
- Erro propagado via `Result<T, E>`: `thiserror` para domínio, `anyhow` para
  infra — sem `.unwrap()` em código de produção.
- `cargo test` e `cargo fmt --check` verdes antes de concluir.
