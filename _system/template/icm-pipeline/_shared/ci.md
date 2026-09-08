# CI — what green means (Layer 3 reference)

The single home for **reading the factory's verdict**. Build, Release and every lane gate
on CI; the stage contracts point here rather than restating check names, because check
names change and a copy would rot.

The rule the whole file exists to enforce: **a stage never merges, hands off, or declares
done on a verdict it did not actually establish.** Not-yet-red is not green.

**CI is the source of truth. Never run local checks** — no build, lint, typecheck, test
or format. Push, and read the verdict back.

## One blocking call — never a model-driven poll

```bash
.icm/scripts/ci-status.sh <slug>          # or --pr <number>
```

It resolves the PR's head SHA, reads **both** surfaces, discards the known noise, waits for
the run to settle, and prints one verdict line. **The waiting happens inside the script's
own loop, so it costs wall-clock rather than model turns** — which is why "wait for CI" is
not in tension with "don't burn context polling". Read its `RESULT:` line and act:

| `RESULT:` | exit | Obligation |
|---|---|---|
| `GREEN` | 0 | Proceed. Every blocking check and status **completed**, none failed. This is the only verdict a hand-off or merge may rest on. |
| `RED` | 3 | **STOP.** Read the failing job's logs, fix on the branch, push, then re-run this call — a fresh push means a fresh verdict. Never merge, never hand off. |
| `PENDING` | 4 | The wait timed out unsettled, or a required check never registered. **STOP and say so**; re-run the call rather than guessing. A required check that never appeared is a broken workflow, not a pass. |

**Re-running the call after a push is not polling.** The rule this used to be written as —
"check once, no polling" — was aimed at burning model turns on `sleep`-and-re-read loops,
and it got read as "one glance is enough". One glance at an unsettled run is worth nothing.
The rule is **one settled verdict per push**, obtained by the one call above: push, call,
act; push again, call again.

`--no-wait` exists for **reporting** state, never for gating on it. It prints what the run
looks like at that instant, and an unsettled run is reported `PENDING` — never rounded to
green because nothing has failed yet.

## PENDING is a verdict, not a soft green

It is the value a pipeline keeps losing. It is not a reason to proceed "since nothing has
failed" — it means the factory has not answered. **Zero checks on a freshly pushed commit
is PENDING, not GREEN**: GitHub takes 10–30 seconds to register a workflow, so a stage
that reads the moment after `git push` reads an empty list and, without this rule, calls
it clean.

Set `PIPELINE_REQUIRED_CHECKS` (newline/comma-separated check-run names) to this repo's own
blocking checks, so a head missing them can never settle GREEN. Unset, the script still
refuses GREEN while *zero* signals exist.

## The rules the script encodes

- **Two surfaces.** A commit's health lives on GitHub Actions *check runs* **and**
  *commit statuses* (deploy providers land there). Reading only check runs is the
  classic mistake: a PR whose preview failed to compile still shows every check run
  green.
- **Newest attempt wins.** A re-run leaves both attempts on the SHA; the stale one is
  how a green PR reports RED forever. The script dedupes by name/context.
- **The head is re-read each pass.** A push landing mid-wait moves the SHA; a verdict
  about the old head is about code no longer on the branch.
- **Classification is by rule, not by list**: `Vercel Preview Comments` — a zero-second,
  always-success marker that the deploy bot is wired up, carrying no information about
  whether anything compiled — is noise; a check whose name ends `(advisory)` can never
  make the verdict RED; a status reading `Canceled by Ignored Build Step` is a *skipped*
  deploy, not a pass; **everything else is blocking by default** — a workflow added
  tomorrow blocks by default. Don't "recognise" an unfamiliar check as skippable.
- **An absent deploy is not a passed one.** A deploy target the diff never touched
  produces no status at all, and one cancelled by an ignore step produces a `success`
  that carries no build. Neither is a preview anything can be smoked against; quoting
  either as "the previews are green" is a false claim. Test against the URL of a target
  that **actually built**.

## Webhook events — sessions don't listen at all

**No PR in this repository is subscribed to PR activity** (`.icm/_shared/github.md` § PR
events): a single push produces a dozen-plus events — each deploy target going `pending`
then `success`, the deploy provider's bot posting and then re-editing its table, every
Actions job starting and finishing — and each one costs a full turn without carrying a
verdict. The one blocking call above, once per push, replaces the whole stream. Anything
longer-running is a **scheduled check-in** — one timed wake that reads state once and
re-arms — never a subscription. A session that finds itself subscribed unsubscribes and
says so; watching a PR event-by-event is a deliberate, human-requested act only.

Should a stray event still arrive — a requested watch, a race before the unsubscribe
landed — these hold:

- **Never act on a deploy-provider event.** Deployment-status events, the deploy bot's
  comment and its edits, and the marker check that only says those comments are wired up
  are all pure noise. Reading a deploy failure out of an event is fine — but establish it
  with the one call above before you touch anything.
- **Never act on a partial picture; one response per settled run, not one per event.** A
  burst of events from a single push is a single occurrence — the response is
  `ci-status.sh`, not a fix for the one job that happened to report first.
- **Advisory jobs never warrant a push.** Fix what they flag when you are already editing
  the run's files; a failing advisory job on its own is not a reason to touch the branch.
- **Your own pushes come back as events.** The stream echoes what you just did — that is
  not a new instruction.
