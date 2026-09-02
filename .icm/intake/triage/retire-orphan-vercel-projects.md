# Stub: Retire six orphan Vercel projects on kodominio

- lane: chore
- found-by: Vercel env research session 2026-09-02 · Jamie's ruling same session
- priority: P2
- sources: `vercel projects ls --scope kodominio` / Vercel MCP listing 2026-09-02

## Problem

Eight kodominio Vercel projects have no repo in `projects/` anymore. Jamie's call:
six are dead and should be retired — **tenderdesk, houseoftherisingmojo,
personal-portfolio, shake-easy, ericeirafishing, curated-property-booking** — while
courseday and pierpont come back to disk instead (separate stub,
`triage/adopt-courseday-pierpont.md`). Left alone, the six keep muddying every
estate-wide Vercel listing and the env system's audit.

## Proposed change

For each of the six: gather what retirement destroys — custom domains attached,
last deployment date, linked GitHub repo — and present the summary. **Deleting a
Vercel project is irreversible (deployments, domains, env vars go with it), so the
actual deletions are Jamie's, per project, after reading the summary** — via dashboard
or a per-project confirmed CLI call; never batch-deleted by an agent. GitHub repos are
untouched — this retires deployments, not code.

## Prompt

Prepare the retirement of six orphan Vercel projects on the kodominio team:
tenderdesk, houseoftherisingmojo, personal-portfolio, shake-easy, ericeirafishing,
curated-property-booking. Read .icm/intake/triage/retire-orphan-vercel-projects.md in
the icm-board repo (`~/Apps`) for context. For each project, report custom domains,
last deployment age and the linked GitHub repo, then stop — present the summary and
let Jamie perform or individually confirm each deletion; do not delete anything
unprompted. GitHub repos stay. When all six are gone, move this stub to triage's
`_done/` in a ticket-only commit to main.
