# Stub: The template's intake contract still says "a ticket PR" in two places D39 retired

- feature-slug: intake-contract-ticket-pr-wording
- lane: tweak
- found-by: estate-sync-d39 (one-branch-two-targets, stub 4), 2026-09-24
- priority: P3
- size: S
- sources: `_system/template/icm-pipeline/intake/CONTEXT.md` (T) — line 42 "land it for the bug
  lane (a ticket PR)" and line 239 "in one commit on one ticket PR" · synced byte-identical into
  remi-ai #126, vinecliff #20, jamienisbet #153

## Problem

D39 §8 retired the ticket PR: ticket state reaches `main` by a direct commit
(`pr-conventions` → Ticket commits). Stub 1 reworded the template's contracts but two phrases
in `intake/CONTEXT.md` survived — the hotfix-candidate hand-off ("land it for the bug lane (a
ticket PR)") and `triage prune` ("in one commit on one ticket PR"). A session following them
would open a PR nothing merges. The file is template-owned, so every pipeline repo now carries
the stale words and none may edit them (D33).

## Proposed change

- Line 42 → "land it for the bug lane (a direct ticket commit to `main`)".
- Line 239 → "in one direct ticket commit to `main`, and nothing else".
- `grep -rn 'ticket PR' _system/template` afterwards shows only the history notes that name it as
  retired (`_shared/github.md` regime 3). Reaches the estate with the next `icm-sync.sh` pass.
