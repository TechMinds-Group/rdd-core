import { spawnSync } from "node:child_process"
import { Plugin } from "@opencode/plugin"

// RTK OpenCode plugin — rewrites commands to use rtk for token savings (V2 plugin API).
// Requires: rtk >= 0.23.0 in PATH.
//
// This is a thin delegating plugin: all rewrite logic lives in `rtk rewrite`,
// which is the single source of truth (src/discover/registry.rs).
// To add or change rewrite rules, edit the Rust registry — not this file.

export default Plugin.define({
  id: "rtk",
  async setup(ctx) {
    const probe = spawnSync("rtk", ["--version"], { encoding: "utf8" })
    if (probe.error || probe.status !== 0) {
      console.warn("[rtk] rtk binary not found in PATH — plugin disabled")
      return
    }

    await ctx.tool.hook("execute.before", (event) => {
      const tool = String(event?.tool ?? "").toLowerCase()
      if (tool !== "bash" && tool !== "shell") return
      const args = event.input as Record<string, unknown> | undefined
      if (!args || typeof args !== "object") return

      const command = args.command
      if (typeof command !== "string" || !command) return

      try {
        const result = spawnSync("rtk", ["rewrite", command], {
          encoding: "utf8",
        })
        const rewritten = (result.stdout ?? "").trim()
        if (!result.error && rewritten && rewritten !== command) {
          args.command = rewritten
        }
      } catch {
        // rtk rewrite failed — pass through unchanged
      }
    })
  },
})
