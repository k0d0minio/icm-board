# .icm — this repo's work layer

*The map of this folder. There is one pipeline for every adopted repo and nothing to
declare here (D22); what varies is `complexity` in a repo's `.icm/project.json`. This
repo holds no application code and carries no run spine of its own — its `.icm/` is the
register and the backlog, held to the same baseline it enforces. Canonical contracts:
`_system/contracts/TICKETS.md` and `_system/contracts/PIPELINE.md`; `intake/README.md`
here is the self-contained micro-copy.*

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

In an adopted repo this folder also carries `stages/`, `lanes/`, `runs/`, `_shared/`,
`scripts/` and the `MANIFEST` — each seeded file documents itself, and
`.claude/skills/pipeline/SKILL.md` routes between them. Not here: icm-board ships no
product and runs no pipeline of its own.

## The rules that travel with this folder

- **Identity is the path** — a ticket is `<epic-slug>/<feature-slug>`; no numbers.
- **Status is positional** — where a file sits is its state; `git mv` to `_done/` is
  "done". Nothing is deleted; dropped work carries a `> Dropped: <reason, date>` line.
- **Planning lives here** — never a loose `TODO.md` or `BACKLOG.md` at the root.
- **The board reads `main`** — an unpushed stub does not exist.
