# Runs — one folder per unit of work in flight

`runs/<slug>/` is a run's working home: `run.md` (the pointer index — lane, stub,
branch, PR) plus each stage's `output/`. Spine runs carry
`01_define/output/spec.md` and `02_build/output/notes.md` (Release appends its
`## Release` record there); lane runs carry `lane/output/notes.md` instead.

```md
# Run: <slug>

- lane: feature            # or bug | tweak | chore
- stub: intake/<epic>/<slug>.md   # when spun from one
- branch: claude/<slug>    # recorded, not enforced — written by new-run.sh
- pr: #456                 # the ONE PR — written by new-run.sh
```

**Live folders hold only live work.** The session that merges a run moves it to
`runs/_done/<slug>/` in the same close-out commit (`stages/03_release/CONTEXT.md`); a
merged run still sitting here is the alarm that the close-out was missed. Runs are
tracked in git and ride the run's PR, so any device can resume them
(`.icm/_shared/stage-preamble.md`).
