# Stub: Roll D37 out — sync the estate, the operator's per-repo acts, prove it on berceo

- feature-slug: ticket-base-rollout
- epic: ticket-base-branch
- priority: P1
- size: L
- depends-on: template-ticket-scripts, board-scripts-ticket-base
- sequence: 4 of 4
- sources: breakdown · `gh api repos/k0d0minio/{berceo,agorasim}` 2026-09-23 — berceo public,
  agorasim private, both `allow_auto_merge=false`, default branch `main` · memory: berceo rulesets
  (the admin bypass on `main` exists for `Plan:`/`Wrap:` pushes and `sync`)

## Problem

Stubs 1–3 change the template and icm-board; no client repo changes until it is synced, and the
repo settings the new route needs (auto-merge, the label, the ignore step) are the operator's.
The dashboard still reads the default branch until the jamienisbet stub lands.

## Proposed change

1. **Prove first, on berceo** (a UAT repo): sync its T files (`icm-sync.sh --apply`); refresh
   `pr-conventions`, `ticket-craft` and `wrap-reminder.sh` by hand in the same PR (D7 forbids a
   script syncing them, not a reviewed PR); Jamie turns on "Allow auto-merge" and creates
   `type:tickets`; add the `.icm/`-only ignore step and confirm on a real ticket PR that it builds
   nothing, creates no Neon/Mongo preview database, and still leaves the `Vercel` status the merge
   gate requires. Then one real ticket PR end to end: armed, landed, visible on the board.
2. **agorasim** (the other UAT repo): the same, with the auto-merge fallback D37 names (private repo
   on the free plan).
3. **The rest of the estate**: pipeline repos by `icm-sync.sh --apply`, one PR each; canonical
   skills by hand; `type:tickets` label in each repo. Intake-only repos get the two skills.
4. **Rulesets**: with no `Plan:`/`Wrap:` or Scope push left on a client `main`, Jamie decides
   whether the admin bypass on `main` goes (berceo, and any repo that has one). `sync` still pushes
   `uat`.
5. **One-off check** on berceo and agorasim: every stub open on `main` but `_done` on `uat` is
   explained by the lag, not by a real gap; `promote-uat.sh status` clean.

## Acceptance criteria (rough)

- [ ] berceo: a ticket PR landed with auto-merge, built nothing, and shows on the board from `uat`
- [ ] agorasim: same, via its fallback
- [ ] `icm-check.sh` shows no `pr-conventions` / `ticket-craft` drift across the estate
- [ ] The dashboard stub in jamienisbet merged (the board reads the ticket base branch)
- [ ] A dated rollout note in `.icm/docs/` — repos changed, skipped and why, the ignore-step answer

## Prompt

In icm-board (`~/Apps`, local machine only — `projects/` is invisible to cloud sessions), carry out
stub 4 of the `ticket-base-branch` epic: read `.icm/intake/ticket-base-branch/breakdown.md`,
`ticket-base-rollout.md`, and the D37 entry in `.icm/project.md`. Prove the new ticket route on
berceo first (sync, skills by hand, one real `type:tickets` PR landed and visible on the board, the
`.icm/`-only ignore step checked against the required `Vercel` status), then agorasim, then the
rest of the estate one PR per repo. The repo settings — auto-merge, labels, rulesets, Vercel — are
Jamie's acts: list them and ask, never change them yourself. Sustentus only on Jamie's word. Commit
each client repo immediately (the `projects/` tree is shared with a sweeper) and leave every
checkout on `main`.
