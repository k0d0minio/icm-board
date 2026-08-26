# `deals/` — Layer 4: one folder per relationship

*The working artifacts of [`sell/`](../sell/CONTEXT.md) and [`start/`](../start/CONTEXT.md).
Tracked in git, deliberately — this repo is private, the pipelines must work from cloud
sessions, and past deals are precedent for future quotes (decision D5,
[`.icm/project.md`](../../.icm/project.md)). Grammar:
[`WORKSPACES.md`](../../_system/contracts/WORKSPACES.md).*

## A deal folder

```
deals/<kebab-case-name>/
  DEAL.md                  ← the spine: who, state, log
  01-intake.md             ← verdict + the sent first message
  02-discovery-prep.md     ← the short list for the meeting
  02-discovery-notes.md    ← the brief a quote can be written from
  03-quote.md              ← scope · shape · number · deviations
  04-proposal.md / .pdf    ← what the lead received (md canonical)
  05-onboarding.md         ← answers, access record, confirmed terms
  06-repo.md               ← repo created, baseline seeded, prefix registered
  07-kickoff.md            ← /project ran; pointers into the client repo
```

Artifacts appear as their stage runs; a folder with only `01-intake.md` is a young deal,
not a broken one. Numbering continues across sell → start because it is one story.

## DEAL.md

```markdown
# <Name> — deal

| | |
|---|---|
| Ladder | talking          ← mirror only; Neon is authoritative (CLIENTS.md) |
| Stage  | 03_quote         ← the next stage to run |
| Shape  | fixed-price · retainer · in-kind |
| Value  | €N (or in-kind EUR equivalent) |
| Source | portfolio form · referral (<who>) · outbound |

## Log
- 2026-08-26 — first reply sent
One dated line per event that matters: sent, heard back, quoted, went quiet, won, lost.
```

## Rules

- **Never a secret.** No credentials, tokens, or identity documents — an access grant is
  recorded as *existing* (in the password manager), never as its value.
- **Nothing is deleted.** A lost deal keeps its folder and its log; a returning lead
  reopens the same folder. Slugs, like ticket numbers, are never reused for a different
  person.
- **Jamie's edits win.** Whatever he leaves in an artifact is what the next stage reads.
- **Won deals hand over.** At `07_kickoff` the durable documents (proposal, discovery
  notes) are *copied* into the client repo's `.icm/docs/` — the deal folder keeps its
  originals as the business's own record.
- **The dashboard is not duplicated.** Value, rung, Stripe state live in Neon; `DEAL.md`
  mirrors just enough to read a deal cold.
