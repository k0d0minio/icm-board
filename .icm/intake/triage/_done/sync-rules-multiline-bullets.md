# Stub: run-pack.sh --sync-rules keeps only the first line of a wrapped learned rule

- lane: chore
- found-by: jamienisbet run `epic-view` Build, reading `master-detail-shell`'s synced rules ·
  2026-09-24 · template-change guard (D33) — full account in
  `projects/jamienisbet/.icm/intake/triage/template-change-sync-rules-multiline.md`
- priority: P2
- size: S

## Problem

`run-pack.sh --sync-rules` (`T`) reads a run's `FAILURE.md` → `## Learned rules` with
`grep -E '^- '`, so a bullet wrapped onto indented continuation lines lands in the repo's
`_shared/project-rules.md` cut mid-sentence — two of jamienisbet's rules did, and Build reads
that section before its first edit with the standing of the code rules. `retrospective.sh`'s
`- rule:` reader already joins an indented continuation and is not affected.

## Proposed change

Read each bullet whole — the `- ` line plus every following indented line up to the next bullet,
blank line or heading — joined into one line with continuation whitespace collapsed, before the
`known` check and the append; judge `known` on the same joined view of `project-rules.md`, so a
rule a formatter wrapped there since is still known. The template placeholder is still skipped.
Fixture: a three-line rule syncs as one line ending in its closing punctuation; a second run
reports it `known`.

## Prompt

In the icm-board repo (`~/Apps`), read `.icm/intake/triage/sync-rules-multiline-bullets.md` and
`projects/jamienisbet/.icm/intake/triage/template-change-sync-rules-multiline.md`, then
`_system/contracts/PIPELINE.md` → File-level ownership. Change the `sync)` branch of
`_system/template/icm-pipeline/scripts/run-pack.sh` as proposed and confirm
`_system/template/icm-pipeline/scripts/retrospective.sh`'s `- rule:` reader joins a continuation.
Prove it with the fixture above, ship on a `claude/` PR; after the merge the operator syncs
`projects/jamienisbet` and the other pipeline repos, retiring the jamienisbet stub in that commit
and this one in the PR. The two truncated lines already in jamienisbet's `project-rules.md` are
project-owned and repaired there, from `.icm/runs/_done/master-detail-shell/FAILURE.md`.
