# Stack — the default technical shape of a delivery

*Layer-3 reference for sell `02_discovery`/`03_quote` (what a build implies) and start
`06_repo` (what gets set up). **Confirmed as policy 2026-08-26** from
[`../setup/questionnaire.md`](../setup/questionnaire.md) § Stack (ICM-009). Defaults,
not law — a deal that needs different says so in its folder, and the repo's own
contracts win once it exists.*

## The default build

- **Web** — Next.js on Vercel; TypeScript.
- **Data** — Neon Postgres (Drizzle) where an app needs state; none where a site doesn't.
- **Auth** — Clerk, only when the product needs accounts.
- **Email** — Resend.
- **Payments** — Stripe, always — it is also the business's money source of truth.
- **Repos** — GitHub under `k0d0minio`, created by the admin dashboard
  (`createClientRepo`), never by hand; baseline seeded by `icm-check.sh --fix`.
- **CI** — checks on push; CI is the source of truth, local builds are not run.

Deviations are named per deal in the quote and inherited by the repo's own contracts.

## What a client site ships with

The invisible scope every quote silently includes — listed here so `03_quote` prices it
once instead of forgetting it per deal. Confirmed 2026-08-26:

- Domain + DNS wired, HTTPS, redirects from old URLs where they exist.
- Analytics or none — client's call, recorded per deal; consent handling where required
  (EU context, see [contracts/LENSES.md](../contracts/LENSES.md) § legal).
- Privacy page and contact route appropriate to the site's data collection.
- A `.icm/` + `CLAUDE.md` baseline in the repo, so the estate's process reaches it.

## Ceilings

Work the default stack (or a solo operator) can't honestly deliver — discovery flags
these `[BLOCKER]` on sight
(C5 in [discovery-questions](../../workspaces/sell/references/discovery-questions.md)):

- **Native mobile apps** — iOS/Android app-store builds are out of the web stack
  entirely; the honest answer is a responsive web app or a referral.
