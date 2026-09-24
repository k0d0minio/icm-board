# Stub: validate-intake.sh should reject an epic slug the board already reserves (runs, triage, backlog)

- lane: chore
- found-by: jamienisbet bug lane `fix-board-runs-slug-collides-with-epic` · 2026-09-24 ·
  template-change guard (D33) — full account in
  `projects/jamienisbet/.icm/intake/triage/template-change-reserve-runs-epic-slug.md`
- priority: P2
- size: S

## Problem

The admin dashboard renders three pseudo-batches beside a repo's epics — `triage`, `backlog`
and `runs` (its `batchKind()`), and `_done/` is the intake archive. `triage batch` and Scope
both slugify a title, and nothing stops the result being one of those names: jamienisbet's
dashboard had to give its In flight pseudo-batch a slug no title can produce (`_runs`) to close
the UI-visible collision, but a stale stub's fallback in an epic actually named `runs` still
misresolves. `validate-intake.sh` (`T`) checks a batch's sequence, `depends-on` and build order
and never the scope slug itself, so the cut ships before anything catches it.

## Proposed change

A fifth invariant in `_system/template/icm-pipeline/scripts/validate-intake.sh`: the scope slug
(the folder's own name, never a stub's feature-slug) is not `runs`, `triage`, `backlog` or
`_done`. `RESULT: INVALID` naming the reserved word and pointing at the slugify step. `triage/`
itself stays the backlog it is; it is refused only when a `breakdown.md` shows a batch was cut
into it. Fixture: a scope dir named `runs` (and `backlog`, and `triage` with a breakdown) with one
valid stub → `INVALID`; an ordinary epic and the plain triage folder → unchanged `OK`.

## Prompt

In the icm-board repo (`~/Apps`), read `.icm/intake/triage/validate-intake-reserved-scope-slugs.md`
and `projects/jamienisbet/.icm/intake/triage/template-change-reserve-runs-epic-slug.md`, then
`_system/contracts/PIPELINE.md` → File-level ownership. Add the fifth invariant to
`_system/template/icm-pipeline/scripts/validate-intake.sh` and name it where the intake and Scope
contracts list the invariants. Prove it with the fixture above, ship on a `claude/` PR; after the
merge the operator syncs `projects/jamienisbet` and the other pipeline repos, retiring the
jamienisbet stub in that commit and this one in the PR.
