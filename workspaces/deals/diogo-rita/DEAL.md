# Diogo & Rita — deal (Agorasim)

| | |
|---|---|
| Ladder | client |
| Stage | — in delivery; the client-relationship artifacts live here |
| Adopted | 2026-08-27, reconciliation pass |
| Shape | fixed-price €2,000 (six features) + commission: 4% tours (min €10, cap €50) · 6% events |
| Value | €2,000 + running commission from first live booking |
| Source | pre-system — direct relationship |
| Company | Agorasim — guided classic-car tours, Saloia region (Sintra · Mafra · Ericeira) |
| Contacts | Diogo +351 926 210 707 (account owner: Diogo Santos Trajano) · Rita +351 919 272 077 · info@agorasim.pt |
| Repo | k0d0minio/agorasim |

*(Folder slug covers both principals; rename to a single name if the `01_intake`
naming rule should apply strictly.)*

## The deal, precisely
- **Accepted**: the 23 Jul 2026 "Digital Platform, Booking & Commission Partnership" —
  six features valued €5,900, charged €2,000 flat. Canonical copy in the client repo,
  `.icm/files/AgorasimProposal.docx` (+ PDF in `.icm/docs/`).
- **Commission instrument**: the Commission & Payments Agreement (27 Jul) — Stripe
  Connect application fees on Agorasim's own account, proportional refund of
  commission, begins with the first live booking. **Never signed; signing is
  deferred for the time being — it remains the intended instrument** (Jamie,
  2026-08-27).
- **Dead**: the July "Digital Growth Platform" proposal (€7,900 à-la-carte). Killed
  and deleted from the client repo 2026-08-27 — nothing in it is quotable. Its
  add-ons (gift vouchers, review wall, …) are **not** in scope.

## Current objective (2026-08-27)
- **No new promised date.** The objective is a first working version for their
  testing **ASAP**: sandbox payments working at **agorasim.jamienisbet.com** (the
  current production URL), booking end-to-end.
- **The agorasim.pt switch is independent of development** — Diogo & Rita are
  recovering the domain from their previous provider. When it lands: DNS cutover +
  flip to live Stripe keys.
- Stripe: they have not created their account yet; development runs against a
  sandbox in Jamie's account. Their account (+ the Connect commission wiring) is
  needed before real money moves.

## Log
- 2026-07-23 — deal accepted (€2,000 + commission).
- 2026-08-10 — launch plan + information request sent.
- 2026-08-18 — their Section 1/2 answers arrived (info PDF, prices PDF); booking
  engine landed on `main`.
- 2026-08-24 — original launch target passed; open-questions pack drafted but
  **never sent**.
- 2026-08-27 — reconciliation: this folder created; open-questions pack moved here
  from the client repo (updated — photos have since landed in the repo, Olaria MZ
  confirmed out); dead proposal deleted; tickets rescoped to the sandbox-first
  objective. Weddings deposit terms: **using sensible defaults until confirmed**.

## Open
- Send `open-questions.md` (WhatsApp-ready). Answers unblock the availability model
  (big groups / seat sharing), the weddings deposit terms, the social auto-poster
  (IG/FB access — Meta review takes weeks), and the privacy policy's draft banner
  (written legal facts).
- Chase their Stripe account creation when the time comes to go live.
- Domain recovery status — theirs to drive; ask alongside the pack.
