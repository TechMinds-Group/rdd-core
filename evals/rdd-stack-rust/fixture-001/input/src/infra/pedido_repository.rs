use std::sync::Mutex;

pub struct PedidoRepository {
    // pitfall: Mutex síncrono em contexto async — segura a thread do runtime
    cache: Mutex<Vec<String>>,
}

impl PedidoRepository {
    pub fn novo() -> Self {
        Self {
            cache: Mutex::new(Vec::new()),
        }
    }

    pub fn listar(&self) -> Vec<String> {
        // pânico em produção via unwrap — deveria propagar erro
        self.cache.lock().unwrap().clone()
    }
}
