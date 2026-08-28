# Lane — Chore (contract)

Invoked via `/pipeline chore "<task>"` — or `/pipeline chore <stub-name>` from a parked
`.icm/intake/triage/` stub. For work with **no behaviour change**: a refactor, a
dependency bump, a migration, config hygiene. No spec, one PR, one gate — **Ready to
merge**. If behaviour would change, it isn't a chore — STOP and route accordingly.

## Inputs (read only these)

- The task (argument / conversation / triage stub).
- The repo's own code conventions; only the areas the task names.
- `.icm/_shared/github.md` · `.icm/_shared/ci.md`.

## Process

1. **Pick a slug** (kebab-case) and state the invariant out loud — what must be true
   before and after. Do the work; the invariant bounds the diff.
2. **Write `.icm/runs/<slug>/lane/output/notes.md`** (template below), then:

   ```bash
   .icm/scripts/new-run.sh <slug> --lane chore --summary "<what and why, one line>" \
     [--stub .icm/intake/triage/<name>.md]
   ```

3. **Stop.** Merge only on **Ready to merge** `[x]` plus `ci-status.sh <slug>` →
   `GREEN` after the last push; squash once; close out (run folder → `runs/_done/`).

## Outputs

```md
# Chore: <slug>

- invariant: <behaviour unchanged; what differs>
- change: <file/area>: <what and why>
- rollback: <how this is undone if needed>
```

## Verify

- The invariant held — no behaviour change shipped.
- One PR, single gate, merged on tick + settled GREEN only; rollback stated.
