# The estate pipeline — profiles, spine, gates

*The contract for the templated, per-repo SDLC pipeline — extracted from the sustentus
`.icm/` (the reference implementation, which stays exempt and authoritative for itself)
and seeded from [`_system/template/`](../template/README.md). Companions:
[TICKETS.md](TICKETS.md) (the intake layer every profile shares) ·
[PROJECT.md](PROJECT.md) (the register). Decisions D10–D12,
[`.icm/project.md`](../../.icm/project.md).*

Every repo declares **one profile** in its `.icm/CONTEXT.md` (a `- profile:` line;
missing means `intake`). The profile decides what the folder tree carries and what the
conformance tooling expects. A repo moves up a profile by declaring it and running
`icm-check.sh --fix` — the folders arrive; nothing starts running by itself.

## The profiles

| Profile | Adds | For |
|---|---|---|
| **`intake`** (default) | `intake/` epics + triage + `docs/` ([TICKETS.md](TICKETS.md)) | every live repo; work is picked from stubs via `## Prompt`, ships as PRs on `claude/` branches |
| **`pipeline`** | the run spine below | repos with enough flow to want specs, runs and gated merges |
| **`pipeline-full`** | scope/approve front, CI close-out + announce, label projection | **not templated** — sustentus is its only instance; extract it when a second repo has a business author |
| *(dormant)* | the empty `.icm/dormant` marker | parked repos ([TICKETS.md](TICKETS.md) § Dormant) |

## The `pipeline` profile — what the template seeds

```
.icm/
  CONTEXT.md                 ← the repo's Layer-1 map; declares `- profile: pipeline`
  stages/
    01_define/CONTEXT.md     ← stub or request → spec.md → the run's ONE draft PR
    02_build/CONTEXT.md      ← implement the approved spec; notes.md; draft → open
    03_release/CONTEXT.md    ← gate read → reviews → gated squash-merge
  lanes/
    bug/ tweak/ chore/       ← fast lanes: no spec, single merge gate
  runs/<slug>/               ← one folder per run: run.md + stage outputs
  _shared/
    github.md                ← PR regime, gate anchors, the never-tick rule
    ci.md                    ← GREEN / RED / PENDING and what green means
    stage-preamble.md        ← resolve the run or STOP
  scripts/
    resolve-run.sh validate-spec.sh validate-intake.sh new-run.sh ci-status.sh
.claude/skills/pipeline/SKILL.md   ← the /pipeline router (one skill, many stages)
.github/pull_request_template.md   ← carries both gate anchors
```

The flow: an epic's next stub (or a plain request) → **Define** writes
`runs/<slug>/01_define/output/spec.md`, validates it, and `new-run.sh` commits the run,
consumes the stub into `_done/`, and opens the **one draft PR** → the owner ticks
**Spec approved** → **Build** implements exactly the spec, writes
`02_build/output/notes.md`, establishes CI green and flips the PR draft → open → the
owner smoke-tests and ticks **Ready to merge** → **Release** establishes
`ci-status.sh` GREEN, runs the review passes, parks off-ticket findings in `triage/`,
and squash-merges once. The merged run is `git mv`'d to `runs/_done/<slug>/` and, when
its epic finishes, the epic archives per [TICKETS.md](TICKETS.md).

**The slug is the universal key**: run folder, stub, branch (`claude/<slug>`), PR — one
name throughout.

## Gates — human checkboxes in the PR body

Anchored so parsing never depends on wording:

```md
<!-- gate:spec-approved -->
- [ ] Spec approved (Define gate — a human ticks this before Build)
<!-- gate:ready-to-merge -->
- [ ] Ready to merge (Release gate — a human ticks this to authorise the squash-merge)
```

- The agent **reads** gates (find the anchor, the next checklist line is the gate) and
  **never ticks either box** — no scripted exception. Unticked → STOP and say so.
- **A missing anchor means "not required", never "unticked".** Lane PRs carry only
  `gate:ready-to-merge`. A PR missing that anchor is malformed — fix the body first.
- Ticking **Ready to merge** attests the owner's own testing of the change; Release
  re-asks for no manual checks.
- Nothing self-advances across a gate: after each stage, say what's done and which
  `/pipeline <next>` comes when the human is ready.

## Scripts — the deterministic factory

Each is one job, config from the environment (never `.env`), one `RESULT:` line last on
stdout, documented exit codes. **`GITHUB_REPO` (owner/repo) is required** — the template
ships no default repo. `GITHUB_TOKEN`/`GH_TOKEN` authenticate; `GITHUB_API_URL` is
optional.

| Script | Job | Verdicts |
|---|---|---|
| `resolve-run.sh <slug>` | adopt an existing run (run.md → branch, else PR search by slug) — **never creates anything** | `READY` 0 · `STOP` 3 |
| `validate-spec.sh <slug\|path>` | spec structure: header fields, five sections, criteria-are-checkboxes | `OK` 0 · `INVALID` 2 |
| `validate-intake.sh <epic\|path>` | the cut's bookkeeping: sequences contiguous, depends-on ordered, build order agrees; triage stubs lane-tagged | `OK` 0 · `SKIP` 0 · `INVALID` 2 |
| `new-run.sh <slug> --summary "…" [--stub …] [--lane …]` | commit run → consume stub → push → open the one PR (draft on the spine, ready in a lane) | `CREATED` 0 |
| `ci-status.sh <slug> \| --pr <n>` | block until CI settles; reads check runs **and** commit statuses, dedupes by newest attempt, re-reads the head each pass | `GREEN` 0 · `RED` 3 · `PENDING` 4 |

Rules the scripts encode, which are the contract even where repo config wouldn't stop
you: **one PR per run** (`new-run.sh` dies if `run.md` records one) · **adopt or STOP**
(never fabricate a run, a branch, or a `run.md`) · **not-yet-red is not green**
(`PENDING` is a third value; nothing merges or hands off on it) · **no PR-event
subscriptions** — the one blocking `ci-status.sh` call per push is the only CI read.

`PIPELINE_REQUIRED_CHECKS` names the check runs that must be present and completed
before GREEN — set it per repo to the repo's own CI.

## Where the D3 line runs (decision D11)

The house rule stays: **never build an orchestrator — the folders are the
orchestration.** D11 narrows what that excludes: a *project repo's own* deterministic
one-job scripts, and CI that acts only after a human-authorised merge (close-out,
announce — `pipeline-full` only), are **factory**, not orchestrator. The line that never
moves:

- Nothing advances work across a human gate; nothing triggers the next stage.
- No outbound action leaves a session (the announce in `pipeline-full` is CI's, fired by
  a merge the owner authorised).
- icm-board itself drives nothing — it describes, checks, and seeds.

If a change makes a stage run itself, that is still the signal to stop.

## Adding a stage or lane in a repo

Add a numbered folder `.icm/stages/NN_<name>/CONTEXT.md` (or `.icm/lanes/<name>/`) and a
row to the repo's `/pipeline` routing table. The pipeline grows in the folder tree, not
the skills list. The repo's copy is its own — the template seeds, drift is reported, the
repo wins ([template/README.md](../template/README.md)).
