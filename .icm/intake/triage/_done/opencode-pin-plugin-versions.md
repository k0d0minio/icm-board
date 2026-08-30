# Stub: Pin OpenCode plugin versions once they have proven themselves

- lane: chore
- found-by: opencode-buildout/plugins-and-quota, 2026-08-30
- priority: P2
- sources: report artifact §Phase 2 "Standing rule for all npm plugins"
  https://claude.ai/code/artifact/806e3001-9c27-40a3-be2f-851c050086f8

## Problem

`~/.config/opencode/opencode.json` carries `@tarquinen/opencode-dcp@latest`. Plugins
execute at startup with access to `~/.local/share/opencode/auth.json`, so `@latest` is
the supply-chain surface of the whole OpenCode setup: any future publish runs on
Jamie's box unreviewed. Stub `plugins-and-quota` deliberately deferred the pin until
the plugin had a week of clean behaviour rather than pinning a version nothing had
exercised — that week is up on **2026-09-06**.

The stub's other npm plugin, `opencode-quota`, no longer applies: it was dropped on
2026-08-30 (wrong package — see the stub in `opencode-buildout/_done/`), and budget
visibility comes from native `opencode stats`. So this is a one-line change.

## Change

Pin DCP to the exact version that has been running: `@tarquinen/opencode-dcp@3.1.15`
(resolved 2026-08-30, installed at `~/.cache/opencode/packages/`). Confirm the pinned
version still loads — DCP writes `~/.config/opencode/dcp.jsonc` on first startup, and
`opencode debug config` shows the resolved plugin array.

Treat any further plugin addition as one-in-one-out, pinned from the start.

Done when the global config names an exact DCP version and a session still starts
clean. Machine-only work, nothing committed.

## Prompt

On Jamie's machine, edit `~/.config/opencode/opencode.json` and change the plugin entry
`@tarquinen/opencode-dcp@latest` to the exact version `@tarquinen/opencode-dcp@3.1.15`
(verify that is still the version in `~/.cache/opencode/packages/` first; if it has
moved on, pin whatever has actually been running and say so). Plugins run at startup
with access to the credentials file, so `@latest` is the supply-chain risk being closed
here. Then confirm the config still resolves with `opencode debug config` and that the
plugin array lists the pinned DCP plus the local `plugins/notify.js`. Nothing is
committed to any repo — this file lives in `~/.config/opencode`, which is not a git
repository. When done, `git mv` this stub into `.icm/intake/triage/_done/`.
