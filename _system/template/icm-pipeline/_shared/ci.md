# CI — what green means (Layer 3 reference)

**CI is the source of truth. Never run local checks** — no build, lint, typecheck, test
or format. Push, and read the verdict back with one blocking call:

```bash
.icm/scripts/ci-status.sh <slug>          # or --pr <number>
```

| Verdict | Meaning | Exit |
|---|---|---|
| `RESULT: GREEN` | every blocking check and status **completed**, none failed — the only verdict a hand-off or merge may rest on | 0 |
| `RESULT: RED` | something blocking concluded in failure — read the failing job, fix, push, re-run the call | 3 |
| `RESULT: PENDING` | unsettled (or a required check never registered) — **not a pass**; re-run rather than assume | 4 |

The rules the script encodes:

- **Two surfaces.** A commit's health lives on GitHub Actions *check runs* **and**
  *commit statuses* (deploy providers land there). Reading only check runs is the
  classic mistake.
- **Newest attempt wins.** A re-run leaves both attempts on the SHA; the stale one is
  how a green PR reports RED forever. The script dedupes by name/context.
- **The head is re-read each pass.** A push landing mid-wait moves the SHA; a verdict
  about the old head is about code no longer on the branch.
- **Classification is by rule, not by list**: `Vercel Preview Comments` is noise; a
  check whose name ends `(advisory)` can never make the verdict RED; a status reading
  `Canceled by Ignored Build Step` is a *skipped* deploy, not a pass; **everything else
  is blocking by default** — a workflow added tomorrow blocks by default.
- **Required checks**: set `PIPELINE_REQUIRED_CHECKS` (newline/comma-separated check-run
  names) to this repo's own CI so a fresh push with no checks registered yet reads
  PENDING, never GREEN. Unset, the script still refuses GREEN while *zero* signals
  exist.
- **Not-yet-red is not green.** PENDING is a third value. Nothing merges or hands off
  on it.
