# .icm — this repo's work layer

*The map of this folder. Every estate repo carries the one pipeline (`icm-check.sh --fix`
from the icm-board repo seeds what is missing); how much of it a repo leans on is the
`complexity` key in `.icm/project.json` — `standard`, or `micro` for a repo too small to
hold a knowledge map. There is no profile line to declare. Canonical
contracts: `_system/contracts/TICKETS.md` and `_system/contracts/PIPELINE.md` in the
icm-board estate; `intake/README.md` here is the self-contained micro-copy.*

## Layout

```
.icm/
  CONTEXT.md            ← this file
  project.md            ← what this project is for — written by /project, never by hand
  intake/               ← the work: epics + triage (see intake/README.md)
    <epic-slug>/          breakdown.md + one stub per unit of work + _done/
    triage/               parked one-off bug/tweak/chore stubs
    _done/                completed epics + the legacy archive
  docs/                 ← ad hoc reports, client words, runbooks
```

This folder also carries the pipeline — `project.json`, `stages/`, `lanes/`, `runs/`,
`_shared/`, `scripts/`, `raw/` + `processed/` for material a client sends, `output/` for
the reports the scripts compile (`client-status.sh` → `client-status-latest.md`, the
client's view), and `uat/` where `/setup` declared a persistent client UAT environment
(the contract and the batch) — each seeded file documents itself, and
`.claude/skills/pipeline/SKILL.md` routes between them.

## The rules that travel with this folder

- **Identity is the path** — a ticket is `<epic-slug>/<feature-slug>`; no numbers.
- **Status is positional** — where a file sits is its state; `git mv` to `_done/` is
  "done". Nothing is deleted; dropped work carries a `> Dropped: <reason, date>` line.
- **Planning lives here** — never a loose `TODO.md` or `BACKLOG.md` at the root.
- **The board reads `main`** — an unpushed stub does not exist.
