// icm-session-env.js — hands the running OpenCode session's id to the shell, so
// .icm/scripts/usage-snapshot.sh can read its own numbers from ~/.local/share/opencode/opencode.db.
//
// The binary exports no session variable of its own (verified on 1.18.30: the OPENCODE_* set has
// none). The plugin API provides it: `shell.env(input: {cwd, sessionID?, callID?}, output: {env})`
// carries sessionID on 1.18.x (@opencode-ai/plugin index.d.ts); `tool.execute.before` always does
// — kept as the fallback. Canonical root asset (optional): a repo that wants it seeded carries it
// at .opencode/plugins/; Jamie's machine carries the same file in ~/.config/opencode/plugins/.
// It reads nothing, writes nothing, and calls nothing — one environment variable, per shell.
let last = ""
export const IcmSessionEnv = async () => ({
  "tool.execute.before": async (input) => { if (input && input.sessionID) last = input.sessionID },
  "shell.env": async (input, output) => {
    const id = (input && input.sessionID) || last
    if (id && output && output.env) output.env.OPENCODE_SESSION_ID = id
  },
})
