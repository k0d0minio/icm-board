# Estate intake spec — `.icm/intake/`

*System-wide standard, re-founded 2026-08-28 on the sustentus intake model (decision D10,
[`.icm/project.md`](../../.icm/project.md)). Canonical copy lives here in `_system`; each
repo carries a self-contained micro-copy in `.icm/intake/README.md` so cloud sessions that
only see the repo still have the contract. Epics are cut by `/project`, walked by `/day`.
What a project is **for** lives in [PROJECT.md](PROJECT.md); the run spine some repos add
on top lives in [PIPELINE.md](PIPELINE.md); this doc is only about the work.*

Tickets are markdown **stubs** inside each repo, and they never live alone: every stub
belongs to an **epic** (a batch cut from one intent) or to the **triage lane** (parked
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
    <epic-slug>/         ← one folder per epic
      breakdown.md       ← the cut's single review surface
      <feature-slug>.md  ← one stub per unit of work
      _done/             ← done stubs (spun out into a run — see PIPELINE.md)
    triage/              ← the parking lane: one-off bug/tweak/chore stubs
      <slug>.md
      _done/
    _done/               ← the archive: completed epics, moved whole — and the legacy
                           flat PREFIX-NNN tickets, kept untouched
```

- **Identity is the path.** A ticket is `<epic-slug>/<feature-slug>` — estate-wide,
  `repo · epic/slug`. There is no number series; the old `PREFIX-NNN` scheme is retired
  and its prefix registry with it. Legacy IDs live on in `_done/` archives, unedited.
- Slugs are kebab-case and short. The **feature-slug matches the filename** — everything
  resolves stubs by filename.
- Nothing lives loose in `intake/` — a one-off is a triage stub; related work is an epic,
  however small (a single-stub epic is fine).
- **Sustentus is exempt** — its `.icm/` is authoritative (it is the *source* of this
  model). The board reads it natively; the conformance and hygiene tooling leaves it
  alone.

## Stub format

```markdown
# Stub: Fix mobile nav overflow on menu page

- feature-slug: mobile-nav-overflow
- epic: menu-page-polish
- priority: P1
- size: S
- depends-on: none
- sequence: 2 of 3

## Problem

The nav wraps off-screen below 380px …

## Proposed change

Constrain the nav to the viewport; collapse to the burger at 380px.

## Acceptance criteria (rough)

- [ ] Nav usable at 320px
- [ ] CI green

## Prompt

Fix the mobile nav overflow on the menu page. The nav lives in
app/components/nav.tsx. Read .icm/intake/menu-page-polish/mobile-nav-overflow.md
for full context. Open a PR on a claude/ branch; do not run local checks — CI is
the source of truth.
```

**Required:** H1 `# Stub: <title>` · `- feature-slug:` matching the filename ·
`- sequence: <n> of <m>` · `- depends-on:` (write `none` when there are none).

**`## Prompt`** — everything under it must stand alone when pasted into a fresh agent
session at the repo root. **Required in every stub**: it is the brief Define reads when
`/pipeline new` picks the stub up, and the whole pick-up contract where a repo has no
router yet. **What the board sends is the pick-up verb** (decision D26): where the repo
carries `.claude/skills/pipeline/SKILL.md`, the "Copy prompt" button and the deep links
send `/pipeline new <epic>/<slug>` for an epic stub, `/pipeline <lane>
.icm/intake/triage/<slug>.md` for a triage stub (the lane from its `- lane:` line), and
`/pipeline build <slug>` / `/pipeline release <slug>` for a run in flight by its stage;
where the repo does not, they send the `## Prompt` body as before. The ticket detail shows
the exact string it will send.

**Optional, free-form:** `priority` (`P0` urgent · `P1` next · `P2` whenever — `/day`
ranks across repos with it), `size`, `blocked: <reason>` (external blockage, shown as a
badge — remove the line when it lifts), `sources`, `client`, extra sections. The board
displays what it finds and never requires them.

## Breakdown format

`breakdown.md` is the epic's single review surface — edit it and re-cut to steer:

```markdown
# Breakdown: <epic title>

- epic-slug: <slug>
- sources: <where this came from — docs, audit, Jamie's words>

## What I understood

<3–6 sentences restating the intent, so a misread is caught before the cuts>

## Build order

1. <feature-slug> — <one line> — depends-on: none
2. <feature-slug> — <one line> — depends-on: <feature-slug>

## Out of scope (whole epic)

- <what no stub covers this round>
```

The build order is a strict total order: sequences contiguous `1..m`, every `depends-on`
naming an in-epic stub sequenced first, `## Build order` agreeing with the stubs.
`validate-intake.sh` checks the bookkeeping in every repo that carries it;
`ticket-hygiene.sh` lints it estate-wide. **`## Parallelizable` is derived from
`- touches:`** (D26): a parallel set holds only stubs whose optional `touches:` guesses do
not overlap; stubs that share a surface are sequenced, the shared-file ones first
(`intake/CONTEXT.md` → Formats).

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

## Problem

<observed, one or two lines; file paths if known>

## Proposed change

<one line — or "investigate", if the fix isn't obvious>

## Prompt

<stand-alone pick-up, as above — required>
```

No breakdown, no `sequence:`, no `depends-on` — a backlog, not a batch. The human
prunes; sessions only add and consume.

## Status is positional

There is no Status row and no status vocabulary. Where a file sits on the repo's ticket
base branch (§ What the dashboard reads) — and what exists around it — is the state:

| State | How it reads |
|---|---|
| **open** | the stub sits in a live epic or in `triage/` |
| **next** | the open stub with the lowest unmet `sequence` in its epic |
| **in flight** | `.icm/runs/<slug>/` exists (a repo with the pipeline) · the `claude/<slug>` PR is open (a repo without it yet) |
| **blocked** | a `- blocked: <reason>` line; a stub whose `depends-on` isn't done is *waiting*, shown as such |
| **today** | the ticket is listed in icm-board's `.icm/today.md` (below) |
| **done** | the stub is in its epic's `_done/` (pipeline: *spun out* — shipped is the run's merge) |
| **dropped** | in `_done/` with a `> Dropped: <reason, date>` line prepended |

- **Done is a folder move, never a field**: `git mv` in the PR that finishes (or spins
  out) the work. Abandoned work moves the same way with its `> Dropped:` line — nothing
  is deleted, and a slug is never reused inside its epic.
- **A completed epic is archived whole**: when every stub is in `_done/` (and, in
  pipeline repos, every run has merged), `git mv intake/<epic>/ intake/_done/<epic>/`.
  `intake/` holds only epics with work left in them.
- **The today list lives in one file**: icm-board's `.icm/today.md` — written by `/day`
  the evening before, replaced wholesale, **≤10 entries across the whole estate**, each
  `- <repo> · <epic-slug>/<feature-slug> — <title>`. The board and the SessionStart hook
  read it; ticket files never carry the flag.

## What the dashboard reads

The board (`websites/admin-dashboard/lib/tickets.ts`) reads each repo's `.icm/` from
`main` via the GitHub API and parses leniently — a malformed stub still appears rather than
vanishing. icm-board's `tickets-board.sh` and `ticket-hygiene.sh` read the same branch
locally — `origin/main` in each `projects/<repo>`, never its shared checkout
(`_system/scripts/lib/ticket-base.sh`).

| It reads | From |
|---|---|
| identity | the path: `intake/<epic>/<slug>.md` (legacy flat tickets: the old ID rules) |
| title | the H1, `Stub: ` stripped (falls back to the filename) |
| ordering | `- sequence:` + `- depends-on:` dash-lines; `- priority:` for ranking |
| lane / blocked / size | their dash-lines, shown as badges |
| in flight | `.icm/runs/<slug>/` presence (pipeline repos) |
| today | icm-board's `.icm/today.md` |
| the prompt | `## Prompt` body up to the next `##` (synthesised from the path when absent) — sent as the body only where the repo has no `/pipeline` router; otherwise the board sends the pick-up verb |
| the verb | `/pipeline new <epic>/<slug>` · `/pipeline <lane> .icm/intake/triage/<slug>.md` · `/pipeline build\|release <slug>` — probed once per repo by the presence of `.claude/skills/pipeline/SKILL.md` |

Legacy flat `PREFIX-NNN` tickets still parse under the old rules until their repo
migrates — both shapes render side by side.

## Dormant repos

Some repos are finished rather than neglected — a build-once-hand-off client site with
no backlog and no next sprint. An empty `.icm/dormant` file marks one:

```bash
mkdir -p .icm && touch .icm/dormant && git add .icm/dormant
```

`ticket-hygiene.sh` then stops reporting `off-ticket` against that repo. Every other
check still runs, so dormancy hides noise and never evidence. The file is empty by
design; `git rm .icm/dormant` wakes the repo up. It marks a **repo**, never a ticket —
a dormant repo that gets a new stub drops the marker in the same commit.

## Working rules

- The session that picks a stub up moves it to its epic's `_done/` in the PR that
  spins out the run (`new-run.sh --stub`) — or, in a repo without the router yet, in the
  PR that finishes the work.
- Cutting what's left into epics or triage is part of ending any session — never a loose
  `TODO.md`.
- **Ticket state has one home, `main`, reached by a direct commit in every repo** (D39 §8,
  `.icm/project.md`) — inside a run it rides the run's PR; outside one it is a
  `Plan:`/`Wrap:`/`Scope:` commit pushed straight to `main`, shaped once in the canonical
  `pr-conventions` skill → Ticket commits.
- No write actions from the dashboard (deliberate; revisit only if the manual flow
  chafes).
