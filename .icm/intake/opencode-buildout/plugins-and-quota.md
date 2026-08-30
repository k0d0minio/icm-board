# Stub: Plugins — quota tracking, context pruning, hand-rolled notify

- feature-slug: plugins-and-quota
- epic: opencode-buildout
- priority: P1
- size: S
- depends-on: global-core-config
- sequence: 2 of 5
- sources: report artifact §Phase 2
  https://claude.ai/code/artifact/806e3001-9c27-40a3-be2f-851c050086f8

## Problem

The €20–50/mo budget posture needs spend visibility and token hygiene, and Jamie
wants desktop notifications when sessions finish or stall — without the OCX
registry the popular notify plugin requires.

## Change

1. Confirm `opencode-quota` and `@tarquinen/opencode-dcp` (already in the stub-1
   plugin array) load cleanly on startup — quota toasts appear, DCP logs pruning.
2. Write `~/.config/opencode/plugins/notify.js` — the ten-line `notify-send`
   plugin from the report (session.idle, permission.asked, session.error).
   Verify against current plugin API docs if it doesn't fire; the API moves fast.
3. After a week of clean behavior: pin both npm plugins to exact versions in
   opencode.json (`@latest` is the supply-chain surface — plugins execute at
   startup with credentials).

Done when a finished session pops a desktop notification and quota toasts show
per-session spend.

## Prompt

Read `.icm/intake/opencode-buildout/plugins-and-quota.md` in this repo and the
report artifact it cites (Phase 2). Verify the two npm plugins load in OpenCode,
write the notify-send plugin file, and test all three. Machine-only work, nothing
committed. If the plugin API has drifted from the report's snippet, fix against
https://opencode.ai/docs/plugins rather than forcing the snippet.
