# Stage 03 — Release (contract)

Invoked via `/pipeline release <slug>`. One stage, one human decision: by the time this
runs, the owner has tested the change and ticked **Ready to merge** — that tick attests
all manual testing, so this stage never re-asks for it. Your job: confirm the factory
agrees (CI green), run the review pass, park anything off-ticket, and squash-merge.

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
- `.icm/runs/<slug>/run.md` · `01_define/output/spec.md` · `02_build/output/notes.md`.
- The branch diff (`git diff main...HEAD`) — what the review runs against.
- `.icm/_shared/github.md` — gate read, merge mechanics, the no-subscriptions rule.
- `.icm/_shared/ci.md` — what green means.

## Process

1. **Run the shared preamble**, then confirm Build finished: `notes.md` exists and the
   PR is open (not draft). A criterion Build flagged unmet → back to
   `/pipeline build <slug>`; don't release known-broken work.
2. **Read the gate.** **Ready to merge** must be `[x]`. Unticked → **STOP** and say so —
   this is the stage's one stop-and-wait, and you never tick it.
3. **Establish CI green:** `.icm/scripts/ci-status.sh <slug>` → `GREEN`. `RED` → fix on
   the branch if it's this run's, else back to Build. `PENDING` → re-run the call.
4. **Review pass:** run `/code-review` at the spec's complexity (`trivial → low`,
   `standard → medium`, `complex → high`), then triage every finding by the rule above —
   trivial and in-run → fix now; the two stop classes → STOP and report; everything
   else → one triage stub, and move on. Never widen the PR.
5. **Append the `## Release` record to `notes.md`** (template below), commit, push, then
   **re-run `ci-status.sh <slug>` on the head you just pushed** — the last settled
   verdict is the one that authorises the merge.
6. **Merge.** Re-read the gate (it must still be `[x]`), then squash-merge, attempted
   **once**. Never on RED, never on PENDING.
7. **Close out.** On `main`: `git mv .icm/runs/<slug>/ .icm/runs/_done/<slug>/`; if that
   emptied the stub's epic (every stub in `_done/`, every sibling run merged),
   `git mv .icm/intake/<epic>/ .icm/intake/_done/<epic>/`. Commit both as
   `Wrap: close out <slug>` and push. Report: what merged (SHA), what was parked (by
   stub name).

## Outputs

Appended to `.icm/runs/<slug>/02_build/output/notes.md`:

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
- The run folder moved to `runs/_done/`, and the epic archived if it completed.
