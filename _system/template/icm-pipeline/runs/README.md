# Runs — one folder per unit of work in flight

`runs/<slug>/` is a run's working home: `run.md` (the pointer index — lane, stub,
branch, PR), `usage.md` (one `- usage:` line per stage start and end, appended by
`usage-snapshot.sh`, never edited) plus each stage's `output/`. Spine runs carry
`02_define/output/spec.md` and `03_build/output/notes.md` (Release appends its
`## Release` record there); lane runs carry `lane/output/notes.md` instead — and, where
something failed on the way, an `error.log` beside it (each error and its fix;
`retrospective.sh` reads it at Release, and the archive keeps it so later runs can count what
recurs). A **front**
run — Scope — carries `01_scope/_source/story.md` and `01_scope/output/scope.md`, and
opens no PR of its own.

```md
# Run: <slug>

- lane: feature            # or front | bug | tweak | chore | hotfix | handover
- stub: intake/<epic>/<slug>.md   # when spun from one
- branch: claude/<slug>    # recorded, not enforced — written by new-run.sh
- pr: #456                 # the ONE PR — written by new-run.sh (a front has none)
```

**A run only ever writes inside its own folder, on its own branch** — that is what lets several
runs be in flight at once: each stage's working artifacts land under `runs/<slug>/<stage>/`, the
run is bound to `claude/<slug>`, and no two live runs share a working tree
(`.icm/_shared/stage-preamble.md` → Run-scoped isolation).

**Live folders hold only live work.** The session that merges a run moves it to
`runs/_done/<slug>/` — `.icm/scripts/close-out.sh <slug>`, run on the branch as the last
commit before the merge, so the squash publishes it (`stages/04_release/CONTEXT.md`). A
merged run still sitting here is the alarm that the close-out was missed. Runs are
tracked in git and ride the run's PR, so any device can resume them
(`.icm/_shared/stage-preamble.md`).
