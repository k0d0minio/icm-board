# GitHub — the PR regime, gates, and mechanics (Layer 3 reference)

The scripts in `.icm/scripts/` own the mechanical projections (config from the
environment: `GITHUB_TOKEN`/`GH_TOKEN`; `GITHUB_REPO` overrides the `origin`-derived
owner/repo). Reads, content edits and merges go through whatever GitHub surface the
session has (the GitHub MCP where available, the API otherwise) — one narrow call per
question, never paging through comment threads or diffs you don't need.

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
- **Never subscribe to PR activity.** One push produces a pile of events and none of
  them is a verdict. The pipeline needs exactly two reads instead: the one blocking
  `ci-status.sh <slug>` call per push, and one review-comments read at Release.

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

## After the merge

Close-out is the merging session's last act, on `main`:
`git mv .icm/runs/<slug>/ .icm/runs/_done/<slug>/` (plus the epic archive when it
completed — the stage contracts say when), committed as `Wrap: close out <slug>` and
pushed. Live folders hold only live work — a merged run still sitting in `runs/` is the
alarm, not a state.
