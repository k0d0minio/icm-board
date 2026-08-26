# sell/01_intake — qualify, and open (or decline) the deal

One stage, one job: decide whether this name becomes a deal, and send the first reply.
The clock matters — a `new` lead mints a "Reply within 2 days" todo
([CLIENTS.md](../../../../_system/contracts/CLIENTS.md)).

## Inputs

| Layer | File | Why |
|---|---|---|
| 3 | [`references/qualification.md`](../../references/qualification.md) | The take/decline/not-yet criteria |
| 3 | [`references/target-profile.md`](../../references/target-profile.md) | What a good fit looks like |
| 3 | [`references/outreach.md`](../../references/outreach.md) | Outbound only: message shapes |
| 3 | [`_system/knowledge/voice.md`](../../../../_system/knowledge/voice.md) | The reply sounds like the business |
| 3 | [`_system/knowledge/services.md`](../../../../_system/knowledge/services.md) | Is what they want something we sell |
| 4 | The lead's own words | Form message, referral note, or nothing yet (outbound) |

## Process

1. If no deal folder exists, create `workspaces/deals/<slug>/` with `DEAL.md` per
   [`deals/README.md`](../../../deals/README.md). Slug = their name, kebab-case.
2. Write `01-intake.md`: who they are, where they came from, what they asked for in
   their words, and the qualification verdict **with the criterion it rests on**.
3. Draft the reply (inbound) or the outreach message (outbound) into the same file —
   voice per `voice.md`, no price yet, one concrete next step (usually the discovery
   conversation).
4. Declines get a draft too — brief, kind, and where honest, a pointer elsewhere.

## Gate — Jamie

- Reads the verdict, edits the draft, **sends it himself** — no outbound action from a
  session, ever.
- Moves the dashboard rung: reply sent → `talking`; decline → `lost` (archive).

## Outputs

| Artifact | Lands in |
|---|---|
| `01-intake.md` (verdict + sent message) | the deal folder |
| `DEAL.md` created/updated | the deal folder |

## Audit

- Verdict cites a qualification criterion, not a vibe.
- The draft asks for a conversation, not a commitment; contains no number.
- `DEAL.md` and the dashboard rung agree.
