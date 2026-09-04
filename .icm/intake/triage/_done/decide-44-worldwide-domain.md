* [ ] 

# Stub: Decide what happens to 44-worldwide.com

- lane: chore
- found-by: retiring the six orphan Vercel projects, 2026-09-03
- priority: P2
- sources: Vercel domains API on kodominio; `triage/_done/retire-orphan-vercel-projects.md`

## Problem

`44-worldwide.com` was the only custom domain on the retired `tenderdesk` project. It is
registered **through Vercel** (bought 2025-05-25), sits on `ns1/ns2.vercel-dns.com`, and
**auto-renews on 2027-05-25** — `renew: true`. Deleting `tenderdesk` detached it but did
not cancel the registration, so it now bills annually while serving
`404 DEPLOYMENT_NOT_FOUND` to anyone who visits.

The project it belonged to is gone, and so is its GitHub repo (`k0d0minio/tenderdesk`
does not exist in the org) — there is nothing left that explains what 44-worldwide was
meant to be. That context has to come from Jamie.

## Proposed change

Decide, and act on, one of three:

1. **Let it lapse** — turn off auto-renew in the Vercel dashboard; it expires 2027-05-25.
2. **Reassign it** — attach it to a live project if 44-worldwide is still a live idea.
3. **Keep it parked** — leave auto-renew on deliberately, and record *why* here so the
   next audit does not re-raise it.

Doing nothing is the same as (3) but without the reason, which is how it got flagged.

## Prompt

Decide what happens to the Vercel-registered domain `44-worldwide.com` on the kodominio
team. Read `.icm/intake/triage/decide-44-worldwide-domain.md` in the icm-board repo
(`~/Apps`) for context. It is orphaned — its project (`tenderdesk`) and GitHub repo were
retired on 2026-09-03 — and auto-renews 2027-05-25 while serving a 404. Report its
current registration state, then ask Jamie whether to let it lapse, reassign it, or park
it deliberately. Changing auto-renew or attaching the domain is Jamie's action, not the
session's. When it is settled, move this stub to triage's `_done/` in a ticket-only
commit to main.
