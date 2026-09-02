# Stub: Untrack garmani's .env — the only tracked env file in the estate

- lane: chore
- found-by: Vercel env research session 2026-09-02 (estate .env hygiene scan)
- priority: P0
- sources: scan 2026-09-02 — `projects/garmani/.env` is git-tracked and not
  gitignored, 1 variable; contents unread (protected from session reads), so severity
  is unconfirmed. Precedent: `triage/_done/untrack-barzinho-pnl-pdfs.md`

## Problem

`projects/garmani/.env` is tracked in git — the only tracked env file across all 24
estate repos (every other repo uses a properly ignored `.env.local`). It holds one
variable whose value could not be inspected from the session that found it, so it must
be treated as a possible plaintext credential in history until Jamie or a local
session confirms otherwise. Estate rule: no secrets in git, ever.

## Proposed change

In `projects/garmani` (separate repo, Jamie's machine only): inspect the variable; if
it is a secret, rotate it at the provider and move the value to the garmani Vercel
project (kodominio team) with a note, per the env system conventions once available —
a plain `vercel env add` before then. Either way: `git rm --cached .env`, add the
ignore pattern, commit in that repo. Report whether the repo has a remote so Jamie can
decide on a history scrub — do not rewrite history. Record the finding and outcome in
`_system/AUDIT.md`'s security section here (doc-only commit straight to main), the
barzinho precedent.

## Prompt

Fix the tracked env file in the garmani client repo. Read
.icm/intake/triage/untrack-garmani-env.md in the icm-board repo (`~/Apps`) for full
context. Work in projects/garmani on Jamie's machine: inspect the single variable in
.env; if secret, tell Jamie to rotate it and move the value to the garmani Vercel
project before you untrack — then git rm --cached .env, fix .gitignore, commit in that
repo following its conventions, and report whether a remote exists (scrub urgency) —
never rewrite history yourself. Update _system/AUDIT.md's security section in
icm-board and move this stub to triage's `_done/`, both in a ticket-only commit to
main.
