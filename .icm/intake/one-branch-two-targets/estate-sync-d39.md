# Stub: The other pipeline repos take the D39 template — nothing else changes for them

- feature-slug: estate-sync-d39
- epic: one-branch-two-targets
- priority: P2
- size: M
- depends-on: template-two-targets, board-reads-main
- sequence: 4 of 4
- sources: D39 · `.icm/template-version` on remi-ai, sustentus, vinecliff, jamienisbet all at
  `de444cd` (2026-09-24) · none of the four declares `uat`

## Problem

Four pipeline repos carry the D31/D38 template without a UAT branch. Their scripts and skills
still describe the ticket PR and the UAT branch; their `project.json` carries the old `uat` stub
shape. After stub 1 the template stamp moves and `icm-check` reports them behind.

## Proposed change

- `icm-sync.sh --apply <repo>` one PR each: remi-ai, vinecliff, jamienisbet; sustentus on
  Jamie's word (its `.icm/` is authoritative, its T files synced like any repo's — D20).
- Canonical `.claude/` assets (`pr-conventions`, `ticket-craft`, `wrap-reminder.sh`) refreshed by
  hand in the same PR (D7).
- `project.json`: `uat: {target: "", url: ""}`; `type:promote` may stay in `labels.yml` unused,
  or go — one choice for all four. `.github/workflows/release.yaml` reference refreshed where a
  repo carries it (the PR-merge announce path is unchanged for them).
- Intake-only repos (no pipeline): the two skills only.
- Jamie merges each PR. Nothing else: no Vercel act, no UAT declared. Offering UAT to any of them
  is a separate `/setup` conversation.

## Acceptance criteria (rough)

- [ ] `icm-check.sh` clean across the estate: stamps at the D39 template, no skill drift
- [ ] `grep -rn 'ticket base\|promote-uat\|uat.branch' projects/*/.icm projects/*/.claude` empty
- [ ] One PR per repo, merged by Jamie; checkouts on `main`

## Prompt

In icm-board (`~/Apps`, local machine only — `projects/` is invisible to cloud sessions), carry out
stub 4 of the `one-branch-two-targets` epic: read the breakdown, this stub and decision D39 in
`.icm/project.md`. Sync remi-ai, vinecliff and jamienisbet to the D39 template with
`icm-sync.sh --apply`, refresh the three canonical `.claude/` assets by hand, one PR per repo;
sustentus only on Jamie's word. Declare no UAT anywhere. Commit each repo immediately and leave
every checkout on `main`.
