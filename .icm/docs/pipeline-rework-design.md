# The pipeline rework — design record (2026-08-28)

*Jamie-directed session, 2026-08-28. The sustentus delivery pipeline becomes the estate
standard: tickets re-founded as epic batches of stubs, the pipeline templated as tiered
profiles, the dashboard board taught to read all of it — sustentus included. This
document is the reasoning and the ledger; the law lives in the contracts it amends.*

## What Jamie asked for, and what he decided

The ask: *"The sustentus ICM pipeline is pretty damn good, and it works. Rework ticket
management, creation and visualisation to match it. The admin dashboard should visualise
all my tickets easily, including sustentus. The ultimate goal is an ICM pipeline that is
templated, reproducible and editable per project, powering the SDLC of any project, big
or small. Tickets don't live on their own — they belong to user stories or epics."*

Interrogation round 1 (scope):

| Question | Jamie's answer |
|---|---|
| How much of sustentus goes estate-wide? | **The full pipeline, parameterized** — intake batches, run/stage spine, lanes, scripts |
| Ticket identity? | **Adopt sustentus slugs** — drop the `PREFIX-NNN` series; identity is the `epic/slug` path |
| Dashboard data path? | **GitHub API, read-only** — no sync, no DB copy, git stays the source of truth |
| Where does sustentus end up? | **Source, stays exempt** — the template is extracted *from* it; sustentus itself is untouched |

Interrogation round 2 (execution), after the four-agent analysis:

| Question | Jamie's answer |
|---|---|
| Deliverable? | **Run the whole thing end-to-end**, pausing only at his gates |
| The D3 orchestrator doctrine? | **Narrow D3, keep the machinery** — recorded as D11 |
| Scaling across 23 repos? | **Tiered profiles** |
| What replaces the Status row? | **Positional only; `/day` redesigned** — no status metadata in ticket files |

## What the analysis established

Four parallel explorations (sustentus deep-map · icm-board blast radius · estate `.icm`
inventory · jamienisbet dashboard) found:

- **The mechanism separates cleanly from the binding.** Sustentus's transferable core:
  folder-as-orchestration, the intake cut (`breakdown.md` + stubs with `sequence: n of m`
  and `depends-on`), one PR per run with anchored human-only checkbox gates, three-value
  CI verdicts from one blocking script, park-don't-widen triage. Its ~20 bindings (named
  approvers, six-persona vocabulary, Slack announce, changelog site, Vercel surfaces,
  label scheme) each map to a template parameter — or to omission at the smaller tiers.
- **It scales down in tiers.** The lanes + triage are the highest-value/lowest-cost piece;
  the intake cut earns its keep above ~1 related PR; the scope/approve front only earns
  its keep when someone other than the operator authors stories — sustentus itself has
  never exercised it (all 26 runs start at define or a lane).
- **remi-ai is the ancestor**, running a 6-stage `pipeline/` with zero runs and two
  parallel ticket systems (`pipeline/intake/` + `.icm/intake/` REMI-NNN). This rework is
  the recorded answer to `_system/AUDIT.md`'s open question 2 ("Pipeline upstream").
- **The blast radius of path identity** is large but enumerable — the ledger below. The
  dual prefix registry (`TICKETS.md` + `icm-check.sh`, enforced by `start/06_repo`)
  disappears entirely.
- **The dashboard board already exists in production** (`/tickets` on
  app.jamienisbet.com) with exactly the chosen architecture. The work is a parser +
  roster + caching evolution, not a build.
- **Ordering constraints:** the board's reader never recursed into subfolders, so the
  parser must speak both shapes before any repo migrates; `self-check.sh`'s
  `^ICM-[0-9]+-` regex runs in CI here, so icm-board's own migration must land in the
  same PR as the script change.

## The model (the law is in `_system/contracts/TICKETS.md` and `PIPELINE.md`)

- **Epics and stubs.** `.icm/intake/<epic-slug>/` holds `breakdown.md` + one stub per
  unit of work + `_done/`. One-off findings park in `.icm/intake/triage/` as lighter
  lane-tagged stubs (`bug | tweak | chore`). Nothing lives loose in `intake/`.
- **Path identity.** A ticket is `<epic-slug>/<feature-slug>` (estate-wide:
  `repo · epic/slug`). The `PREFIX-NNN` series is retired; legacy IDs survive untouched
  in the archives.
- **Positional status.** Open = in a live epic or triage. Done = in `_done/`. In flight =
  the run exists (`runs/<slug>/`, pipeline profiles) or the `claude/<slug>` PR is open.
  Order = `sequence: n of m` + `depends-on`. Priority stays as an optional `- priority:`
  line (P0/P1/P2) because `/day` ranks across repos. An optional `- blocked: <reason>`
  line records external blockage; there is no status row and no status vocabulary.
- **The today flag leaves ticket files.** `/day` writes `.icm/today.md` in icm-board —
  ≤10 lines, each `- <repo> · <epic>/<slug> — <title>`. The board and the SessionStart
  hook read that one file. Replacing it wholesale each evening *is* clearing the flags.
- **Archive semantics.** `intake/_done/` at the root is the archive: completed epic
  folders are `git mv`'d there whole, and the legacy flat `PREFIX-NNN` tickets already
  in it stay put, unedited. Inside a live epic, `_done/` means *done or consumed* —
  in pipeline profiles specifically it means *spun out, not shipped* (the run's merge is
  shipped).
- **Profiles** (declared in each repo's `.icm/CONTEXT.md`):
  - **`intake`** — the estate default. Epics + triage + `docs/`. Work is picked straight
    from stubs via their `## Prompt`; PRs on `claude/` branches; no runs.
  - **`pipeline`** — adds the run spine: `runs/`, `stages/01_define` + `02_release`,
    `lanes/{bug,tweak,chore}`, `_shared/{github,ci,stage-preamble}.md`, five scripts, the
    `/pipeline` router skill, and a PR template carrying the gate anchors. Two gates by
    default (Spec approved · Ready to merge), both the owner's.
  - **`pipeline-full`** — the sustentus shape: adds the scope/approve front, CI
    close-out/announce, label projection. **Not templated yet** — sustentus is its only
    instance and stays exempt; extract it when a second repo genuinely needs a
    business author.
  - **dormant** — the empty `.icm/dormant` marker, unchanged.
- **D3 narrowed (decision D11).** Deterministic one-job scripts, and post-merge CI
  close-out inside a project repo's own pipeline, are *factory*, not orchestrator. The
  line that survives intact: **nothing advances work across a human gate**, and icm-board
  itself still drives nothing.

## The amendment ledger

Every home the old model lived in, and what happened to it in this change:

| Home | Change |
|---|---|
| `_system/contracts/TICKETS.md` | Rewritten — the intake spec above |
| `_system/contracts/PIPELINE.md` | **New** — profiles, spine, lanes, gates, scripts contract |
| `_system/contracts/PROJECT.md` | Features table's Tickets column becomes epic/stub paths |
| `_system/contracts/WORKSPACES.md` | Points at D11 for what "never an orchestrator" now excludes |
| `_system/README.md` | Shape-of-a-repo block, scripts table, doctrine bullets (incl. the stale "3 today" → the real ≤10 cap) |
| `CLAUDE.md`, `README.md`, `CONTEXT.md` | Series language replaced with path identity; PIPELINE.md routed |
| `workspaces/deliver/stages/day/CONTEXT.md` | Redesigned around positional status + `today.md` |
| `workspaces/deliver/stages/project/CONTEXT.md` | §5/§6 cut epics + stubs; gate surface is the breakdown |
| `workspaces/deliver/stages/conformance/CONTEXT.md` | Prefix steps out; profile awareness in; exemption wording fixed (`.icm/`, not `pipeline/`) |
| `workspaces/start/stages/06_repo/CONTEXT.md` | Prefix registration step deleted |
| `workspaces/deliver/CONTEXT.md` | Layer-3 table gains PIPELINE.md |
| `.claude/agents/ticket-scout.md` | Emits epic state + stub-shaped candidates |
| `_system/scripts/self-check.sh` | Ticket half validates epics/stubs/triage/today.md |
| `_system/scripts/tickets-board.sh` | Two-level walk, positional groups, `today.md` |
| `_system/scripts/ticket-hygiene.sh` | New lint set (epic structure, triage lanes, today.md, legacy-unmigrated) |
| `_system/scripts/icm-check.sh` | Prefix machinery deleted; triage + `.icm/CONTEXT.md` in the GAP set; `pipeline` profile seeding |
| `_system/scripts/estate-conformance.sh` | Mirrors the new GAP set |
| `_system/template/` | Rewritten baseline + new `icm-pipeline/` + `claude-pipeline/` trees |
| `_system/template/claude/hooks/*` | session-start walks epics; wrap-reminder keys on branch slugs (legacy ID fallback kept) |
| `_system/template/claude/skills/ticket-craft/SKILL.md` | Rewritten as stub/epic craft |
| `_system/template/claude/skills/pr-conventions/SKILL.md` | `_done/` rules updated |
| `.icm/intake/` (this repo) | Migrated: 9 open tickets re-homed into epics + triage; `_done/` untouched |
| `.icm/project.md` | Decisions D10–D13 appended; run-log row |
| `_system/AUDIT.md` | Open question 2 answered; generation table updated |
| jamienisbet `lib/tickets.ts` + `/tickets` page | Dual-shape parser, tree fetch, roster widening, `today.md`, sustentus included — its own PR |

Pre-existing contradictions fixed in the same pass: the day cap said 3 in
`_system/README.md` and 10 in `TICKETS.md` (10 is the contract); the sustentus exemption
named a `pipeline/` folder that doesn't exist (its pipeline lives in `.icm/`); the
exemption's "Sustentus-v2" naming normalised to sustentus.

## Migration plan (per repo, after the two PRs merge)

> **Superseded same-day by decision D14 (the clean slate).** Jamie chose to purge every
> legacy ticket — open and archived, estate-wide — rather than re-cut ("I don't mind
> losing them all; they were getting very noisy"). The purge ran in the same session:
> per-repo `Wrap:` commits straight to each `main`, security facts carried into
> `AUDIT.md`, the ICM-017 hook-wiring history carried into the seeding stub, and the
> estate-migration epic re-cut to `seed-estate-baseline` alone. Fresh backlogs arrive
> per repo from gated `/project` runs on demand. The plan below is kept as the record
> of what the re-cut path would have been.

Order matters only in that **the jamienisbet parser PR merges before any repo's tickets
migrate** — the parser is dual-shape, so migrated and unmigrated repos coexist
indefinitely. Per repo, migration is `/project`-shaped work at Jamie's gate: re-cut from
evidence (the standing drop-bias), don't convert mechanically.

1. **icm-board** — migrated in this PR (atomic with its own `self-check.sh`).
2. **jamienisbet** (7 open) — epics for the board evolution + leads-cockpit; triage for
   the one-offs. Cut JN work as new-shape stubs once its own migration lands.
3. **remi-ai** (18 open) — the consolidation: `.icm/intake/` re-cut into epics; decide
   whether the dormant 6-stage `pipeline/` tree is replaced by the `pipeline` profile
   (recommended — it has zero runs, and the template is its direct descendant).
4. **agorasim** (13 open) — epics; its `workspaces/` content factory is untouched.
5. **dungeons-dragons** (1 open), **casey-hebbel**, **collabimmo** (0 open) — trivial.
6. Dormant repos — nothing to migrate; next `--fix` seeds the new baseline files only.

Legacy flat tickets that survive a repo's migration are visible on the board (the legacy
parser path) and flagged by `ticket-hygiene.sh` as `legacy-unmigrated`, so progress is
measurable and never silent.

## Deliberately not done

- **`pipeline-full` is not templated.** The scope/approve front, close-out CI and label
  projection stay sustentus-only until a second repo needs a business author — the
  analysis showed the front is design-intent even in sustentus (zero runs through it).
- **No repo besides icm-board migrates in this change.** Each migration is a gated,
  per-repo re-cut.
- **Sustentus is untouched**, including drift found in passing (stale PR-template wording,
  persona vocabulary duplicated in four places, a contradictory SKILLS.md claim, an
  announce path never exercised against real changelog frontmatter). Reported to Jamie;
  its `.icm/` owns its semantics.
- **The dashboard stays read-only** — visualisation only, per the standing doctrine.
