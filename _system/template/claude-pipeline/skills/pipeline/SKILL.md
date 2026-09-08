---
name: pipeline
description: >-
  The delivery pipeline (ICM). Use for /pipeline — to scope a request, define, build or
  release work, fix a bug, make a tweak, run a chore, or check status. Subcommands:
  scope, approve, new, define, build, release, bug, tweak, chore, status.
---

# /pipeline — the delivery pipeline router

The single entry point for this repo's delivery pipeline (estate template — canonical
spec: `_system/contracts/PIPELINE.md` in the icm-board estate). It does **not** contain
the work — each stage or lane contract lives under `.icm/stages/` / `.icm/lanes/`.
Parse the subcommand, load the right contract, follow it.

Argument form: `<subcommand> [slug, "request", or stub path]`. The argument is: `$ARGUMENTS`

## Routing table

| Subcommand | Contract to read & follow |
|---|---|
| `scope "<story>"` / `scope <slug>` | `.icm/stages/01_scope/CONTEXT.md` |
| `approve <slug>` | `.icm/stages/01_scope/approve/CONTEXT.md` |
| `new` (all forms — resolution below) | `.icm/stages/02_define/CONTEXT.md` |
| `define "<request>"` / `define <slug>` | `.icm/stages/02_define/CONTEXT.md` |
| `build <slug>` | `.icm/stages/03_build/CONTEXT.md` |
| `release <slug>` | `.icm/stages/04_release/CONTEXT.md` |
| `bug "<report>"` / `bug <slug-or-stub>` | `.icm/lanes/bug/CONTEXT.md` |
| `tweak "<change>"` / `tweak <slug-or-stub>` | `.icm/lanes/tweak/CONTEXT.md` |
| `chore "<task>"` / `chore <slug-or-stub>` | `.icm/lanes/chore/CONTEXT.md` |
| `status [slug]` | — (handle here, below) |
| *(empty / unclear)* | read `.icm/CONTEXT.md`, show the help |

Stages are discovered by folder order: `ls .icm/stages/` → `NN_<name>/CONTEXT.md`; a
subcommand maps to the `<name>` part, and a substage folder inside a stage (here,
`01_scope/approve/`) maps to its own name. Lanes likewise under `.icm/lanes/`. Adding a
stage is a folder plus a routing row — never a new skill.

**The front is optional.** `scope` + `approve` exist for work that arrives as someone
else's written words: the story is committed verbatim, interrogated, settled, and cut
into an intake epic. Work that arrives already agreed skips them — `/pipeline new` and
Define picks the slug. A repo with no business author behind its work will never use
them, and that is not a gap.

## How to run a stage or lane

1. Read `.icm/CONTEXT.md` once this session if you haven't.
2. Resolve the `<slug>` (kebab-case).
3. For the **adopting** stages — `build`, `release`, a lane resumed by slug — run the
   shared preamble first: `.icm/_shared/stage-preamble.md` ("resolve the run or STOP").
   Never recreate a missing run. `scope`, `approve` and `define` create rather than
   adopt, and do not run it.
4. **Read the matching contract in full and follow it exactly.** Load only the files
   its Inputs section names. **CI is read one way everywhere:**
   `.icm/scripts/ci-status.sh <slug>` → `GREEN | RED | PENDING` (`.icm/_shared/ci.md`).
   No stage hands off or merges on anything but a settled `GREEN`. **Pipeline PRs are
   never subscribed to PR activity** (`.icm/_shared/github.md`).
5. **Respect gates — never auto-advance.** Two hard gates on the PR, both the owner's:
   **Spec approved** and **Ready to merge** (checkboxes). You only ever **read** them —
   never tick one, never start the next stage on your own. The front has a third gate
   with no checkbox: Scope stops until the author has answered, and the owner running
   `/pipeline approve <slug>` is what closes it. After each stage, say what's done, where
   the output is, and which `/pipeline <next>` comes when the human is ready.

## Resolving `new` (one procedure, three selectors)

**Candidate set = active epic stubs.** Glob `.icm/intake/*/*.md`, excluding every
`breakdown.md`, anything under `_done/`, and the whole `triage/` folder (triage stubs
are lane work — the lanes consume them, `new` never does).

- **`new "<request>"`** (has spaces/quotes) — plain-English work, no stub: hand it
  straight to Define; it picks the slug.
- **`new <stub-path>`** (contains `/` or ends `.md`) — explicit stub: hand it to Define.
- **`new <bare-name>`** — exact filename match in the candidate set → use it; else
  substring match (one → use it and say which; several → ask; none → list the active
  stubs grouped by epic and ask — never treat it as a fresh request. A match in
  `triage/` instead → point at `/pipeline bug|tweak|chore <name>`).
- **`new`** (no argument) — walk the active epic in order:
  1. Group candidates by epic. One active epic → that's the batch; several → ask;
     none → say intake is empty. Stop.
  2. Pick the lowest `sequence: n of m`. Dependency check — `_done/` means **spun out,
     not shipped**: if the pick's `depends-on` names a stub not yet in `_done/`, warn
     the batch is out of order; if it is in `_done/`, confirm its run actually merged
     before offering the pick.
  3. **Announce the pick and stop for confirmation** — opening a run + draft PR is a
     real side effect. On confirmation, hand the path to Define.

**Lane stubs resolve the same way but from `triage/`:** `bug|tweak|chore <bare-name>`
first checks `.icm/intake/triage/*.md` (excluding `_done/`) before treating the
argument as a resume slug.

## `status` subcommand

- `status <slug>` → shared preamble if the run isn't in the checkout; then report:
  lane, which stage outputs exist (story.md → scoped · scope.md → approved · spec.md →
  defined · notes.md → built · a `## Release` section → released), each gate's state
  from the PR body (a front has none), PR state, and
  `ci-status.sh <slug> --no-wait`'s verdict (report `PENDING` as pending, never as
  green).
- `status` (no slug) → the board: `.icm/runs/` (in flight) and `.icm/runs/_done/`
  (recently shipped); `.icm/intake/*/` epics with stubs remaining vs `_done/` — the
  filesystem is the state — and the `triage/` backlog (count + lane split) on its own
  line.

## Help (when subcommand is empty or unclear)

```
/pipeline — delivery pipeline
  Front (only when the work arrives as someone else's written words):
  /pipeline scope "<story>"     commit the story verbatim, interrogate it, raise the questions
  /pipeline approve <slug>      settle the answers into scope.md, cut the intake batch
  Spine (spec → build → gated merge):
  /pipeline new                 take the epic's next stub into Define (also: new <name> | <stub-path> | "<request>")
  /pipeline define <slug>       revise an existing spec
  /pipeline build <slug>        implement the approved spec (needs the Spec-approved tick)
  /pipeline release <slug>      review → gated squash-merge → close out (needs the Ready-to-merge tick)
  Fast lanes (single merge gate; also start from a triage stub by name):
  /pipeline bug "<report>"      reproduce → fix → PR
  /pipeline tweak "<change>"    tiny adjustment → small PR
  /pipeline chore "<task>"      refactor/dep-bump/migration → PR
  /pipeline status [slug]       where a run (or everything) stands
```
