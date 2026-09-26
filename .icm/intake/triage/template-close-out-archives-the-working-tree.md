# Stub: close-out.sh archives the working tree, not the index — the usage end line rides the move

- lane: bug
- found-by: template-change (agorasim triage/template-change-close-out-usage-end-line · sustentus triage/template-change-close-out-stages-usage-end) · 2026-09-26
- priority: P1
- complexity: low
- sources: agorasim commit 8ba2ccc (run fix-move-back-suppresses-reminder) · sustentus PRs 1168, 1189, 1202 (close-out commits archiving `usage.md | 0`)

## Problem

`_system/template/icm-pipeline/scripts/close-out.sh` moves the run with `git mv`, which carries
the **index** copy of each file. The lanes and Release write `usage-snapshot.sh <slug> <stage> end`
into `.icm/runs/<slug>/usage.md` immediately before the close-out, and nothing stages that append
(the script stages only `_shared/project-rules.md`, line ~212), so the archived `usage.md` loses its
end line and the working tree is left dirty. Five runs across two repos hit it in two days; each
needed a follow-up commit, one a follow-up PR. Every stage-pair cost in `run-economics.sh` is
undercounted until the line lands.

## Proposed change

Before the `git mv`, `git add -A -- ".icm/runs/$slug"` so whatever is on disk at call time rides
the archive move; add a fixture to `icm-sync-branch-guard.sh`'s style of throwaway repo: append a
line to a tracked file in a run folder, run `close-out.sh`, assert the archived commit contains it.
Then `icm-sync.sh --apply` per repo; the two source stubs retire with `- superseded-by:` in those
sync commits.
