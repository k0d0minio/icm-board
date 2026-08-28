# Stub: Untrack barzinho's P&L PDFs

- lane: chore
- found-by: estate audit (AUDIT.md security P0) · 2026-08-28 recut from ICM-008
- priority: P0

## Problem

AUDIT.md open security P0: barzinho's P&L PDFs are git-tracked — the `.gitignore`
pattern stopped matching after the files moved to `shared/profit-and-loss/`. Work
happens in `projects/barzinho` (separate repo, Jamie's machine only). Scope is
deliberately split: untrack + pattern fix go now; a **history scrub** stands on its own
merits (the deal is dead — AUDIT.md, barzinho answered 2026-08-26) and is Jamie's call
once the remote question is answered.

## Proposed change

`git rm --cached` the PDFs, fix the `.gitignore` pattern, commit in that repo; report
whether a remote exists (scrub urgency); update AUDIT.md here.

## Prompt

Untrack the git-tracked P&L PDFs in the barzinho client repo. Read
.icm/intake/triage/untrack-barzinho-pnl-pdfs.md (and the archived original
.icm/intake/_done/ICM-008-untrack-barzinho-pnl-pdfs.md) for full context. Work in
projects/barzinho (local machine only): git rm --cached the PDFs under
shared/profit-and-loss/, fix the .gitignore pattern, commit in that repo, and report
whether the repo has a remote so Jamie can decide on a history scrub — do not rewrite
history yourself. Update _system/AUDIT.md's security section in this repo (doc-only
commit straight to main).
