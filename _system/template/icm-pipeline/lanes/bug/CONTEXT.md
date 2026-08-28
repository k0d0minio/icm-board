# Lane — Bug (contract)

Invoked via `/pipeline bug "<what's broken>"` — or `/pipeline bug <stub-name>` to start
from a parked finding in `.icm/intake/triage/` (the stub pre-seeds the report below and
`new-run.sh --stub` moves it to `triage/_done/`). A fast lane, not the spine: no spec,
no Spec-approved gate. One PR, one gate — **Ready to merge**. If the "bug" turns out to
need product decisions or touches more than it fixes, STOP and route to the spine
(`/pipeline new`) instead.

## Inputs (read only these)

- The report (the argument / conversation), or the triage stub — and the reproduction
  it leads you to.
- The repo's own code conventions; only the source files the reproduction implicates.
- `.icm/_shared/github.md` — the lane-PR regime (single gate) and merge mechanics.
- `.icm/_shared/ci.md` — what green means; the merge gates on it.

## Process

1. **Pick a slug** (`fix-<what>`, kebab-case) and **reproduce first**. State observed vs
   expected in one line each. Can't reproduce → STOP and report what you tried; don't
   fix blind.
2. **Fix the cause, not the symptom** — minimal diff, no drive-by refactors. Anything
   found that isn't this fix → a triage stub.
3. **Write `.icm/runs/<slug>/lane/output/notes.md`** (template below), then open the
   lane PR:

   ```bash
   .icm/scripts/new-run.sh <slug> --lane bug --summary "<what was broken → what's true now>" \
     [--stub .icm/intake/triage/<name>.md]
   ```

   It commits the run, pushes, and opens a ready (non-draft) PR whose body carries
   **only** the Ready-to-merge gate.
4. **Stop.** CI verifies (never run local checks). Merging is gated twice: **Ready to
   merge** `[x]` (you read it, never tick it) **and** `ci-status.sh <slug>` →
   `RESULT: GREEN` on the head you're about to merge, established after the last push.
   Then squash-merge once, and close out as Release does (run folder → `runs/_done/`;
   a consumed triage stub is already in `triage/_done/`).

## Outputs

`.icm/runs/<slug>/run.md` (with `- lane: bug`) and `.icm/runs/<slug>/lane/output/notes.md`:

```md
# Bug: <slug>

- observed: <what happened> · expected: <what should happen>
- cause: <one line — the actual defect>
- fix: <file/area>: <what changed>
```

## Verify

- The reproduction is recorded and the fix addresses its cause; the diff is minimal.
- One PR, no Spec-approved anchor; merged only on the ticked box **and** a settled
  `GREEN` you established after your own last push.
- Anything that grew beyond a fix was STOPped to the spine — or parked in triage —
  never absorbed here.
