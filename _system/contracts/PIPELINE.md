# The estate pipeline — profiles, spine, gates

*The contract for the templated, per-repo SDLC pipeline — extracted from the sustentus
`.icm/` (the reference implementation, which stays exempt and authoritative for itself)
and seeded from [`_system/template/`](../template/README.md). Re-founded on that source's
current four-stage shape in September 2026, generalised rather than parameterised — a
copy is exact, which is what makes the drift report honest. Companions:
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
| **`pipeline`** | the front + the run spine below | repos with enough flow to want specs, runs and gated merges |
| **`pipeline-full`** | CI-driven announce on merge, and whatever else a repo's own factory adds | **not templated** — sustentus is its only instance. The front and the label projection were extracted into `pipeline` in September 2026, so what is left of this row is the announce; whether it survives as a profile is a later call, made with evidence |
| *(dormant)* | the empty `.icm/dormant` marker | parked repos ([TICKETS.md](TICKETS.md) § Dormant) |

## The `pipeline` profile — what the template seeds

```
.icm/
  CONTEXT.md                 ← the repo's Layer-1 map; declares `- profile: pipeline`
  stages/
    01_scope/CONTEXT.md      ← the story committed verbatim → the question sheet
      approve/CONTEXT.md     ← the answers settled into scope.md → the intake cut
    02_define/CONTEXT.md     ← stub or request → spec.md → the run's ONE draft PR
    03_build/CONTEXT.md      ← implement the approved spec; notes.md; draft → open
    04_release/CONTEXT.md    ← gate read → review → close-out → gated squash-merge
  lanes/
    bug/ tweak/ chore/       ← fast lanes: no spec, single merge gate
  runs/<slug>/               ← one folder per run: run.md + stage outputs
  _shared/
    github.md                ← PR regime, gate anchors, the never-tick rule
    ci.md                    ← GREEN / RED / PENDING and what green means
    stage-preamble.md        ← resolve the run or STOP
  scripts/
    resolve-run.sh validate-spec.sh validate-intake.sh new-run.sh ci-status.sh
    close-out.sh project-labels.sh
.claude/skills/pipeline/SKILL.md   ← the /pipeline router (one skill, many stages)
.github/pull_request_template.md   ← carries both gate anchors
```

**The front is optional, and it is a stage, not a profile.** Scope + approve exist for
work that arrives as someone else's written words — a story someone outside the session
wrote. A repo with no business author behind its work never invokes them and has no gap;
work that arrives already agreed goes straight to `/pipeline new`.

The flow, when there is a front: **Scope** commits the author's story verbatim to
`runs/<slug>/01_scope/_source/story.md`, interrogates it, and writes the `Q-n` question
sheet — then stops, because the author answers away from the session. The owner runs
**approve**, which settles those answers into `01_scope/output/scope.md` (story + an
addendum where every `Q-n` ends answered) and cuts the intake epic from *that*, not from
the draft. Both push straight to `main`; a front opens no PR.

Then the spine, once per stub: an epic's next stub (or a plain request) → **Define**
writes `runs/<slug>/02_define/output/spec.md`, validates it, and `new-run.sh` commits the
run, consumes the stub into `_done/`, and opens the **one draft PR** → the owner ticks
**Spec approved** → **Build** implements exactly the spec, writes
`03_build/output/notes.md`, establishes CI green and flips the PR draft → open → the
owner smoke-tests and ticks **Ready to merge** → **Release** establishes `ci-status.sh`
GREEN, runs the review pass, parks off-ticket findings in `triage/`, runs `close-out.sh`
**on the branch**, and squash-merges once. The squash is what publishes the archive move
to `runs/_done/<slug>/` — and the epic's move to `intake/_done/<epic>/`, plus the front
run that cut it, when this stub was the last one it had left unshipped
([TICKETS.md](TICKETS.md)).

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
- **The front's gate has no checkbox** — there is no PR yet. Scope stops until the author
  has answered, and the owner running `/pipeline approve <slug>` *is* the gate closing.
  It is as hard as the other two: nothing downstream is cut from an unanswered sheet.

## Scripts — the deterministic factory

Each is one job, config from the environment (never `.env`), one `RESULT:` line last on
stdout, documented exit codes. Every script derives **`GITHUB_REPO` (owner/repo) from
`origin`** and takes the env var as an override — the template ships no repo literal, and
a script with no origin to derive from says so and dies. `GITHUB_TOKEN`/`GH_TOKEN`
authenticate; `GITHUB_API_URL` is optional.

| Script | Job | Verdicts |
|---|---|---|
| `resolve-run.sh <slug>` | adopt an existing run (run.md → branch, else PR search by slug) — **never creates anything** | `READY` 0 · `STOP` 3 |
| `validate-spec.sh <slug\|path>` | spec structure: header fields, five sections, criteria-are-checkboxes | `OK` 0 · `INVALID` 2 |
| `validate-intake.sh <epic\|path>` | the cut's bookkeeping: sequences contiguous, depends-on ordered, build order agrees; triage stubs lane-tagged | `OK` 0 · `SKIP` 0 · `INVALID` 2 |
| `new-run.sh <slug> --summary "…" [--stub …] [--lane …]` | commit run → consume stub → push → open the one PR (draft on the spine, ready in a lane) | `CREATED` 0 |
| `ci-status.sh <slug> \| --pr <n>` | block until CI settles; reads check runs **and** commit statuses, dedupes by newest attempt, re-reads the head each pass | `GREEN` 0 · `RED` 3 · `PENDING` 4 |
| `close-out.sh <slug>` | archive the run (and the finished epic, and the front behind it) into `_done/`, committed **on the run's branch** — refuses `main`, refuses a PR closed unmerged | `CLOSED` 0 · `STOP` 3 |
| `project-labels.sh <slug> --stage <…\|auto>` | project `type`/`stage`/`complexity` from the spec header onto the run's PR (PUT replaces the whole set) — spine runs only | `APPLIED` 0 |

Rules the scripts encode, which are the contract even where repo config wouldn't stop
you: **one PR per run** (`new-run.sh` dies if `run.md` records one) · **adopt or STOP**
(never fabricate a run, a branch, or a `run.md`) · **not-yet-red is not green**
(`PENDING` is a third value; nothing merges or hands off on it) · **no PR-event
subscriptions** — the one blocking `ci-status.sh` call per push is the only CI read ·
**the close-out rides the PR** (`close-out.sh` refuses to run on `main`: a branch with
required status checks refuses a direct push, and an archive commit pushed afterwards
strands where nobody merges it).

The label vocabulary is the repo's own — `project-labels.sh` writes `type:feature`,
`stage:*` and `complexity:*` and curates nothing. A repo that wants them coloured and
described defines them itself.

`PIPELINE_REQUIRED_CHECKS` names the check runs that must be present and completed
before GREEN — set it per repo to the repo's own CI.

## Where the D3 line runs (decision D11)

The house rule stays: **never build an orchestrator — the folders are the
orchestration.** D11 narrows what that excludes: a *project repo's own* deterministic
one-job scripts, and CI that acts only after a human-authorised merge (the announce —
`pipeline-full` only), are **factory**, not orchestrator. The close-out is the plainest
case: it is a `git mv` and a commit that a human then merges, which is why it moved onto
the branch rather than into CI. The line that never moves:

- Nothing advances work across a human gate; nothing triggers the next stage.
- No outbound action leaves a session (the announce in `pipeline-full` is CI's, fired by
  a merge the owner authorised).
- icm-board itself drives nothing — it describes, checks, and seeds.

If a change makes a stage run itself, that is still the signal to stop.

## Adding a stage or lane in a repo

Add a numbered folder `.icm/stages/NN_<name>/CONTEXT.md` (or `.icm/lanes/<name>/`, or a
named substage folder inside a stage — `01_scope/approve/` is one) and a row to the
repo's `/pipeline` routing table. The pipeline grows in the folder tree, not
the skills list. The repo's copy is its own — the template seeds, drift is reported, the
repo wins ([template/README.md](../template/README.md)).
