/**
 * OpenCode plugin: anti-idle-detector (IMP-085)
 *
 * Detecta loops de preenchimento do agente — sequências de chamadas bash
 * triviais (mesmo comando repetido, output descartável, sem efeito em disco)
 * — e interrompe a execução da chamada com um erro orientando o agente a
 * encerrar o turno com UMA pergunta agrupada ao operador.
 *
 * Instalação: ~/.config/opencode/plugins/anti-idle-detector.ts
 * (autodiscovery do diretório global de plugins — não requer
 *  entrada em opencode.jsonc)
 *
 * API: OpenCode V2 — Plugin.define({ id, setup(ctx) }) + ctx.tool.hook
 * ("execute.before"). A forma V1 (default export async retornando hooks)
 * não carrega no servidor V2 — ref err_f60fdb78.
 *
 * Critérios de "chamada trivial" (falso-positivo ~zero):
 *   - tool = bash
 *   - comando = echo / printf / Write-Output / Write-Host + literal curto
 *   - sem $variaveis, sem $( ), sem pipe, sem redireção, sem `;`/`&`
 * Intervenção: N chamadas idênticas consecutivas (THRESHOLD) → a N-ésima
 * falha com mensagem de sistema. O contador reinicia após a intervenção.
 */

import { Plugin } from "@opencode/plugin"

const THRESHOLD = 5

const TRIVIAL_RE =
  /^(write-output|write-host|echo|printf)\s+("([^"$`()]{0,80})"|'([^'$`()]{0,80})'|[^"$`();&|]{1,80})$/i

const BLOCK_RE = /[>|;&`]|\$\(|\b(out-file|set-content|add-content|tee-object)\b/i

interface SessionState {
  lastSignature: string | null
  count: number
}

const states = new Map<string, SessionState>()

function normalize(cmd: string): string {
  return cmd.trim().replace(/\s+/g, " ").replace(/;+\s*$/, "").trim()
}

function isTrivialEcho(cmd: string): boolean {
  const c = normalize(cmd)
  if (!c) return false
  if (BLOCK_RE.test(c)) return false
  return TRIVIAL_RE.test(c)
}

export default Plugin.define({
  id: "anti-idle-detector",
  async setup(ctx) {
    await ctx.tool.hook("execute.before", (event) => {
      const toolName = String(event?.tool ?? "")
      const key = String((event as { sessionID?: string } | undefined)?.sessionID ?? "default")

      if (toolName !== "bash") {
        states.delete(key) // qualquer tool real reinicia o contador
        return
      }

      const cmd = String((event?.input as { command?: string } | undefined)?.command ?? "")
      if (!isTrivialEcho(cmd)) {
        states.delete(key)
        return
      }

      const sig = normalize(cmd)
      const st = states.get(key) ?? { lastSignature: null, count: 0 }

      if (st.lastSignature === sig) {
        st.count += 1
      } else {
        st.lastSignature = sig
        st.count = 1
      }
      states.set(key, st)

      if (st.count >= THRESHOLD) {
        st.lastSignature = null
        st.count = 0
        throw new Error(
          `[anti-idle IMP-085] ${THRESHOLD}+ chamadas bash triviais consecutivas e idênticas detectadas (output descartável, sem efeito em disco). ` +
            `Este é um loop de preenchimento. REGRA: se restar apenas decisão do operador, emita UMA pergunta agrupada e ENCERRE o turno — ` +
            `responder no chat e parar é uma ação válida e completa. Nunca emita tool calls de preenchimento enquanto aguarda resposta.`,
        )
      }
    })
  },
})
