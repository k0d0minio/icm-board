# Diogo & Rita (Agorasim) — client

- client: agorasim
- company: Agorasim — guided classic-car tours, Saloia region
- contacts: Diogo (account owner) · Rita
- repo: k0d0minio/agorasim
- language: pt
- engagement: agorasim-v1
- source: adopted

## Engagements
| slug | shape | started | ended | outcome |
|---|---|---|---|---|
| agorasim-v1 | one-off (€2,000 flat, six features) + partnership (commission — instrument unsigned, deferred) | 2026-07-23 |  | in delivery; sandbox-first objective; open questions pack unsent |

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
- 2026-08-29 — /project first run on the repo: register written, 11 epics + triage
  cut (see agorasim `.icm/project.md`); GitHub repo flipped **private** (had been
  public with the deal documents in it); question pack amended, still unsent.
- 2026-08-31 — **controlpanel.pro password rotated by Diogo**, confirmed by Jamie.
  Precautionary: it had been in the info PDF while the client repo was public
  (until 2026-08-29). Asked over WhatsApp in PT; Diogo changed it himself and the
  new credential is held by the client only — it is in no repo and no chat log.
  Closes agorasim `secure-client-data/rotate-registrar-credential`; the paired
  `untrack-credential-pdfs` (remove the now-dead password from the tracked PDF,
  decide the history purge) is still open.
- 2026-09-22 — re-cut to the dash-field schema (D24): Ladder, Stage and Value rows retired; artefacts moved into the engagement folder with a provenance line each; nothing deleted.
- 2026-09-22 — the old table's Contacts row carried two phone numbers and an email; `DEAL.md` no longer holds contact details (the Neon row does — deals/README.md § Rules).
- 2026-09-23 — folder renamed from `diogo-rita` to `agorasim`: the slug is now the repo name (Jamie's decision, 2026-09-23; decision D27).

## Notes (adopted)

*The sections below are the adopted `DEAL.md`'s (before the 2026-09-22 re-cut), kept verbatim; the Ladder, Stage and Value rows of its table were retired — the rung is Neon's, the value lives in the quote.*

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

## Open
- Send `open-questions.md` (WhatsApp-ready; **amended 2026-08-29** — now 12 items:
  pricing PAX semantics, Óbidos times, cancellation behaviour, photo re-send and two
  small checks added). Answers unblock the availability model (big groups / seat
  sharing), real-money pricing correctness, the weddings deposit terms, the social
  auto-poster (IG/FB access — Meta review takes weeks), and the privacy + terms
  draft banners (written legal facts).
- Sign the Commission & Payments Agreement before Connect fees activate (agorasim
  register D16).
- Chase their Stripe account creation when the time comes to go live.
- Domain recovery status — theirs to drive; ask alongside the pack.
