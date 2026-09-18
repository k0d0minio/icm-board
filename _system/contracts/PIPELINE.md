# The estate pipeline — profiles, spine, gates, ownership

*The contract for the templated, per-repo SDLC pipeline — extracted from the sustentus
`.icm/` (the reference implementation, which stays exempt from the estate baseline and
authoritative for itself) and seeded from [`_system/template/`](../template/README.md).
Re-founded on that source's current four-stage shape in September 2026, generalised
rather than parameterised — a template-owned copy is exact, which is what makes both the
drift report and the sync honest. Companions: [TICKETS.md](TICKETS.md) (the intake layer
every profile shares) · [PROJECT.md](PROJECT.md) (the register). Decisions D10–D12 and
D20–D21, [`.icm/project.md`](../../.icm/project.md).*

Every repo declares **one profile** in its `.icm/CONTEXT.md` (a `- profile:` line;
missing means `intake`). The profile decides what the folder tree carries and what the
conformance tooling expects. A repo moves up a profile by declaring it and running
`icm-check.sh --fix` — the folders arrive; nothing starts running by itself.

## The profiles

| Profile | Adds | For |
|---|---|---|
| **`intake`** (default) | `intake/` epics + triage + `docs/` ([TICKETS.md](TICKETS.md)) | every live repo; work is picked from stubs via `## Prompt`, ships as PRs on `claude/` branches |
| **`pipeline`** | the front + the run spine below | repos with enough flow to want specs, runs and gated merges |
| **`pipeline-full`** | whatever a repo's own factory adds on top — a CI-driven announce on merge, a preview smoke walk | **not templated** — sustentus is its only instance. Everything the template needs to *know* about such additions is read from the repo's project-owned files (`project.json` → `smoke_check`, `project-rules.md` → Announcing), so the contracts stay identical; whether the row survives as a profile is a later call, made with evidence |
| *(dormant)* | the empty `.icm/dormant` marker | parked repos ([TICKETS.md](TICKETS.md) § Dormant) |

## The `pipeline` profile — what the template seeds, and who owns each file

```
.icm/
  CONTEXT.md                 ← the repo's Layer-1 map; declares `- profile: pipeline`     (repo's own)
  project.json               ← the project manifest: name, docs_path, archives, checks   (P)
  stages/
    01_scope/CONTEXT.md      ← source recorded → settled in session → scope.md → the cut (T)
    02_define/CONTEXT.md     ← stub or request → spec.md → the run's ONE draft PR          (T)
    03_build/CONTEXT.md      ← implement the approved spec; notes.md; draft → open        (T)
    04_release/CONTEXT.md    ← gate read → review → docs → close-out → gated squash-merge (T)
  lanes/
    bug/ tweak/ chore/       ← fast lanes: no spec, the merge button is the gate           (T)
    knowledge/               ← one docs page, one docs-only PR, no run                     (T)
  intake/CONTEXT.md          ← the breakdown/stub formats, triage, the archive rules       (T)
  runs/<slug>/               ← one folder per run: run.md + stage outputs                  (Layer 4)
  runs/README.md             ← the repo's own note on its runs and their archive           (P)
  _shared/
    github.md                ← PR regimes, gate anchors, the never-tick rule               (T)
    ci.md                    ← GREEN / RED / PENDING and what green means                  (T)
    stage-preamble.md        ← resolve the run or STOP                                     (T)
    scope-template.md        ← the shape of a settled scope; the D-n table                 (T)
    conventions.md           ← redirect to the repo's code rules                           (T)
    project-rules.md         ← what is true of THIS repo: people, factory, announce        (P)
    knowledge-map.md         ← which docs page each stage reads                            (P)
  scripts/
    lib/{gh,changed-files,project}.sh                                                      (T)
    resolve-run.sh validate-spec.sh validate-intake.sh validate-decisions.sh new-run.sh
    project-body.sh project-labels.sh ci-status.sh close-out.sh triage-report.sh
    env-check.sh                                                                           (T)
    format.sh lint.sh validate-knowledge-map.sh notify.sh                                  (P)
.claude/skills/pipeline/SKILL.md   ← the /pipeline router (one skill, many stages)
.github/pull_request_template.md   ← carries both gate anchors
```

**File-level ownership (decision D20).** Every file the template seeds is one of two
things, and [`template/icm-pipeline/MANIFEST`](../template/icm-pipeline/MANIFEST) says
which:

- **T — template-owned.** Byte-identical in every pipeline repo. It carries no repo's
  identity — no owner name, no docs path, no channel, no check name, no archive path —
  and reads whatever is repo-specific at runtime from the two project-owned files below.
  `icm-check.sh` reports a diverged copy as drift; **`icm-sync.sh --apply <repo>`** is
  the repair, invoked by a human, defaulting to a dry run, moving nothing outside the
  manifest and deleting nothing. This is the one narrow exception to "repos own their
  copies": the contracts are the estate's, so that a fix to a stage reaches every repo.
- **P — project-owned.** Seeded **once** from the template's stub when missing, then the
  repo's forever: neither script touches it again. `project.json` holds the values a
  script reads (`name`, `docs_path`, `required_env`, `required_checks`, `runs_archive`,
  `intake_archive`, `smoke_check`); `_shared/project-rules.md` holds the rules a stage
  reads (who the operator is, how the repo announces, which capability skills exist);
  `_shared/knowledge-map.md` names the repo's own doc pages; the four scripts are the
  repo's own feedback and notification hooks.

**No placeholders.** A template-owned contract never says `{{PROJECT}}`; it says "the
operator", "the docs tree (`docs_path` in `.icm/project.json`)", "the repo's required
checks", "see `_shared/project-rules.md` → Announcing". Generalising the profile out of
sustentus meant *removing* its identity, never templating it.

**The front is a stage, not a profile, and it has no substage.** Scope exists for work
that arrives as someone else's words — a story, a prototype URL, a document, a prompt
written after a call, a chat thread. It records the source verbatim, interrogates it
**live with the operator in session** (`AskUserQuestion`, in rounds) — there is no
question sheet and nothing is answered out of band — settles what can be settled into
`01_scope/output/scope.md` (the source plus an addendum: assumptions, the **`D-n`
decisions table**, out of scope, and what is **Open for Define**), cuts the intake epic
from *that*, and pushes it all straight to `main`. A front opens no PR. A repo whose work
arrives already agreed never invokes it and has no gap; work with a stub goes to
`/pipeline new`.

Then the spine, once per stub: an epic's next stub (or a plain request) → **Define**
writes `runs/<slug>/02_define/output/spec.md`, carrying every `D-n` it builds on and
answering every Open-for-Define line, validates it, and `new-run.sh` commits the run,
consumes the stub into `_done/`, and opens the **one draft PR** (its body projected from
the spec by `project-body.sh`) → the operator ticks **Spec approved** → **Build**
implements exactly the spec, writes `03_build/output/notes.md`, establishes CI green on
the cheap tier and flips the PR draft → open, which is what builds the previews → the
operator smoke-tests and ticks **Ready to merge** → **Release** establishes
`ci-status.sh` GREEN on the full gate, runs the review pass, parks off-ticket findings in
`triage/`, syncs the docs the change made stale, writes the changelog page where the repo
has one, runs `close-out.sh` **on the branch**, and squash-merges once. The squash is
what publishes the archive move — and the epic's move, plus the front run that cut it,
when this stub was the last one it had left unshipped ([TICKETS.md](TICKETS.md)).
`revise <slug> "<change>"` is the only way a spec changes after that: it re-projects the
PR body and **resets the Spec-approved anchor**, so a revised spec never inherits a stale
tick.

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
- **A missing anchor means "not required", never "unticked".** Lane PRs carry no
  checkboxes at all: their gate is the merge button, which the operator presses in the
  GitHub UI after their own smoke. A spine PR missing an anchor is malformed — fix the
  body first (`project-body.sh <slug> --apply` re-projects it).
- Ticking **Ready to merge** attests the operator's own testing of the change; Release
  re-asks for no manual checks.
- Nothing self-advances across a gate: after each stage, say what's done and which
  `/pipeline <next>` comes when the human is ready.
- **The front's gate has no checkbox** — there is no PR yet. The operator reviews
  `scope.md` and the cut on `main` and runs `new` when happy; nothing downstream is cut
  from a scope the operator did not settle.

## Scripts — the deterministic factory

Each is one job, config from the environment and `.icm/project.json` (never `.env`), one
`RESULT:` line last on stdout, documented exit codes. Every GitHub call goes through
`lib/gh.sh` — curl with `GITHUB_TOKEN`/`GH_TOKEN`, else a logged-in `gh` CLI — and
**`GITHUB_REPO` is derived from `origin`** with the env var as an override; the template
ships no repo literal. `lib/project.sh` reads the manifest, with the estate's own defaults
for every key.

| Script | Job | Verdicts |
|---|---|---|
| `resolve-run.sh <slug>` | adopt an existing run (run.md live or archived → branch, else the PR by slug through the pulls listing — never the search API) — **never creates anything** | `READY` 0 · `STOP` 3 |
| `validate-spec.sh <slug\|path>` | spec structure: header fields, five sections, criteria-are-checkboxes | `OK` 0 · `INVALID` 2 |
| `validate-intake.sh <epic\|path>` | the cut's bookkeeping: sequences contiguous, depends-on ordered, build order agrees; triage stubs lane-tagged | `OK` 0 · `SKIP` 0 · `INVALID` 2 |
| `validate-decisions.sh <slug\|path>` | every `\| D-n \|` row of the scope's Decisions table appears in `spec.md` and `notes.md` (the front's own, or the front of the epic behind the stub); a file not yet written is "not yet", never a failure | `OK` 0 · `SKIP` 0 · `MISSING n` 2 |
| `new-run.sh <slug> --summary "…" [--stub …] [--lane …]` | commit run → consume stub → push → open the one PR (draft on the spine, ready in a lane), body from `project-body.sh` | `CREATED` 0 |
| `project-body.sh <slug> [--apply]` | the one implementation of the spine PR body, projected from `spec.md`; `--apply` PATCHes it in place and resets both gate anchors | `APPLIED` 0 |
| `project-labels.sh <slug> --stage <…\|auto>` | project `type`/`stage`/`complexity` from the spec header onto the run's PR (PUT replaces the whole set) — spine runs only | `APPLIED` 0 |
| `ci-status.sh <slug> \| --pr <n>` | block until CI settles; reads check runs **and** commit statuses, dedupes by newest attempt, re-reads the head each pass; required names from `required_checks`, a conditional smoke from `smoke_check` | `GREEN` 0 · `RED` 3 · `PENDING` 4 |
| `close-out.sh <slug>` | archive the run (and the finished epic, and the front behind it) into `runs_archive` / `intake_archive`, committed **on the run's branch** — refuses `main`, refuses a PR closed unmerged; a dropped stub counts as settled | `CLOSED` 0 · `STOP` 3 |
| `triage-report.sh` | the parking lane's counts by lane / source / area / age, near-duplicates, against the cap | `OK` 0 |
| `env-check.sh [--fix]` | pre-flight: binaries, a GitHub route, `required_env`, the folder shape, executable bits (repaired only with `--fix`), a UTF-8 locale | `PASS` 0 · `FAIL` 1 |
| `format.sh` · `lint.sh` (P) | changed-files-only **feedback** before a push — never the verdict, never the full sweep (D21) | `OK` · `SKIP` · … |
| `validate-knowledge-map.sh` (P) | every page the knowledge map names resolves under `docs_path` | `OK` 0 · `SKIP` 0 · `INVALID` 2 |
| `notify.sh "<notes>"` (P) | the post-merge notification hook — the repo wires its channel, or leaves the stub because its CI announces | `SENT` 0 |

Rules the scripts encode, which are the contract even where repo config wouldn't stop
you: **one PR per run** (`new-run.sh` dies if `run.md` records one) · **adopt or STOP**
(never fabricate a run, a branch, or a `run.md`) · **not-yet-red is not green**
(`PENDING` is a third value; nothing merges or hands off on it) · **no PR-event
subscriptions** — the one blocking `ci-status.sh` call per push is the only CI read ·
**the close-out rides the PR** (`close-out.sh` refuses to run on `main`: a branch with
required status checks refuses a direct push, and an archive commit pushed afterwards
strands where nobody merges it) · **a check name may contain a comma** —
`PIPELINE_REQUIRED_CHECKS` and `required_checks` are newline- and array-separated, never
comma-split.

The label vocabulary is the repo's own — `project-labels.sh` writes `type:feature`,
`stage:*` and `complexity:*` and curates nothing. A repo that wants them coloured and
described defines them itself.

## Where the D3 line runs (decision D11)

The house rule stays: **never build an orchestrator — the folders are the
orchestration.** D11 narrows what that excludes: a *project repo's own* deterministic
one-job scripts, and CI that acts only after a human-authorised merge (an announce, a
verify job), are **factory**, not orchestrator. The close-out is the plainest case: it is
a `git mv` and a commit that a human then merges, which is why it moved onto the branch
rather than into CI. The sync tool is the same kind of thing one level up: it copies
files a human asked it to copy and runs nothing. The line that never moves:

- Nothing advances work across a human gate; nothing triggers the next stage.
- No outbound action leaves a session (an announce is CI's, fired by a merge the operator
  authorised, or a hook the operator wired).
- icm-board itself drives nothing — it describes, checks, seeds, and on request syncs.

If a change makes a stage run itself, that is still the signal to stop.

## Adding a stage or lane

**In the template** — for every pipeline repo: add the folder and its `CONTEXT.md` under
`template/icm-pipeline/`, add a `T` line to the MANIFEST, add the routing row to the
seeded `/pipeline` skill, and run `icm-sync.sh` per repo. **In one repo only** — add a
numbered folder `.icm/stages/NN_<name>/CONTEXT.md` (or `.icm/lanes/<name>/`), a row to
the repo's `/pipeline` routing table, and a note in its `_shared/project-rules.md`;
`icm-check.sh` will list it as "not in the template's manifest" so the addition stays
visible. Either way the pipeline grows in the folder tree, not the skills list.
