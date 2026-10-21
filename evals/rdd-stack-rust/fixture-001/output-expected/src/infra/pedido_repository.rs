use anyhow::Result;
use tokio::sync::Mutex;

pub struct PedidoRepository {
    // corrigido: Mutex assíncrono — não trava a thread do runtime tokio
    cache: Mutex<Vec<String>>,
}

impl PedidoRepository {
    pub fn novo() -> Self {
        Self {
            cache: Mutex::new(Vec::new()),
        }
    }

    // erro propagado via Result com anyhow (camada infra)
    pub async fn listar(&self) -> Result<Vec<String>> {
        let cache = self.cache.lock().await.clone();
        Ok(cache)
    }
}
