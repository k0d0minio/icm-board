# Estate intake spec — `.icm/intake/`

*System-wide standard, re-founded 2026-08-28 on the sustentus intake model (decision D10,
[`.icm/project.md`](../../.icm/project.md)) and aligned on 2026-09-26 with the pipeline
template's own `intake/CONTEXT.md` (Jamie's rulings 2–5 of the estate audit): the template's
field names are the contract, `## Prompt` is optional, dropped work is deleted or archived,
and a front run archives with its scope. Canonical copy lives here in `_system`; each repo
carries a self-contained micro-copy in `.icm/intake/README.md` so cloud sessions that only
see the repo still have the contract; pipeline repos carry the fuller
`.icm/intake/CONTEXT.md` (template-owned), which this document never contradicts. Scopes are
cut by `/pipeline scope` (or `/project` where a repo has no pipeline), walked by `/day`. What
a project is **for** lives in [PROJECT.md](PROJECT.md); the run spine lives in
[PIPELINE.md](PIPELINE.md); this doc is only about the work.*

Tickets are markdown **stubs** inside each repo, and they never live alone: every stub
belongs to a **scope** (a batch cut from one intent — the word the pipeline's Scope stage
gave it; "epic" in older prose means the same folder) or to the **triage lane** (parked
one-off findings). Repos own their tickets; the admin dashboard
(`jamienisbet/websites/admin-dashboard` → `/tickets`) only reads and displays them.
Tickets are never created or edited from the dashboard.

## Layout

```
.icm/
  dormant                ← optional, empty: this repo is parked (see Dormant repos)
  CONTEXT.md             ← this repo's .icm map (PIPELINE.md)
  intake/
    README.md            ← micro-copy of this contract
    <scope-slug>/        ← one folder per scope
      breakdown.md       ← the cut's single review surface
      <feature-slug>.md  ← one stub per unit of work
      _done/             ← stubs spun out into a run (see PIPELINE.md)
    triage/              ← the parking lane: one-off bug/tweak/chore stubs
      <slug>.md
      _done/
    _done/               ← the archive: completed scopes, moved whole — unless
                           `.icm/project.json → intake_archive` names another path
```

- **Identity is the path.** A ticket is `<scope-slug>/<feature-slug>` — estate-wide,
  `repo · scope/slug`. There is no number series; the old `PREFIX-NNN` scheme is retired.
- Slugs are kebab-case and short. The **feature-slug matches the filename** — everything
  resolves stubs by filename.
- Nothing lives loose in `intake/` — a one-off is a triage stub; related work is a scope,
  however small (a single-stub scope is fine).
- **No repo is exempt** (D44). Sustentus, where this model started, is read by the board and
  checked by the conformance and hygiene tooling like any repo.

## Stub format

```markdown
# Stub: Fix mobile nav overflow on menu page

- feature-slug: mobile-nav-overflow
- scope: menu-page-polish
- depends-on: none
- sequence: 2 of 3
- priority: P1
- complexity: low

## Problem

The nav wraps off-screen below 380px …

## Proposed change

Constrain the nav to the viewport; collapse to the burger at 380px.

## Acceptance criteria (rough)

- [ ] Nav usable at 320px
- [ ] CI green
```

**Required:** H1 `# Stub: <title>` · `- feature-slug:` matching the filename ·
`- sequence: <n> of <m>` · `- depends-on:` (write `none` when there are none).

**Optional, read by the tooling when present:** `- scope:` (the folder it sits in — say it,
the board shows it) · `- priority: P0|P1|P2` (P0 urgent · P1 next · P2 whenever — `/day` and
the board rank across repos with it) · `- complexity: low|medium|high|research`
(`select-model.sh` reads it) · `- recommended-model:` · `- blocked: <reason>` (external
blockage, shown as a badge — remove the line when it lifts) · `- personas:`, `- initiative:`,
`- sources:`, `- touches:` (the pipeline's own optional lines — `intake/CONTEXT.md`) · extra
sections. The board displays what it finds and never requires them.

**`## Prompt` is optional.** A stub is its own brief: what the board's "Copy prompt" sends is
the pick-up verb and the slug — `new <scope>/<slug>` for a scope stub, `<lane> <slug>` for a
triage stub (`chore fix-dependencies`), `build <slug>` / `release <slug>` for a run in flight —
which `route-request.sh` routes to `/pipeline` where the repo carries the router. A repo with no
router gets the same string and reads the stub by its path. Write a `## Prompt` only when the
stub needs words the Problem and Proposed change cannot carry (a template change request always
has one — `_shared/template-change.md`).

## Breakdown format

`breakdown.md` is the scope's single review surface — edit it and re-cut to steer:

```markdown
# Breakdown: <scope title>

- scope-slug: <slug>
- sources: <where this came from — docs, audit, Jamie's words>

## What I understood

<3–6 sentences restating the intent, so a misread is caught before the cuts>

## Build order

1. <feature-slug> — <one line> — depends-on: none
2. <feature-slug> — <one line> — depends-on: <feature-slug>

## Out of scope (whole scope)

- <what no stub covers this round>
```

The build order is a strict total order: sequences contiguous `1..m`, every `depends-on`
naming an in-scope stub sequenced first, `## Build order` agreeing with the stubs.
`validate-intake.sh` checks the bookkeeping in every repo that carries it;
`ticket-hygiene.sh` lints it estate-wide. **`## Parallelizable` is derived from
`- touches:`** (D26): a parallel set holds only stubs whose optional `touches:` guesses do
not overlap; stubs that share a surface are sequenced, the shared-file ones first.

## Triage — the parking lane

Anything found that is **not the current work's** — a review finding, a wart stepped
around, a paper cut spotted in passing — is parked as one small stub in
`.icm/intake/triage/` and the session moves on. Never widen a PR to absorb it; never
lose it in conversation.

```markdown
# Stub: <title>

- lane: bug | tweak | chore
- found-by: <source> · <YYYY-MM-DD>
- priority: P2
- complexity: low

## Problem

<observed, one or two lines; file paths if known>

## Proposed change

<one line — or "investigate", if the fix isn't obvious>
```

No breakdown, no `sequence:`, no `depends-on` — a backlog, not a batch. The human prunes;
sessions only add and consume. **The lane holds at most 60 active stubs** (top-level `.md`
files); over the cap every stage or lane that parks a finding says so in its stop message, and
`triage report | batch | prune` (pipeline repos) is how the backlog is worked down — a batch
becomes a scope, a prune is a deletion the human makes.

## Status is positional

There is no Status row and no status vocabulary. Where a file sits on `main` — and what
exists around it — is the state:

| State | How it reads |
|---|---|
| **open** | the stub sits in a live scope or in `triage/` |
| **next** | the open stub with the lowest unmet `sequence` in its scope |
| **in flight** | `.icm/runs/<slug>/` exists (a repo with the pipeline) · the `claude/<slug>` PR is open (a repo without it yet) |
| **blocked** | a `- blocked: <reason>` line; a stub whose `depends-on` isn't done is *waiting*, shown as such |
| **today** | the ticket is listed in icm-board's `.icm/today.md` (below) |
| **done** | the stub is in its scope's `_done/` (pipeline: *spun out* — shipped is the run's merge) |
| **superseded** | in `_done/` with a `- superseded-by:` line naming the stub or batch that absorbed it |

- **Done is a folder move, never a field**: `git mv` in the PR that finishes (or spins
  out) the work.
- **Dropped work is deleted or archived, never left open.** A stub nobody will pick up is
  deleted — the commit message names why — or, where the reasoning is worth keeping, moved
  to `_done/` with a `> Dropped: <reason, date>` line. Nothing complete lingers in `intake/`
  or in `runs/`. A slug is never reused inside its scope.
- **A completed scope is archived whole**: when every stub is in `_done/` (and, in pipeline
  repos, every run has merged), `git mv intake/<scope>/ <archive>/<scope>/` — the archive
  is `intake_archive` in `.icm/project.json` where the repo sets one (sustentus keeps its
  archives under `apps/docs/archive/`), `intake/_done/` otherwise. `intake/` holds only scopes
  with work left in them.
- **A front run archives with its scope** (Jamie, 2026-09-26): the Scope run that cut a
  scope (`runs/<scope-slug>/`, no PR of its own) lives until the last stub of that scope has
  finished — regardless of UAT, promotion or anything else — and `close-out.sh` then moves
  it with the scope. A front still in `runs/` after its scope archived is the missed
  close-out the hygiene report names.
- **The today list lives in one file**: icm-board's `.icm/today.md` — written by `/day`
  the evening before, replaced wholesale, **≤10 entries across the whole estate**, each
  `- <repo> · <scope-slug>/<feature-slug> — <title>`. The board and the SessionStart hook
  read it; ticket files never carry the flag.

## What the dashboard reads

The board (`websites/admin-dashboard/lib/tickets.ts`) reads each repo's `.icm/` from
`main` via the GitHub API and parses leniently — a malformed stub still appears rather than
vanishing. icm-board's `tickets-board.sh` and `ticket-hygiene.sh` read the same branch
locally — `origin/main` in each `projects/<repo>`, never its shared checkout
(`_system/scripts/lib/ticket-base.sh`).

| It reads | From |
|---|---|
| identity | the path: `intake/<scope>/<slug>.md` |
| title | the H1, `Stub: ` stripped (falls back to the filename) |
| ordering | `- sequence:` + `- depends-on:` dash-lines; `- priority:` for ranking |
| lane / blocked / complexity | their dash-lines, shown as badges |
| in flight | `.icm/runs/<slug>/` presence (pipeline repos) |
| today | icm-board's `.icm/today.md` |
| the verb | `new <scope>/<slug>` · `<lane> <slug>` · `build\|release <slug>` — what "Copy prompt" sends; `## Prompt`, when a stub has one, is shown beside it, never sent instead |

## Dormant repos

Some repos are finished rather than neglected — a build-once-hand-off client site with
no backlog and no next sprint. An empty `.icm/dormant` file marks one:

```bash
mkdir -p .icm && touch .icm/dormant && git add .icm/dormant
```

`ticket-hygiene.sh` then stops reporting `off-ticket` against that repo. Every other
check still runs, so dormancy hides noise and never evidence. The file is empty by
design; `git rm .icm/dormant` wakes the repo up. It marks a **repo**, never a ticket —
a dormant repo carries no open stubs: waking it is deleting the marker and cutting fresh
ones, and a repo that goes dormant deletes or archives what it had in the same commit.

## Working rules

- The session that picks a stub up moves it to its scope's `_done/` in the PR that
  spins out the run (`new-run.sh --stub`) — or, in a repo without the router yet, in the
  PR that finishes the work.
- Cutting what's left into scopes or triage is part of ending any session — never a loose
  `TODO.md`.
- **Ticket state has one home, `main`, reached by a direct commit in every repo** (D39 §8,
  `.icm/project.md`) — inside a run it rides the run's PR; outside one it is a
  `Plan:`/`Wrap:`/`Scope:` commit pushed straight to `main`, shaped once in the canonical
  `pr-conventions` skill → Ticket commits.
- **A template-owned file is changed at its source** (D33): a request to change one, made
  in a repo, is parked as a `found-by: template-change` triage stub there and cut again in
  icm-board — `ticket-hygiene.sh` reports every such stub that icm-board has not yet picked
  up, and the sync commit that brings the change back retires it with `- superseded-by:`.
- No write actions from the dashboard (deliberate; revisit only if the manual flow
  chafes).
