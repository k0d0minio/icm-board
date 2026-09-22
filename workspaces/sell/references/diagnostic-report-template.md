# The diagnostic — the report template

*Layer-3 reference for the paid diagnostic
([services.md](../../../_system/knowledge/services.md) § The diagnostic;
[pricing.md](../../../_system/knowledge/pricing.md) § The paid diagnostic). Two weeks; the
instrument is the 52-question bank in [`discovery-questions.md`](discovery-questions.md),
asked along the arc in [`discovery-interview.md`](discovery-interview.md). The report is
the deliverable the client paid for and keeps whether or not a build follows; it is
credited 100 % against the build signed within the window. Rendered to DOCX like a
proposal (`render-deal.sh`), placed in the client's Drive folder, sent by Jamie.*

## The shape

**The one-page summary comes first** — a reader who stops there knows the answer.

```markdown
# <Their business> — how the work runs, and where it belongs

<!-- - language: en | fr | pt -->
<!-- - register: local | sme | enterprise -->

## In one page

- **What the business does**, in two sentences, in their words.
- **The processes seen** — a list, each with its sort word (could run itself · keep a
  person on it · worth an assistant · don't build this).
- **In order** — the three to five things to do first, and why in that order.
- **What it would cost** to build the first of them, and what it costs to run — as a
  range, in this register's posture ([positioning.md](../../../_system/knowledge/positioning.md)).
- **What to leave alone**, and for how long.

## Every process, sorted

One section per process seen, in the order they would be tackled:

### <Process name — in their words>

- **What happens today** — who does it, how often, with which tools, what breaks.
- **The sort** — one of the four words, and the paragraph that earns it.
- **What it needs** — data it must read, decisions a person still makes, the third
  parties in the way (and their lead times).
- **What it costs to build** — a Foundation figure and a Full Build figure, or "not
  built — see the sort".
- **What it costs to run** — hosting, the support line, the person-hours that remain.
- **Blockers** — every `[BLOCKER]` still open, with who answers it; every `[LAWYER]`.

## What to leave alone

The processes sorted *don't build this*, with the reason and the condition under which
that changes ("when you pass N bookings a week", "when a second person does it").

## How I'd start

The engagement this report recommends, as `03_quote` will scope it: the tier, the shape,
the first outcome. The credit rule, stated plainly: this report's price is credited
against that build when it is signed within <30 | 90> days.

## Appendix — what was asked and answered

The question IDs from the bank and their answers, in the client's words — so nothing is
re-asked at the quote, and the assumptions taken are visible and challengeable.
```

## Rules

- **Every process seen is in the report**, sorted — including the ones the client did not
  ask about. That is what they paid for.
- **Numbers as ranges, in the register's posture**; the exact figures are the quote's.
- **Assumptions are flagged, never dressed as findings.** "Nodded to on the call" is not
  "confirmed".
- **`[LAWYER]` where their sector's rules or the data they hold might gate a build** — a
  written opinion from *their* counsel is named as a launch condition, not offered.
