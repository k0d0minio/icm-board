# Berceo — quote (sell/03_quote)

*Stage artifact. Scope + shape + number, decided before any prose. The client-facing
document is [`04-devis-berceo.md`](04-devis-berceo.md) and never renegotiates this.*

| | |
|---|---|
| Client | Berceo — SRL, BCE 0801 875 541 |
| Contacts | Alix Hahusseau (+32 491 12 25 44) & Jordane — decisions taken jointly, by email |
| Service | Web application ([services.md](../../../_system/knowledge/services.md)) |
| Shape | Fixed-price |
| **Number** | **€7.500** |
| Commitment | 5 h/week guaranteed, 16 weeks |
| Window | 7 September 2026 → live 1 January 2027 |
| Hosting | Jamie-hosted, rebilled at cost monthly, **capped at €50/month** during development, receipts provided |
| Repo | `k0d0minio/berceo` |

## Scope source

There are no `02-discovery-notes.md`. The discovery ran in the repo instead, and the
client has declared two documents the source of truth as of 2026-08-27:

- `projects/berceo/.icm/docs/cahier-des-charges.md` — their spec, with their annotations
- `projects/berceo/.icm/docs/berceo-answers.pdf` — 40 pages answering
  `DECOUVERTE-BERCEO.md`

Every scope line below traces to one of those two. Question numbers in brackets refer to
the answers document.

## What the answers changed

The annotated cahier and the answers disagree in places; the answers win. Net effect on
build size:

**Out** (was in the cahier, is not in V1) — itsme [7.3, 6.4] · Stripe Connect and any
transfer to professionals [9.1] · escrow, mission-start codes, end-of-mission validation
[4.1] · gift cards [9.5, 11.5] · professional subscriptions [7.5, 11.5] · the €100–300
slider, replaced by a €130 floor with no ceiling [4.1] · interactive map, replaced by
zone + radius search [15.5, 14.2] · per-commune SEO pages [13.5] · Dutch and English
[6.10] · public written reviews [11.4] · AI-assisted document triage [8.3] · reference
checks [8.4].

**In** (was not in the cahier, is now required) — four family subscription tiers with
real prices [4.3] · a Berceo credit ledger, 24-month validity [9.2] · a full
cancellation / no-show / dispute rule table, with a parameterised 24 h window [9.2, 9.3]
· a professional availability calendar [7.4, 11.1] · 2FA for professionals and admins
[10.9] · dual-sided star ratings on four criteria each [11.4] · an admin action log
[10.10] · every screen designed by me from Surya's moodboard, no mockups exist [12.2] ·
all French product copy written by me, first pass [12.3].

Net: the answered V1 is **larger** than the cahier, not smaller.

## Scope — what is built

Everything the answers ask for. Grouped as the client will read it.

**1. Public site** — accueil · comment ça marche · tarifs · FAQ · shells for the legal
pages they will write themselves · cookie/consent mechanism sized to whatever the V1
actually sets [13.7] · a teaser of real professional profiles for non-subscribers,
showing first name, profession, zone, seniority and star rating only [13.4] · clean
metadata and speed, no per-commune pages.

**2. Accounts** — family and professional signup, verified email and phone, password
reset, 2FA (mandatory for professionals and admins), role separation, CGU/privacy
consent stored with version and timestamp [6.2, 7.3, 10.9].

**3. Professional profile and verification** — profession, specialisations, photo,
presentation, commune, travel radius (10/20/30/40/50 km or all Belgium), languages,
experience, night rate and supplementary hourly rate [7.3, 7.8]. Document upload:
diploma or school certificate, INAMI number, criminal-record extract 596.2, sworn
declarations as checkboxes [7.3]. Four accepted categories only: midwife, nurse with
infant experience, childcare worker (*puéricultrice*), 3rd/4th-year midwifery student
[7.1]. Nothing is visible until Berceo approves it.

**4. Verification back-office** — the queue Berceo lives in: their seven-point checklist,
approve / refuse / request more, refusal reasons, automatic status emails to the
professional, and a link out to the public INAMI lookup [8.1, 8.2].

**5. Availability calendar** — simple internal month grid, optional to complete,
indicative only, confirmed by the professional on acceptance. No external calendar sync
[7.4, 11.1].

**6. Search** — by one of the ten zones (Bruxelles-Capitale, Brabant wallon, Hainaut,
Brabant flamand, Anvers, Flandre orientale, Flandre occidentale, Limbourg, Namur, Liège)
with commune as a secondary filter, matched against each professional's radius [14.2,
7.8]. Full profile and contact behind an active subscription [9.4].

**7. Requests** — the family publishes a *annonce*: date, start and end time (11 h base
night, supplementary hours beyond), one-off or simple recurrence, number of babies
(single/twins/triplets), age, commune or postcode, type of professional sought [6.5,
6.6]. Same-day "urgence" publishing, no minimum or maximum notice [6.7]. Structured
fields, dropdowns and checkboxes — free text kept to a minimum. Edit and cancel while
unassigned.

**8. Matching** — professionals in the zone see the annonce and apply; the family
compares applicants and selects one; the annonce closes on confirmation and can be
republished if nobody suits [11.2]. A family that already has a professional in mind can
address the annonce to her as a priority while it stays visible to others — one annonce
object, one flow [11.2]. Favourites and rebooking of a known professional [6.8].

**9. Booking** — confirmation by both parties, then and only then the exact address and
full contact details are revealed, in the reservation space and in the messaging [7.11].

**10. Messaging** — a thread opens when a professional applies; closes automatically
after the garde and stays readable; a new request opens a new thread [11.3]. Read/unread
state, Berceo's automatic pre-garde message, email notification on each new message.
Page refresh is acceptable — no realtime [15.2]. No blocking of phone numbers or emails
[10.6].

**11. Emails** — one on every account event: signup, verification result, application,
selection, confirmation, message, cancellation, no-show, subscription receipt, and the
post-garde review request [15.4, 15.3]. Email only, no SMS or WhatsApp. Sending domain
configured properly so it does not land in spam [15.6].

**12. Money** — 3 % service fee, changeable without a deploy, charged to the family only,
at confirmation by both parties [9.1]. Four family subscriptions — Découverte 1 month
€24,90 · Parenthèse 3 months €59,90 · Sérénité 6 months €94,90 · Premium 12 months
€159,90 — auto-renewing, no cap on requests [4.3, 9.4]. Bancontact, cards, Apple Pay,
Google Pay [9.6]. Failed payment: Stripe retries, email, 7-day grace, then subscriber
features cut while confirmed bookings stand [9.7]. Invoices via Stripe's own tooling
[9.8]. The garde itself is settled directly between family and professional — the agreed
rate is displayed for the record and nothing more; Berceo suggests no payment method
[9.9].

**13. Credits, cancellations, no-shows** — their full rule table, implemented as written
[9.2, 9.3]: family cancels >24 h → credit; <24 h → fee retained; professional cancels at
any time → credit; either party no-show → the corresponding rule plus a report;
contested → *litige* status for manual review; force majeure and Berceo-initiated
cancellation → credit. Credits valid 24 months and spendable on any future booking. Two
distinct buttons — *Annuler* before the start time, *Signaler une absence* only from the
start time. The 24 h threshold is a setting, not code. Full history: date, time, author,
reason, status.

**14. Ratings** — both directions, stars only, no free text [11.4]. Professionals rated
on ponctualité, professionnalisme, communication, confiance et respect des consignes;
families on communication, respect des horaires, respect de la professionnelle,
conformité de la garde. Visible as soon as one side has rated.

**15. Admin** — dashboard over active annonces, bookings, payments and recent accounts ·
user search · suspend, reactivate, block from booking, ban · force a re-verification ·
view bookings and payments · reports and *litiges* · ratings · an action log recording
date, action, account and administrator [10.10, H-01…H-04].

**16. Data and GDPR** — EU hosting, data export and deletion, retention and deletion of
verification documents, consent records. No health data anywhere; a single "mon enfant
n'a pas de condition médicale particulière" checkbox instead [6.3]. No photographs of
children anywhere [10.8].

**17. Content** — first-pass French for the whole product: signup, automatic emails,
error messages, FAQ, safety pages — from Surya's editorial and SEO brief, for her review
and the founders' final validation [12.3].

**18. Schema headroom** — the database is shaped so garde payments could later run
through the platform with funds held until the garde is done, without a migration. Not
built, not switched on [9.10].

## Not included

Named so it is never argued later. Their own deferrals first:

- Gift cards · professional subscriptions · referral and promo codes · public written
  reviews · AI-assisted document triage · in-app dispute tooling beyond the *litige*
  status · admin private notes and the quality dashboard · an interactive map ·
  per-commune SEO pages · a blog · a CMS ("on demande au dev suffit" [15.1]) · Dutch and
  English · a native mobile app · daytime care · anywhere outside Belgium · itsme or any
  third-party identity check · escrow or any payment for the garde itself.
- **Standing exclusions** — legal drafting (CGU, privacy policy, cookie policy,
  contracts) · brand and graphic design (Surya's) · photography · content beyond the
  first French pass · SEO beyond clean structure, metadata and speed · third-party
  running costs (hosting, Stripe fees, email, domain, insurance) · marketing.
- **Post-launch** — hosting, support, monitoring, statistics and data extraction are
  asked for [2.7] and are **not** in this price. They are the retainer conversation,
  quoted separately before go-live.

## Number

**€7.500 fixed**, for the scope above — presented to them as **€9.600 at full rate,
reduced by €2.100**.

**Second deviation, named — an hourly rate is quoted at the client.**
[pricing.md](../../../_system/knowledge/pricing.md) states plainly that no day or hourly
rate is offered and that time-and-materials is deliberately not sold. This quote breaks
that: it names **€120/h**, multiplies it by the 80 committed hours to reach €9.600, and
shows €7.500 against it. Jamie's call, 2026-08-27, and it is a real trade — the anchor
makes the reduction legible, at the cost of inviting an hourly conversation later. The
engagement itself remains fixed-price; the rate is an anchor, never a billing basis.

**The discount is a decision**, per pricing.md: €2.100 off, granted because they fund the
build from personal savings, because half the fee already rides on their launch, and
because the relationship is meant to run past V1. Future quotes should read this as
precedent for a founder-funded first build, not as a standing rate.

**Deviation, named.** [pricing.md](../../../_system/knowledge/pricing.md) does not band
web applications — the method is scope, then precedent from `workspaces/deals/`. There is
no comparable precedent: the largest priced deal in the folder is diogo-rita at €2.000
plus commission, then casey-hebbel at €1.200/€2.400. **Berceo is the largest deal the
business has quoted.** The number is therefore set from scope and capacity, not from
precedent, and that is the deviation:

- 5 h/week × 16 weeks = **80 hours committed**, ≈ €94/h implied.
- Built through the ICM pipeline on the house stack, where Clerk absorbs auth, phone
  verification and 2FA, Stripe Billing absorbs the four tiers and the dunning, and
  Belgium is small enough that postcode centroids replace a geospatial extension.
- It sits **€6.500 below their stated €14.000 ceiling** [3.1] — deliberately. They have
  no separate budget for a lawyer, insurance or running costs [3.2, 3.3], and every one
  of those is a launch condition. Leaving the headroom is the point, and it is worth
  saying to them.
- Well under the Belgian market for the same scope (agencies quote €25–70k; senior local
  freelance runs €100–140/h). That gap is the argument, not an apology.

**Options.** None. They asked for a V1; the answers describe one coherent V1; the price
is under budget. Offering a smaller version here would invite a negotiation the number
does not need.

## Terms deltas

Against [terms.md](../../../_system/knowledge/terms.md):

| Term | Standard | This deal |
|---|---|---|
| Payment | 50% deposit, 50% at handover | 50% (€3.750) at start · 50% (€3.750) at **the earlier of** the traction milestone **or** 120 days after go-live — **named deviation** |
| Milestone | — | 25 active paying family subscriptions **and** 25 confirmed bookings on the platform |
| Revisions | two rounds | **not counted** — 5 h/week is continuous development, not a build-then-revise cycle. In-scope defects fixed regardless, as standard. |
| Ownership | must be named | **Jamie-hosted** — code and content are Berceo's; Vercel, Neon, Clerk, Resend and the domains sit in Jamie's accounts. **Stripe is the exception and is in Berceo's name** — their subscription revenue must not make Jamie merchant of record. |
| Timeline | dated from deposit paid + materials received | unchanged, and it matters here — see Conditions |
| Support | not established | explicitly out. Presented to them as the **equity conversation** rather than a monthly invoice — see below. |

**On the deferred half.** Half the fee is exposed to their launch traction in a market
the earlier report calls thin — declining births, subsidised alternatives, no paid
marketing budget [13.7], acquisition resting on a 1.400-member Facebook group. The
120-day longstop is what stops it becoming an unpaid stake in their marketing. It is
still the most exposed deal the business has taken.

**No NDA, no portfolio use until launch** [2.5] — accepted as written; Berceo cannot be
cited as a reference until the platform is live.

**Equity** — they raised it themselves [2.6, 3.1]. The client document now names it as the
way to cover post-launch labour, with no numbers and no commitment either side. Opening a
door, not a term. **`[LAWYER]` before any percentage is discussed**, per terms.md.

## Conditions on the date

1 January 2027 holds only if the start is **7 September 2026**, which needs the deposit
paid and, in the same week: Surya's web moodboard and visual brief [12.1, 12.2], the
brand files, the editorial and SEO brief [12.3], and the transfer of berceo.be and
berceo.eu from the previous developer [15.6]. Each week those slip moves the date.

Also on the date: the window straddles Christmas and New Year, and 1 January is a poor
day to open a marketplace. Worth proposing a soft launch in mid-December with the public
push in January.

## Blockers carried into the deal

Not mine to resolve, and each is a real launch condition.

1. **Section 5 of the discovery questionnaire — the legal chapter — is entirely
   unanswered.** Nine questions, several tagged blocking: ONE / Kind & Gezin
   declaration for regular overnight in-home care; the professionals' self-employed
   status against the EU Platform Work Directive (transposition due 2 December 2026);
   the collaborative-economy regime; DAC7; undeclared-work exposure; who drafts the CGU;
   DSA obligations; the platform-to-business ranking-transparency rules; and the European
   Accessibility Act. At [12.6] they say they will write the legal texts themselves and
   pay a lawyer once there are profits. **That is the wrong order** and should be said
   plainly.
2. **The criminal-record extract 596.2.** They flagged it themselves [7.3] — whether
   they may even ask for it, how long it may be kept, when it must be deleted. It is
   Article 10 GDPR data. I will not store it until a lawyer has answered.
3. **The insurance.** Their entire anti-disintermediation argument [1.4] and part of the
   professionals' subscription pitch [7.5] rest on an insurance contract that does not
   exist yet.
4. **The domain transfer** from the previous developer [15.6] — not yet completed.

## Contradictions to settle on the call

Cheap to resolve, each affects a screen:

1. Verification **badges** — listed at [6.9], abolished at [7.2]. → No badges; one
   site-wide statement that every profile is verified by Berceo before publication.
2. **Identity verification of professionals** — the cahier wants itsme or an ID card; the
   answers drop itsme and never reinstate identity as a document [7.3]. → V1 verifies
   diploma, INAMI and criminal record only. No identity document.
3. **Map** — the cahier promises one, [15.5] says a radius is enough. → Zone + radius
   list, no map.
4. **Public profiles** — [4.2] accepted anonymised public cards plus commune SEO pages;
   [13.5] then rejects commune pages. → Teaser cards on the public pages, no commune
   pages, subscription gates the rest.
5. **The calendar's authority** — [7.4] wants it, [11.1] makes it optional and
   indicative. → Optional, indicative, confirmed on acceptance.

## Gate — Jamie

- [ ] Scope approved
- [ ] €7.500 approved
- [ ] Payment split and the 120-day longstop approved
- [ ] Jamie-hosted arrangement + €50/month cap + Stripe-in-their-name confirmed in writing
- [ ] Value and shape recorded on the dashboard deal card
