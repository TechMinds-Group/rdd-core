// OpenCode plugin: jev-tool — tool `jev_classify` (modelo Jev, TypeSafe System One)
//
// Portado para a API de plugins V2 (OpenCode v2.x):
//   - export default Plugin.define({ id, setup(ctx) }) em vez de export nomeado
//   - tool registrada via ctx.tool.transform com input em JSON Schema
//   - credencial: variável de ambiente TYPESAFE_API_KEY (nunca logada)
//
// Consumidores: skill rdd-prompt-gate (qualificação de prompt via Jev) e qualquer
// skill que peça "classificar com jev".

import { Plugin } from "@opencode/plugin"

export default Plugin.define({
  id: "jev-tool",
  async setup(ctx) {
    await ctx.tool.transform((editor) => {
      editor.add({
        name: "jev_classify",
        description:
          "Classifica texto usando o modelo Jev (TypeSafe System One). Retorna JSON com respostas tipadas e probabilidades calibradas. Use para classificacao, roteamento, scoring de urgencia, e qualquer decisao que precise de probability-aware output.",
        input: {
          type: "object",
          properties: {
            text: {
              type: "string",
              description: "Texto ou estado para classificar",
            },
            questions: {
              type: "string",
              description:
                'JSON string com as perguntas no formato TypeSafe. Ex: {"urgencia": {"type": "noul"}, "categoria": {"type": "choice", "criteria": {"reclamacao": "Reclamacao", "duvida": "Duvida"}}}',
            },
          },
          required: ["text", "questions"],
          additionalProperties: false,
        },
        async execute(input, context) {
          const apiKey = process.env.TYPESAFE_API_KEY
          if (!apiKey) {
            throw new Error(
              "TYPESAFE_API_KEY environment variable not set. Get your key at https://console.typesafe.ai/keys",
            )
          }

          let questions
          try {
            questions = JSON.parse(input.questions)
          } catch (e) {
            throw new Error("Invalid questions JSON: " + e.message)
          }

          const response = await fetch("https://api.typesafe.ai/v1/systemone", {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
              Authorization: "Bearer " + apiKey,
            },
            body: JSON.stringify({
              state: input.text,
              model: "jev-latest",
              questions,
            }),
            signal: context.signal,
          })

          if (!response.ok) {
            const body = await response.text()
            throw new Error("Jev API error " + response.status + ": " + body)
          }

          return { content: JSON.stringify(await response.json(), null, 2) }
        },
      })
    })
  },
})
