# template — canonical scaffold + asset library for the estate

Two jobs in one folder, both consumed by `_system/scripts/icm-check.sh`:

1. **The baseline** `--fix` seeds when a repo is missing it (never overwrites).
2. **The canonical Claude-asset library** — the estate-wide hooks and skills every repo
   should carry. Seeded when missing; **drift is reported, never repaired** — repos own
   their copies (decision D7, [`.icm/project.md`](../../.icm/project.md), resolving the
   old open decisions on skills layering and hook strategy).

Sustentus-v2 is exempt (its `pipeline/` is authoritative).

```
icm/                             → copied to <repo>/.icm/
  intake/
    README.md                    ← micro-copy of contracts/TICKETS.md; {{PREFIX}} substituted
    _done/.gitkeep
  docs/.gitkeep                  ← ad hoc reports land here (estate convention)
claude/                          → copied to <repo>/.claude/
  settings.json                  ← clean policy: schema + secrets deny-list + hook wiring
  hooks/
    session-start.sh             ← the repo's own board greets every session
    wrap-reminder.sh             ← Stop hook: unpushed .icm changes block the stop once
  skills/
    ticket-craft/SKILL.md        ← the ticket contract as working knowledge
    pr-conventions/SKILL.md      ← branches, commits, CI-is-truth, no secrets
```

Rules:

- **Never overwrite.** The script only creates what's missing; existing files win. In a
  repo whose `settings.json` predates the hook wiring, the hook files are seeded but
  inert — the drift report says so, and wiring them is Jamie's per-repo call
  (`/icm-check` step 3 proposes it).
- **Drift is a report line, not a repair.** `icm-check.sh` compares each repo's copy of
  a canonical asset against this folder and warns on divergence. Deliberate divergence
  is fine — the repo wins — but it should be visible, not silent.
- **Prefix resolution** when creating `intake/README.md`: existing tickets in the repo
  → the known-prefix map in `icm-check.sh` → derived from the repo name (flagged as
  *suggested* — confirm before cutting the first ticket, numbers are never reused).
- Template edits here propagate only to repos fixed *after* the edit; the script never
  retro-syncs existing files. That is deliberate — repos own their copies, and the
  drift report is how divergence stays honest.
