# `deals/` — Layer 4: one folder per client relationship

*The working artefacts of [`sell/`](../sell/CONTEXT.md) and [`start/`](../start/CONTEXT.md).
Tracked in git, deliberately — this repo is private, the workspaces run from cloud
sessions, and past deals are precedent for future quotes (decisions D5 and D24,
[`.icm/project.md`](../../.icm/project.md)). Grammar:
[`WORKSPACES.md`](../../_system/contracts/WORKSPACES.md) § The deal folder. Re-cut
2026-09-22: one folder per client, one folder per engagement inside it, dash-fields
instead of a table, no mirror of any Neon column.*

## A client folder

```
deals/<client>/                     ← the relationship; slug = the person's name, kebab-case
  DEAL.md                           ← dash-fields + the engagements table + the log
  <engagement>/                     ← one per deal, sequential, never two live
    01-intake.md                    ← the verdict + the sent first message
    02-look.md                      ← the free look, as sent
    03-quote.md                     ← scope · tiers · shape · numbers · terms deltas
    04-proposal.md                  ← the proposal, as sent (the DOCX is rendered, not kept)
    05-agreement.md                 ← the paper: dash-field header + the clauses, as signed
    06-onboarding.md                ← the needed/asked/received table
    07-kickoff.md                   ← the handover into the client repo
    08-handover.md                  ← written by the client repo's handover lane at the end of the build
    answers/<form>.md               ← immutable snapshots of Neon's form answers (the dashboard writes them)
    raw/                            ← client material: transcripts tracked, media ignored
    private/                        ← pricing.md · negotiation.md · terms-sheet.md · economics.md — never leaves this repo
  out/                              ← rendered DOCX — gitignored
```

Artefacts appear as their stage runs; **stage is positional** — the highest `NN-` file in
the live engagement is where the deal stands. A folder with only `01-intake.md` is a young
engagement, not a broken one. Numbering continues across sell → start → the handover lane
because it is one story. `02-discovery-*` files in adopted engagements keep their names:
the `02-` prefix is the look's position.

## DEAL.md

```markdown
# <Company or name> — client

- client: <slug>                 ← this folder; the dashboard's deal_slug
- company: <name>
- contacts: <first names and roles — never an email or phone>
- repo: <owner/name | none yet>
- language: en | fr | pt
- engagement: <slug | none>      ← the live one; stage is positional under it
- source: portfolio-form | referral (<who>) | outbound | adopted

## Engagements
| slug | shape | started | ended | outcome |
|---|---|---|---|---|

## Log
- <date> — <event>
```

Nothing here mirrors Neon: no rung, no stage, no value, no Stripe state. The rung is read
from the dashboard when a stage needs it; the agreed value lives in `05-agreement.md`'s
header and reaches Neon at signature; the dashboard shows the rung beside the folder's
stage and a badge when they disagree ([CLIENTS.md](../../_system/contracts/CLIENTS.md)).
`- engagement:` names the live folder — `none` when nothing is live (a lost deal, a
delivered client between engagements, a relationship that never opened one).

## Adopted deals — relationships that predate the system

The business ran for years before this workspace existed; those relationships are
**adopted, never re-enacted** (house rule: adopt or stop). Nothing gets orphaned, and
nothing gets a fake history:

- The folder is created at the deal's **true stage**, confirmed with Jamie; `- source:
  adopted`; the engagement row and the log say when and at which stage it was adopted.
- Real artefacts that exist — a sent proposal, discovery notes, the client's own emails —
  are copied into the engagement folder under their stage numbers, each opening with one
  provenance line (*"adopted <date> from <where>; written <when>"*). A binary is referenced,
  not copied; the one PDF committed before this rule stays where it is.
- Stages that happened before the system are **honest gaps, never reconstructed** — no
  invented `01-intake.md` for a client won a year ago. The contracts apply from the adopted
  stage forward; the look-back at `07_kickoff` still runs on what exists.
- A relationship already **delivered** with nothing new in motion has a folder with
  `- engagement: none` and its repo named — the doorway for its work is `/project`, and the
  folder exists so a follow-on gets a new engagement, never a new folder.

## Rules

- **Never a secret.** No credentials, tokens, or identity documents — an access grant is
  recorded as *existing* (in the password manager), never as its value. No email addresses
  or phone numbers in `DEAL.md` either; the Neon row has them.
- **Nothing is deleted.** A lost deal keeps its folder and its log; a file is moved with
  `git mv` and a provenance line, never removed. Slugs are never reused for a different
  person.
- **A returning client gets a new engagement, never a new folder.** One folder per
  relationship, one engagement folder per deal, sequential; never two live at once.
- **Jamie's edits win.** Whatever he leaves in an artefact is what the next stage reads.
- **One home per fact.** State in Neon, documents here; a copy only when it is immutable
  and provenance-stamped — the kickoff snapshots into a client repo's `.icm/docs/`
  (proposal, the quote's scope section) and the dashboard's form-answer snapshots into
  `answers/`. Nothing under `private/` is ever copied anywhere.
- **`private/` never leaves this repo.** Pricing reasoning, negotiation analysis, the
  partnership term sheet (equity, commission, revenue share — REMI's lives here and
  nowhere a repository reader can see), the economics roll-up.
- **`Deal:` commits go straight to `main`** — words, not code; stage paths explicitly.
- **Media is never committed.** Recordings and screen captures under `raw/` are
  gitignored (the patterns in the repo's `.gitignore`); their transcripts (`.txt`, `.md`)
  are tracked. `out/` (rendered DOCX) is never committed either.
- **The dashboard is not duplicated.** It reads this folder live, read-only, and writes
  only the `answers/` snapshots.
