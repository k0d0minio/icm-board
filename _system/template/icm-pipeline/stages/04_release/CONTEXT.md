# Stage 04 — Release (contract)

Invoked via `/pipeline release <slug>`. One stage, one human decision: by the time this
runs, Build has flipped the PR ready, CI has settled on that head, and the owner has
smoke-tested the change by hand and ticked **Ready to merge** — that tick attests all
manual testing, so this stage never re-asks for it. Your job: confirm the factory agrees
(CI green), run the review pass, park anything off-ticket, put the close-out on the
branch, and squash-merge.

**What may stop the merge — nothing else may:**

1. A **blocking CI failure** (`RESULT: RED`, or a `PENDING` that will not settle).
2. A **security-critical finding introduced by this diff** — an exploitable defect.
3. A **deploy-breaking config finding** — a missing env var, a migration without a
   working down, config the deploy target doesn't carry.

Every other finding — style, structure, "should be refactored", anything not this
run's — is **parked as a stub in `.icm/intake/triage/`** and the merge proceeds. A
ticked box plus a green factory is the authorisation; do not manufacture reasons to
hold it.

## Inputs (read only these)

- `.icm/_shared/stage-preamble.md` — run it **first**: resolve the run or STOP.
- `.icm/runs/<slug>/run.md` · `02_define/output/spec.md` · `03_build/output/notes.md`.
- The branch diff (`git diff main...HEAD`) — what the review runs against.
- `.icm/_shared/github.md` — gate read, merge mechanics, the no-subscriptions rule.
- `.icm/_shared/ci.md` — what green means.

## Process

1. **Run the shared preamble**, then confirm Build finished: `notes.md` exists and the
   PR is open (not draft). A criterion Build flagged unmet → back to
   `/pipeline build <slug>`; don't release known-broken work.
2. **Read the gate.** **Ready to merge** must be `[x]`. Unticked → **STOP** and say so —
   this is the stage's one stop-and-wait, and you never tick it. The tick means the
   change was tested by hand; anything that had failed that testing would have gone back
   to Build instead.
3. **Establish CI green:** `.icm/scripts/ci-status.sh <slug>` → `GREEN`. `RED` → fix on
   the branch if it's this run's, else back to Build. `PENDING` → re-run the call.
4. **Review pass:** run `/code-review` at the spec's complexity (`trivial → low`,
   `standard → medium`, `complex → high`), then triage every finding by the rule above —
   trivial and in-run → fix now; the two stop classes → STOP and report; everything
   else → one triage stub, and move on. Never widen the PR.
5. **Append the `## Release` record to `notes.md`** (template below) and commit it.
   **Then close the run out, on the branch, as the last commit before the merge:**

   ```bash
   .icm/scripts/close-out.sh <slug>
   ```

   It `git mv`s `.icm/runs/<slug>/` into `.icm/runs/_done/` — and the intake epic into
   `.icm/intake/_done/` with it, if this stub was the last one it had left unshipped (and
   the front run that cut the epic, if one is still live) — and commits that on the
   branch. `RESULT: CLOSED` → carry on. `RESULT: STOP` → read the reason and fix it; do
   not merge a run you could not close out.

   The archive move rides in the run's own PR so **the squash-merge is what publishes
   it**, and nothing has to run afterwards to finish the job. A close-out pushed to
   `main` after the merge is the shape that breaks: a branch protected by required status
   checks refuses a direct push, and the archive commit strands on a branch nobody
   merges. The move is the last thing written because the record it archives has to be
   complete first.

   Push everything, then **re-run `ci-status.sh <slug>` on the head you just pushed** —
   one settled verdict per push, and the last one is the verdict that authorises the
   merge.
6. **Merge.** Re-read the gate (it must still be `[x]`), then squash-merge, attempted
   **once**. Never on RED, never on PENDING. The squash carries the run record, the
   review record **and the archive move** onto `main`.
7. **Report.** What merged (SHA), what was parked in triage (by stub name), and that the
   run is archived. Touch nothing after the merge but the PR body's spec link, repointed
   to its `blob/main/` form.

## Outputs

Appended to `.icm/runs/<slug>/03_build/output/notes.md`:

```md
## Release

- gate: Ready to merge ticked — merge authorised
- ci: GREEN on <sha> (ci-status.sh, after the last push)
- reviews: code <effort> — <result>
- parked: <triage stub filename(s) | none>
```

## Verify (before declaring released)

- The gate was ticked **before** the merge and re-read after the last push; you never
  ticked it. Merged once, on a settled `GREEN` established after your own last push.
- The only holds you applied were the three stop classes; every other finding is a named
  triage stub.
- `close-out.sh` ran on the branch and reported `CLOSED`, and its commit was pushed and
  included in the head that merged — a merge without it leaves the run in `.icm/runs/`,
  which is the alarm that the close-out was missed.
