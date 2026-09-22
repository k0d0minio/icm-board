# Stack — the default technical shape of a delivery

*Layer-3 reference for sell `02_look`/`03_quote` (what a build implies) and start
`07_kickoff` (what gets set up). **Confirmed as policy 2026-08-26** from
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
  (`createClientRepo`), never by hand; baseline seeded by `icm-check.sh --fix`, brought up
  to the template by `icm-sync.sh --apply`, kept honest by the repo's own `/setup`.
- **Monitoring** — Sentry, for every build with state (it is what basic support is on
  call *from*).
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

## What a build with state ships with

Beyond the list above, every build that holds state — accounts, data, payments, a
booking flow, anything that can be *down* — silently includes, and `03_quote` prices once:

- The **fail-safe technical-difficulties page**: a static page the platform serves when the
  app cannot, saying so plainly and giving the contact route. Declared in the repo's
  `.icm/project.json` → `support.failsafe_page`.
- **Sentry** wired on the server and the client, the DSN a `[production]` key in
  `.env.example` and the repo's environment — never in git.
- The two together are what make basic support possible ([terms.md](terms.md) § Support
  after handover); a quote that offers the support line without them is a `03_quote`
  audit failure.

## Local tools the pipeline may use

Installed by Jamie on his machine, **never by a script**, and every script that needs one
reports `SKIP` with the install hint when it is absent:

- **pandoc** — markdown → DOCX for proposals and agreements
  ([`render-deal.sh`](../scripts/render-deal.sh)); the house look comes from
  `_system/knowledge/house.docx` when Jamie provides one (Q24), pandoc's default otherwise.
- **ffmpeg + whisper.cpp (`whisper-cli`)** — a client's voice note or screen recording →
  a transcript, locally, never uploaded (`process-raw.sh`'s audio and video kinds).

## Ceilings

Work the default stack (or a solo operator) can't honestly deliver — discovery flags
these `[BLOCKER]` on sight
(C5 in [discovery-questions](../../workspaces/sell/references/discovery-questions.md)):

- **Native mobile apps** — iOS/Android app-store builds are out of the web stack
  entirely; the honest answer is a responsive web app or a referral.
