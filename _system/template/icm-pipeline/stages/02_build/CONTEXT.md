# Stage 02 — Build (contract)

Invoked via `/pipeline build <slug>`. Your job is **one thing**: implement the approved
spec on the run's branch, prove it with CI, and flip the PR draft → open. No requirement
gathering here — an ambiguous spec goes back to Define.

## Inputs (read only these)

- `.icm/_shared/stage-preamble.md` — run it **first**: resolve the run or STOP.
- `.icm/runs/<slug>/01_define/output/spec.md` — the whole brief.
- `.icm/_shared/github.md` — the gate read and hand-off mechanics.
- `.icm/_shared/ci.md` — what green means.
- The repo's own code conventions (its `CLAUDE.md` / conventions file), and only the
  source the spec's `touches:` implicates.

## Process

1. **Run the shared preamble**, then **read the gate**: **Spec approved** must be `[x]`
   in the PR body. Unticked → STOP and say so; you never tick it.
2. **Implement exactly the acceptance criteria** — no drive-bys, no scope creep. Work
   found that isn't this run's becomes a `.icm/intake/triage/` stub, parked in a minute.
   If the spec turns out ambiguous about *what* to build → STOP, back to Define.
3. **Write `.icm/runs/<slug>/02_build/output/notes.md`** (template below), commit run
   files with the code, push. **Never run local checks** — CI is the source of truth.
4. **Establish green:** `.icm/scripts/ci-status.sh <slug>` → `RESULT: GREEN`. `RED` is
   Build's to fix — read the failing job, fix, push, re-run the call. `PENDING` →
   re-run it; not-yet-red is not green.
5. **Hand off:** flip the PR draft → open. Tick nothing. Tell the owner what to test;
   their **Ready to merge** tick (after their own testing) is what lets Release run.

## Outputs

`.icm/runs/<slug>/02_build/output/notes.md`:

```md
# Build notes: <slug>

- commits: <short list>
- ci: GREEN on <sha>

## What changed

- <file/area>: <why>

## Acceptance criteria status

- [x] <criterion> — <how it's met>

## Notes for Release

- <anything the reviews should look at closely>
```

## Verify (before handing off)

- The gate was ticked before you started; you ticked nothing.
- Every criterion is either met (and says how) or flagged with why not — never silent.
- CI is a settled `GREEN` from `ci-status.sh` on your last push — never assumed.
- The diff contains only this run's work; everything else is a triage stub.
