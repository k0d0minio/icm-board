# Services — what is actually sold

*Layer-3 reference. The catalogue every quote and proposal draws from — a deal is one or
more of these, scoped. Filled 2026-08-26 from
[`../setup/questionnaire.md`](../setup/questionnaire.md) § Services (ICM-009); the free
look, the diagnostic and hosting & basic support added 2026-09-22 (the rework brief). Any
engagement can run as one-off, one-off + support, retainer or partnership — that is a
pricing shape ([pricing.md](pricing.md)), not a separate service.*

## The catalogue

One entry per thing Jamie sells. If a piece of work fits no entry, that is a finding —
either the catalogue grows, or the work is declined.

### The free look
- **What the client gets** — one page, after the first call: *what I saw* · *where each
  part of the work belongs* (could run itself · keep a person on it · worth an assistant ·
  don't build this) · *three things I'd do first* · *how I'd start*. Written in their
  words, ≤ 400 words, no number in it ([`sell/02_look`](../../workspaces/sell/stages/02_look/CONTEXT.md)).
- **Typical shape** — free, always; it follows the first call and never precedes it.
- **In scope, always** — the call (20–30 minutes), a read of their public presence and
  whatever they sent, the page.
- **Not in scope, always** — a price, a build, any access beyond what they offer read-only.
- **Smallest honest version** — the page itself; there is no smaller.

### The diagnostic
- **What the client gets** — the detailed report on implementing and improving their
  current processes and workflows efficiently: every process seen, sorted four ways, in
  order; what each needs; what it costs to build and to run; what to leave alone; a
  one-page summary first ([`diagnostic-report-template.md`](../../workspaces/sell/references/diagnostic-report-template.md)).
- **Typical shape** — paid, two weeks, priced by register and credited 100 % against the
  build signed within the window ([pricing.md](pricing.md) § The paid diagnostic).
- **In scope, always** — the 52-question bank as the instrument
  ([`discovery-questions.md`](../../workspaces/sell/references/discovery-questions.md)),
  the interviews it needs, the report.
- **Not in scope, always** — building anything; a decision the business has not made.
- **Smallest honest version** — the free look. Where a spec-shaped deal is contradictory,
  the Foundation tier *is* the diagnostic.

### Client website
- **What the client gets** — their business findable and presentable: pages, booking or
  menu or contact flows, their own domain, live and handed over.
- **Typical shape** — fixed-price build, hand-off at the end; a retainer where they want
  ongoing care.
- **In scope, always** — domain + DNS + HTTPS · analytics-or-none with consent handling
  · privacy page + contact route appropriate to the data collected · the `.icm/` +
  `CLAUDE.md` baseline (see [stack.md](stack.md) § What a client site ships with) · **for
  anything with state** (a booking flow, accounts, payments): the fail-safe *technical
  difficulties* page and Sentry, so basic support can exist.
- **Not in scope, always** — content writing · photography and imagery · logo/brand
  design · SEO beyond clean structure, metadata and speed. Each is theirs to bring, or
  a separately quoted add-on — quotes never re-litigate this list.
- **Smallest honest version** — deliberately not fixed: it varies per deal and is
  negotiated as the smaller row of the quote's Options table, at or above the floor.

### Web application
- **What the client gets** — a working tool with state: accounts, data, an admin view,
  the workflows their business runs on.
- **Typical shape** — fixed-price per engagement, scoped from discovery; a retainer
  where the tool keeps evolving.
- **In scope, always** — the stack baseline ([stack.md](stack.md)) · the fail-safe
  *technical difficulties* page and Sentry (a build with state ships with both — they are
  what makes basic support possible) · the repository carrying its own pipeline.
- **In scope / not in scope** — the rest is defined per engagement in the quote; the
  website always-extra list applies to any web-facing surface.

### AI consulting / agent workflows
- **What the client gets** — a process of theirs made faster or automatic: agent
  workflows, LLM integration, the setup and the handover knowledge to run it.
- **Typical shape** — scoped engagement (fixed-price) or an ongoing retainer; this is
  the line the business is deliberately growing
  ([target-profile](../../workspaces/sell/references/target-profile.md)).
- **In scope, always** — where the workflow holds state or runs unattended: the fail-safe
  page and Sentry, as for any build with state; the handover knowledge in the repository.
- **In scope / not in scope** — the rest is defined per engagement. *Standing inclusions
  beyond that — not yet established; distil from the next two real engagements.*

### Hosting & basic support
- **What the client gets** — the build kept running: Vercel Pro in Jamie's team, Supabase
  or Neon for the data, and **crash fixes on call** — when the app is down or a flow
  breaks, Jamie is the one who fixes it. Not feature work, not a retainer.
- **Typical shape** — the recurring line of *one-off + support*: **included at no cost for
  landing pages**; **a monthly line for builds with state**, priced by the build's
  complexity ([pricing.md](pricing.md) § Support). It requires the fail-safe page and
  Sentry — without both there is nothing to be on call for.
- **In scope, always** — hosting on the stated accounts, the error tracker, the on-call
  fix, the monthly hosting rebill where the deal says so ([terms.md](terms.md)).
- **Not in scope, always** — new features, content changes, anything a retainer covers;
  the client-owned pattern has no support line at all ([terms.md](terms.md)).
- **Smallest honest version** — hosting only, no on-call: the landing-page case.

## Non-services

- **Pure content or design work** — copywriting, branding, or graphic design as the
  deliverable itself, with no build attached. Declined on sight (qualification D1);
  where honest, point at someone who does it well.
