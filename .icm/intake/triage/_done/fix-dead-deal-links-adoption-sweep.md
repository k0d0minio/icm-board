# Stub: Repoint the adoption-sweep doc's links after the deal-folder renames

- lane: chore
- found-by: security-gate session (PR #49 merge of main) · 2026-09-23
- priority: P2

## Problem

`main`'s Self-check has been red since the `Deal:` commits of 2026-09-23 renamed
`workspaces/deals/{rui-matias,alix-hahusseau,billy-carlson,diogo-rita}` to their repo slugs
and removed `{dragon,alex-valexo,karen,jerome,magali}`: `.icm/docs/2026-08-26-icm-011-adoption-sweep.md`
still links each old `DEAL.md` — eight dead links, reported by `_system/scripts/self-check.sh`.
Every PR that merges `main` in now reds on it; none of them caused it. May already be fixed by
the deal session that made the renames — check `main` before acting.

## Proposed change

In that one doc: point the four renamed links at the new folders and unlink the five removed
ones (keep the names as plain text — the doc is a dated record). Nothing else.

## Prompt

In the icm-board repo (`~/Apps`), fix the eight dead links `_system/scripts/self-check.sh`
reports in `.icm/docs/2026-08-26-icm-011-adoption-sweep.md`: repoint the links to renamed deal
folders (`rui-matias→kau-american-bbq`, `alix-hahusseau→berceo`, `billy-carlson→vinecliff`,
`diogo-rita→agorasim`, `remi→remi-ai`) and turn the links to removed folders (`dragon`,
`alex-valexo`, `karen`, `jerome`, `magali`) into plain text. Run `self-check.sh` to confirm
zero problems, commit as a ticket-only `Wrap:` commit straight to `main`, and move this stub
to triage's `_done/`. If `main` already passes, just move the stub.
