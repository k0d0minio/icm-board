# sell/01_intake — qualify, and draft the reply that asks for the call

One stage, one job: decide whether this name becomes a deal, and draft the first reply.
The clock matters — a `new` lead mints a "Reply within 2 days" todo
([CLIENTS.md](../../../../_system/contracts/CLIENTS.md)). Runs from any session with
icm-board in view.

## Inputs

| Layer | File | Why |
|---|---|---|
| 3 | [`references/qualification.md`](../../references/qualification.md) | The take/decline/not-yet criteria |
| 3 | [`_system/knowledge/positioning.md`](../../../../_system/knowledge/positioning.md) | Which register this lead is in; the free look as the ask |
| 3 | [`_system/knowledge/services.md`](../../../../_system/knowledge/services.md) | Is what they want something we sell |
| 3 | [`_system/knowledge/voice.md`](../../../../_system/knowledge/voice.md) | The reply sounds like the business |
| 3 | [`references/outreach.md`](../../references/outreach.md) | Outbound only: message shapes |
| 4 | The lead's own words | The Neon row's message, or the `intake-diagnostic` form answers (the dashboard writes them to `answers/intake-diagnostic.md`) |

## Process

1. If no client folder exists, create `workspaces/deals/<repo>/` with `DEAL.md` per
   [`deals/README.md`](../../../deals/README.md) — slug = the client repo's name (the
   business, kebab-case; the repo takes the same name at signature);
   `- engagement:` names the engagement folder you create beside it (slug from the deal's
   subject, e.g. `vinecliff-site`); `- language:` from how they wrote.
2. Write `<engagement>/01-intake.md`: who they are, where they came from, what they asked
   for **in their words**; then the verdict — **one line per qualification criterion**,
   each `Q1`–`Q4`, `D1`–`D4`, `N1`–`N2` named with its evidence.
3. Draft the reply (inbound) or the outreach message (outbound) into the same file — voice
   per `voice.md`, in the lead's register per `positioning.md`, **no price**, one concrete
   next step: the first call, after which comes the free look.
4. Declines get a draft too — brief, kind, and where honest, a pointer elsewhere.

## Gate — Jamie

- Reads the verdict, edits the draft, **sends it himself** — no outbound action from a
  session, ever.
- Sets the rung in the dashboard: reply sent → `talking`; decline → `lost` (archive).
  The folder records neither.

## Outputs

| Artefact | Lands in |
|---|---|
| `DEAL.md` (created; `- engagement:` set) | `workspaces/deals/<client>/` |
| `01-intake.md` (verdict + the draft) | `workspaces/deals/<client>/<engagement>/` |

Committed straight to `main` with a `Deal:` prefix.

## Audit

- The verdict cites criteria by ID, one line each, not a vibe.
- The draft asks for a conversation, not a commitment; contains no number.
- `DEAL.md` carries no rung, stage or value; the language field is set.
