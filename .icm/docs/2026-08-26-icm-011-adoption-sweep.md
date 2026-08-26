# ICM-011 — the adoption sweep, run 2026-08-26

*The one-time record of walking the ladder with Jamie. Ticket:
[`ICM-011`](../intake/ICM-011-adopt-inflight-relationships.md). Source of truth for the
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
| [`alex-valexo`](../../workspaces/deals/alex-valexo/DEAL.md) | Alex Valexo · Alfredo | `talking` | `01_intake` | none |
| [`casey-hebbel`](../../workspaces/deals/casey-hebbel/DEAL.md) | Casey Hebbel · Broadway | `talking` | `03_quote` | 20 questionnaire answers → `02-discovery-notes.md` |
| [`karen`](../../workspaces/deals/karen/DEAL.md) | *(none)* | `lost` | `04_proposal` | proposal, counter-analysis, structure memo, confirmed facts, diligence questions |
| [`le-pavillon-vert`](../../workspaces/deals/le-pavillon-vert/DEAL.md) | *(none)* | `lost` | `04_proposal` | `proposal.pdf` referenced, not copied |
| [`collabimmo`](../../workspaces/deals/collabimmo/DEAL.md) | *(none)* | *(none)* | `01_intake` | none — follow-on only |

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
| Max Rettich · Boys to Men Retreat | `boystomenretreat` | **Jamie's decision: delivered.** Deal terms and `work_started_at` were simply never set — a dashboard gap, not a pipeline gap. |
| Tristan Boxford · Little Grass Shack | `little-grass-shack` | €150, delivered |
| Kuuipo · Jardim | `cafe-jardim` | €150, delivered |
| Miriam · Accounting | `miriamfridman` | barter, delivered |
| Morgane Paquet · Remi AI | `remi-ai` | 10% equity, work started |
| David Hamilton · Sustentus | *(not connected)* | €3,890/mo, work started |
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

## What this sweep could not do — Neon actions for Jamie

Nothing in a session writes to Neon, and no outbound action was taken. These are the
dashboard steps the sweep depends on:

- [ ] **Karen / Barzinho** — create the row, set `lost`, archive it. Until then
      `karen/DEAL.md`'s Ladder mirrors nothing.
- [ ] **Le Pavillon Vert** — same: create the row, set `lost`, archive it.
- [ ] **CollabImmo** — create a row. Neither the delivered work nor the follow-on is
      visible to the dashboard today.
- [ ] **Max Rettich** — enter the deal terms so the ConvertFlow badge clears.
- [ ] **Sustentus** — connect `k0d0minio/sustentus` as the delivery repo.
- [ ] Optional: link Stripe customers for Tristan Boxford and Kuuipo (€150 each).

## Acceptance — where ICM-011 stands

- **Every open row adopted or decided** — yes. All 6 `talking` rows have folders.
- **Real artifacts only, no invented history** — yes. Only Casey's answers and barzinho's
  five documents were folded in, each with a provenance line. Every pre-system stage is
  left as an honest gap.
- **Delivered clients confirmed folder-less** — yes, with the assumption above flagged.
- **`DEAL.md` mirrors agree with the dashboard rung** — **not yet**, for three deals.
  `karen`, `le-pavillon-vert` and `collabimmo` have no row to mirror. This is the one
  acceptance box the sweep cannot tick from a session; it clears when Jamie does the
  Neon actions listed above.
