# ICM-017 · Wire the estate Stop hook and give it a closure question

| | |
|---|---|
| Status | in-progress |
| Type | automation |
| Priority | P2 |
| Size | M |

## Problem

Two faults stack into one hole: **work merges and the ticket stays open.**

1. **The hook is inert almost everywhere.** `wrap-reminder.sh` is on disk in 22 repos
   and registered in `.claude/settings.json` in exactly one (`the-library`). That is
   **42 of `icm-check.sh`'s 76 warnings** — already reported for weeks, never acted on.
   The cause is structural, not neglect: `--fix` seeds a missing *file* and never
   overwrites an existing one, and every repo already had a `settings.json` (the
   permissions stub), so the hooks block was never added. The hook files were missing,
   so they got seeded; the wiring was not a file, so it did not.
2. **Even where it runs, it cannot catch this.** The hook fires only on *uncommitted*
   changes under `.icm/`. A session that ships work and never touches the ticket leaves
   a clean tree and passes silently — which is precisely the `JN-030` case.

The rule itself is not missing. The canonical `pr-conventions` skill, seeded estate-wide,
already says: "The PR that finishes a ticket's work moves the ticket file to
`.icm/intake/_done/`." Nothing has ever verified it. PR #8 in this repo is a worked
example — it did the work, never touched `ICM-003`, and merged green.

## Build

- Extend the canonical `_system/template/claude/hooks/wrap-reminder.sh` with a second
  question, asked at session end when the first (dirty `.icm/`) does not fire: if this
  branch has commits that changed files **outside** `.icm/` and name a ticket still
  sitting in `.icm/intake/`, **and no commit on the branch touched that ticket file**,
  block once and ask. The final clause is what keeps it quiet — a session that flipped
  `Status` to `in-progress` has engaged with the ticket and is not nagged.
- Give icm-board its own copy at `_system/hooks/wrap-reminder.sh` and register the
  `Stop` hook in its `.claude/settings.json`. This repo is held to its own baseline.
- Hand-merge into the 21 repos that carry the file and do not register it — **one commit
  per repo, Jamie approves the list first.** Each commit is two files, because wiring
  alone would only activate the *old* hook: the updated `.claude/hooks/wrap-reminder.sh`
  (which `icm-check` now reports as drift in all 22 repos, correctly) and the `hooks`
  block in `.claude/settings.json`. Not a bulk sync: `--fix` still refuses to overwrite
  an existing file, and that contract stays exactly as it is.

The hook **asks**; it never moves a ticket. Gates are human checkboxes.

## Acceptance

- [ ] A session that commits work naming an open ticket, without touching the ticket
      file, is asked about it once at session end
- [ ] A session that touched the ticket file, or that only changed `.icm/`, is not asked
- [ ] `wrap-reminder.sh` still honours `stop_hook_active` and stays silent on any error
- [ ] The 21 unwired repos register the hook, one reviewed commit each
- [ ] `icm-check.sh` reports zero `inert` warnings for `wrap-reminder.sh`

## Prompt

Close the ticket-closure hole in the Apps estate. Read
`.icm/intake/ICM-017-wire-stop-hook-closure.md` for full context. Extend the canonical
Stop hook `_system/template/claude/hooks/wrap-reminder.sh` so that, when the working tree
has no uncommitted `.icm/` changes, it checks whether this branch has commits that
changed files outside `.icm/` and name a ticket still in `.icm/intake/` while no commit
on the branch touched that ticket's file — and if so blocks once with a question. It must
honour `stop_hook_active`, exit 0 silently on any error or missing `origin/main`, and
never move a ticket itself. Add the same hook to icm-board at `_system/hooks/` and
register `Stop` in its `.claude/settings.json`. Then wire the 21 estate repos that carry
the hook file without registering it — one commit per repo, and show Jamie the list for
approval before writing anything. Client repos live in `projects/` on this machine only.
Estate script and template changes go through a PR on a `claude/` branch. Do not run
local checks — CI is the source of truth.
