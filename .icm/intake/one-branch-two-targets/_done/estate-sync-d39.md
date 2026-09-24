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

## Notes from stub 1 (template-two-targets, 2026-09-24)

For the four repos without UAT the sync is the T files only; nothing in their behaviour changes
(`client-status.sh` output is byte-identical, the merge still ships). Two things still land:
`type:promote` in `.github/labels.yml` is reported as retired, not failed; a
repo that already carries the reference `release.yaml` should take the new one (the merge job now
also requires `announce_from: ci`, and a `release: published` event on a repo without UAT is a
no-op notice — report.sh's own Releases, created with a PAT, trigger it).

## Progress (2026-09-24, first session)

- **Three PRs open, unmerged — the operator merges:** k0d0minio/remi-ai#126,
  k0d0minio/vinecliff#20, k0d0minio/jamienisbet#153 — each `icm-sync.sh --apply` at icm-board
  `0db8a71` (30 T files, `promote.sh` + `_shared/promotion.md` new, `promote-uat.sh` +
  `uat/CONTEXT.md` `git rm`'d), `uat: {target: "", url: ""}`, the T files and canonical skills
  checked byte-identical to the template on each branch. Every checkout back on `main`.
- **Canonical assets: five, not three.** `pipeline` and `setup` (`claude-pipeline/`) changed in
  stub 1 too and were byte-identical to their pre-D39 canonical in all three repos, so they were
  refreshed with `pr-conventions`, `ticket-craft` and `wrap-reminder.sh`.
- **`labels.yml`, one choice:** `type:promote` removed (only vinecliff carried it);
  `type:tickets` kept, described as retired; vinecliff's `type:hotfix` no longer names UAT. The
  GitHub labels themselves are untouched.
- **remi-ai `release.yaml`:** the D39 reference with remi-ai's edits carried over (Slack in every
  announce/alert step, changelog H1 + docs link) and the `migrate` job deleted — no
  `db-migrate.yml` there, and a `uses:` to a missing file would invalidate the workflow.
  Recorded in its `project-rules.md`. vinecliff's `db-migrate.yml` and jamienisbet's
  `db-migrations.yml` left alone (without UAT, push-to-main migration stays right).
- **Repo-owned words fixed** where they named the retired files or the ticket PR: routers
  (`.icm/CONTEXT.md`), remi-ai `SKILLS.md` + `settings.json` (`promote-uat.sh` → `promote.sh`),
  jamienisbet `AGENTS.md` + `intake/README.md`.
- **Parked:** jamienisbet `triage/tickets-board-reads-main` (the dashboard still probes
  `uat.branch` and tells readers to "land a ticket PR"); icm-board
  `triage/intake-contract-ticket-pr-wording` (two stale phrases in a T file).
- **Acceptance grep, read literally, never empties:** `uat.branch` matches `uat_branch` (D39's
  named-database key) and the template names the retired key/files on purpose to refuse them
  (`setup.sh`, `lib/project.sh`, `promotion.md`, `MANIFEST`, `setup` skill). What remains
  outside those is the two phrases parked above.
- **Stamp behind already:** `7eb9541` (D40 stub 1) added `_shared/output.md` (T) after this
  sync, so `icm-check` will report it missing in all three; inert until D40 stub 2, whose sync
  carries it.
- **Left:** Jamie merges the three PRs; sustentus only on Jamie's word.

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
