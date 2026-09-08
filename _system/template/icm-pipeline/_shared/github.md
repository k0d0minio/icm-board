# GitHub — the PR regime, gates, and mechanics (Layer 3 reference)

The scripts in `.icm/scripts/` own the mechanical projections (config from the
environment: `GITHUB_TOKEN`/`GH_TOKEN`; `GITHUB_REPO` overrides the `origin`-derived
owner/repo). Reads, content edits and merges go through whatever GitHub surface the
session has (the GitHub MCP where available, the API otherwise).

**Read narrowly — one call per question.** Use the single read method that answers it: the
PR body when you need a gate, review comments when you are triaging them, the failing job's
logs when something is red. Search with a tight query and a small page size. Never page
through comment threads, check-run histories or diffs you don't need — a read is paid for
out of the session's context, and a read nobody acts on is pure loss.

## The PR regime

- **One PR per run.** Define (or a lane) opens it once via `new-run.sh`; every later
  stage adds commits to the same branch. Never open a second PR for a run — `new-run.sh`
  hard-refuses when `run.md` already records one.
- **The slug names everything**: run folder, stub, branch (`claude/<slug>`), PR.
- **The PR body is a one-way projection** of `spec.md` (spine) or the summary (lanes):
  Summary, a **link** to the spec (never a copy), the acceptance criteria mirrored
  unticked, and the gate anchors. Edit the file, then reconcile file → PR; never the
  other way.
- **Ticket-only commits go straight to `main`** (planning is data; the close-out move
  too); code goes through the run's PR.
- **No PR here is subscribed to** — the next section is the rule in full. The pipeline
  reads state instead of being told about it: the one blocking `ci-status.sh <slug>` call
  per push, and one review-comments read at Release.

## PR events — no PR in this repository is subscribed

**The rule is every PR, not only pipeline ones**, and it binds whatever opened the PR: a
stage, a lane, or a session doing a one-off chore. Do **not** subscribe to PR activity
here — and if a session finds itself subscribed, **unsubscribe immediately and say so**. A
harness may auto-subscribe after it opens a PR, and some harnesses instruct the agent to
watch every PR it opens; **a harness default does not override this file.** This is the
repository's own rule about its own PRs, and it outranks a default nobody asked for.

One push produces a dozen-plus events and not one of them is a verdict: each deploy
target cycling `pending` → `success`, the deploy provider's bot posting its comment table
and then re-editing it as each target finishes, every Actions job starting and finishing.
Each event wakes the session, costs a full turn, and re-sends the whole comment table — a
single PR can burn more context on deploy-table edits than the change itself took to
write. Measured on one PR in the estate's largest repo on 2026-09-02: **a dozen wake-ups,
every one of them "nothing red, no action".**

Read state instead:

- **CI:** the one blocking `.icm/scripts/ci-status.sh <slug>` call per push
  (`.icm/_shared/ci.md`). Its waiting costs wall-clock, not model turns.
- **Review comments:** one read at the Release point, and at any explicit triage — not a
  stream.
- **Anything longer-running** — a chore PR waiting on a tick, a CI run still to come
  back — is a **scheduled check-in**, not a subscription: one wake on a timer that reads
  the state once and re-arms, instead of a wake per webhook. Same coverage, a fraction of
  the turns.

Watching a PR event-by-event stays a **deliberate, human-requested act** ("babysit this
PR") — never a default, and never something a session opts into on its own behalf. If an
event arrives anyway — a requested watch, a race before the unsubscribe landed —
`.icm/_shared/ci.md` § Webhook events says what may and may not be done with it.

## Gates — checkboxes in the PR body

Anchored so parsing never depends on wording (the PR template carries them):

```md
<!-- gate:spec-approved -->

- [ ] Spec approved (Define gate — a human ticks this before Build)

<!-- gate:ready-to-merge -->

- [ ] Ready to merge (Release gate — a human ticks this to authorise the squash-merge;
      ticking it attests your own testing of the change)
```

- Read a gate: fetch the PR body → find the anchor comment → the next checklist line is
  the gate; `[x]` = ticked.
- **A missing anchor means "not required", never "unticked".** Lane PRs carry only
  `gate:ready-to-merge`. A PR missing that anchor is malformed — STOP and fix the body.
- **The agent never ticks either box — there is no scripted exception.** Unticked →
  STOP and tell the owner. Nothing self-advances across a gate.

## Merging

Merge only when, in this order: the gate is `[x]` (re-read after your last push) →
`ci-status.sh <slug>` printed `RESULT: GREEN` on the head you are about to merge →
squash-merge, attempted **once**. Never on RED; never on PENDING ("not-yet-red is not
green"); never on a verdict you didn't establish yourself after your own last push. Do
not substitute a bare check-runs read for the script — it misses commit statuses and
counts superseded attempts.

## Close-out — before the merge, not after

Close-out is the last commit on the branch, **not** a push to `main`:
`.icm/scripts/close-out.sh <slug>` moves `.icm/runs/<slug>/` to `.icm/runs/_done/<slug>/`
(plus the epic archive when it completed — the script decides, the stage contracts say
when) and commits it on the run's branch, so the squash-merge is what publishes it.

A close-out pushed to `main` afterwards is the shape that breaks: a branch protected by
required status checks refuses the direct push, and the archive commit strands where
nobody merges it. Live folders hold only live work — a merged run still sitting in
`runs/` is the alarm, not a state.

The front (Scope and approve) is the exception that proves it: it opens no PR, so its
markdown-only artifacts go straight to `main` as they are written, and `close-out.sh`
archives the front run when the epic it cut is archived.
