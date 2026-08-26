# ICM-011 — the adoption sweep, run 2026-08-26

*The one-time record of walking the ladder with Jamie. Ticket:
[`ICM-011`](../intake/_done/ICM-011-adopt-inflight-relationships.md). Source of truth for the
rungs: the admin dashboard (`app.jamienisbet.com`), read live during the sweep.*

## What the ladder held

**14 rows — 6 `talking`, 8 `client`, 0 `lost`, 0 `new`.** Header totals at the time:
€1,200 in play · €3,890/month.

## Adopted — 9 deal folders created

| Folder | Row | Ladder | Adopted at | Artifacts folded in |
|---|---|---|---|---|
| [`rui-matias`](../../workspaces/deals/rui-matias/DEAL.md) | Rui Matias · Kau | `talking` | `01_intake` | none — none exist |
| [`alix-hahusseau`](../../workspaces/deals/alix-hahusseau/DEAL.md) | Alix Hahusseau · Berceo | `talking` | `01_intake` | none |
| [`dragon`](../../workspaces/deals/dragon/DEAL.md) | Dragon · Private chef | `talking` | `01_intake` | none |
| [`billy-carlson`](../../workspaces/deals/billy-carlson/DEAL.md) | Billy Carlson · Vinecliff | `talking` | `01_intake` | none |
| [`alex-valexo`](../../workspaces/deals/alex-valexo/DEAL.md) | Alex Valexo · Alfredo | `lost` | `01_intake` | none |
| [`casey-hebbel`](../../workspaces/deals/casey-hebbel/DEAL.md) | Casey Hebbel · Broadway | `talking` | `03_quote` | 20 questionnaire answers → `02-discovery-notes.md` |
| [`karen`](../../workspaces/deals/karen/DEAL.md) | Karen · Barzinho | `lost` | `04_proposal` | proposal, counter-analysis, structure memo, confirmed facts, diligence questions |
| [`jerome`](../../workspaces/deals/jerome/DEAL.md) | Jerome · Le Pavillon Vert | `lost` | `04_proposal` | `proposal.pdf` referenced, not copied |
| [`magali`](../../workspaces/deals/magali/DEAL.md) | Magali · CollabImmo | `client` | `01_intake` | none — follow-on only |

**Jamie's decision on the five bare `talking` rows:** adopt at `01_intake`, not
`02_discovery`. They have gone quiet 8–14 days with no artifacts and no terms, so the
next stage to run is qualification and a reply, even though the rung already reads
`talking`. No `01-intake.md` was written for any of them — the stage writes it when it
runs. Nothing was reconstructed.

## Not adopted — decisions recorded

### Delivered clients — folder-less by design

Their record is the Neon row and the client repo; the doorway is `/project`, not
`/client` ([`deals/README.md`](../../workspaces/deals/README.md) § Adopted deals).

| Row | Repo | Note |
|---|---|---|
| Max Rettich · Boys to Men Retreat | `boystomenretreat` | **Jamie's decision: delivered.** Terms were never set; €1,000 entered during the sweep. |
| Tristan Boxford · Little Grass Shack | `little-grass-shack` | €150, delivered |
| Kuuipo · Jardim | `cafe-jardim` | €150, delivered |
| Miriam · Accounting | `miriamfridman` | barter, delivered |
| Morgane Paquet · Remi AI | `remi-ai` | 10% equity, work started |
| David Hamilton · Sustentus | *(different GitHub org)* | €3,890/mo, work started. The delivery repo lives outside `k0d0minio`, so the dashboard cannot link it — a known limitation, not a gap. |
| Dungeons & Dragons | `dungeons-dragons` | barter, work started |
| Diogo · Agorasim | `agorasim` | 4% commission, work started |

Stripe is unlinked on all eight. For the barter, equity and commission deals that is not
a gap — per [`CLIENTS.md`](../../_system/contracts/CLIENTS.md), no status is a money fact
and Stripe stays the authority for anything invoiced. It is only an open question for the
two €150 rows.

> **Assumption, flagged.** Jamie ruled Max Rettich delivered — `client` rung, repo
> connected, `work_started_at` never set. Tristan Boxford, Kuuipo and Miriam match that
> pattern exactly, so the same ruling was applied to them without asking again. If any of
> the three is actually mid-start rather than long delivered, it needs a folder at
> `05_onboarding` and this line is where to correct it.

### messy-play — not a client relationship

**Jamie's decision:** a personal project, still at its own intake stage. Deal folders
serve client relationships, so it gets none. Its `DISCOVERY-PROMPT.md` (2026-08-08) is
its own thing, and its doorway is `/project`.

### The build-once-hand-off sites

`firedough` · `garmani` · `grafitala` · `lourenco-botelho` · `simnao` · `the-library`
carry no Neon row and no deal paper. They stay folder-less under the standing ruling in
[`_system/AUDIT.md`](../../_system/AUDIT.md) that client sites are build-once-hand-off.
`the-library` is additionally the one repo in the estate with **no `.icm/`** — a
conformance gap, not a deal gap.

## The Neon actions — all taken, 2026-08-26

Nothing in a session writes to Neon and no outbound action was taken; Jamie performed
these in the dashboard while the sweep was open, and the ladder was re-read afterwards to
confirm. It went from **14 rows (6 open · 8 client · 0 lost)** to
**17 rows (5 open · 9 client · 3 lost)**.

- [x] **Karen / Barzinho** — row created, set `lost`.
- [x] **Jerome / Le Pavillon Vert** — row created, set `lost`. This is where the contact
      name came from; the folder was renamed from `le-pavillon-vert/` to `jerome/`.
- [x] **Magali / CollabImmo** — row created at `client`, delivery repo connected. Folder
      renamed from `collabimmo/` to `magali/` for the same reason.
- [x] **Max Rettich** — deal terms entered, €1,000.
- [x] **David Hamilton / Sustentus** — *closed as not-applicable.* The delivery repo is
      in a different GitHub org, so the dashboard cannot link it. Known limitation.
- [ ] Optional, left open: Stripe customers for Tristan Boxford and Kuuipo (€150 each).

### Two things the re-read turned up

**Alex Valexo moved to `lost`** during the sweep, after his folder had already been
adopted at `talking`. The folder now records that he was adopted and closed the same day.
No reason for the loss is written down — `deals/README.md` expects `DEAL.md` to say why a
deal exited, so that is one line still owed.

**The three `lost` rows are not archived.** [`CLIENTS.md`](../../_system/contracts/CLIENTS.md)
says `lost` is terminal and archiving is what takes them off the list. They are visible
by choice; noting it so the next reader doesn't take it for drift.

## Acceptance — where ICM-011 stands

- **Every open row adopted or decided** — yes. All 6 rows that were `talking` at the
  start of the sweep have folders.
- **Real artifacts only, no invented history** — yes. Only Casey's answers and barzinho's
  five documents were folded in, each with a provenance line. Every pre-system stage is
  left as an honest gap.
- **Delivered clients confirmed folder-less** — yes, with the assumption above flagged.
- **`DEAL.md` mirrors agree with the dashboard rung** — **yes, verified.** Every adopted
  deal now has a row, and each `Ladder` value was re-read from the dashboard after Jamie's
  changes rather than assumed.
