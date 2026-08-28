# Lane — Tweak (contract)

Invoked via `/pipeline tweak "<change>"` — or `/pipeline tweak <stub-name>` from a
parked `.icm/intake/triage/` stub. For a **tiny, fully-specified adjustment**: copy, a
default, spacing, a label. No spec, one small PR, one gate — **Ready to merge**. The
moment it needs a decision nobody has made, it isn't a tweak — STOP and route to the
spine.

## Inputs (read only these)

- The requested change (argument / conversation / triage stub).
- The repo's own code conventions; only the files the change names.
- `.icm/_shared/github.md` · `.icm/_shared/ci.md`.

## Process

1. **Pick a slug** (kebab-case) and make the change — minimal diff, exactly what was
   asked, nothing else. Anything adjacent → a triage stub.
2. **Write `.icm/runs/<slug>/lane/output/notes.md`** (template below), then:

   ```bash
   .icm/scripts/new-run.sh <slug> --lane tweak --summary "<before → after, one line>" \
     [--stub .icm/intake/triage/<name>.md]
   ```

3. **Stop.** Merge only on **Ready to merge** `[x]` plus `ci-status.sh <slug>` →
   `GREEN` after the last push; squash once; close out (run folder → `runs/_done/`).

## Outputs

```md
# Tweak: <slug>

- change: <file/area>: <before → after, one line>
```

## Verify

- The diff is as small as the request; nothing rode along.
- One PR, single gate, merged on tick + settled GREEN only.
