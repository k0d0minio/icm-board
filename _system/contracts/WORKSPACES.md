# The workspace grammar — how a process is written down

*The contract for everything under [`../../workspaces/`](../../workspaces/). Based on
Interpretable Context Methodology (Van Clief & McDermott 2026,
[`../reference/icm.pdf`](../reference/icm.pdf)) — folder structure as the architecture,
markdown as the interface, a human gate at every boundary. Companions:
[CLIENTS.md](CLIENTS.md) (the ladder the business workspaces walk) ·
[TICKETS.md](TICKETS.md) (what delivery work becomes) ·
[PROJECT.md](PROJECT.md) (what delivery reads and writes).*

Supersedes the 2026-08-12 retirement of the "ICM business factory" — decision D3 in
[`.icm/project.md`](../../.icm/project.md). What returns is **not** a factory: nothing
here runs itself, drives a pipeline, or acts outward. A workspace is stage contracts plus
human gates; Jamie advances every stage, and the agent's writes stay inside the folders
this contract names.

## The five layers

Every session in this repo navigates the same hierarchy. Load down only as far as the
task needs; no session reads everything.

| Layer | File(s) | Answers |
|---|---|---|
| 0 | [`/CLAUDE.md`](../../CLAUDE.md) | Where am I? |
| 1 | [`/CONTEXT.md`](../../CONTEXT.md) + each workspace's `CONTEXT.md` | Where do I go? |
| 2 | `workspaces/*/stages/*/CONTEXT.md` | What do I do? |
| 3 | [`knowledge/`](../knowledge/) · [`contracts/`](./) · each workspace's `references/` | What rules apply? |
| 4 | [`workspaces/deals/`](../../workspaces/deals/) — and, for deliver, the estate repos themselves | What am I working with? |

Layer 3 is the factory: configured once, stable across runs, internalised as constraints.
Layer 4 is the product: unique to each deal or day, processed as input. Never mix them —
a reference file that names a real client is a Layer-4 artifact in the wrong folder.

## The three workspaces, one number line

| Workspace | Stages | Runs | Ends when |
|---|---|---|---|
| [`sell/`](../../workspaces/sell/) | `01_intake → 02_discovery → 03_quote → 04_proposal` | once per deal | the deal is agreed (or lost) |
| [`start/`](../../workspaces/start/) | `05_onboarding → 06_repo → 07_kickoff` | once per won deal | `/project` has run in the client repo |
| [`deliver/`](../../workspaces/deliver/) | `project · day · conformance` | forever, cyclically | never |

Sell and start share one number line (01–07) because a deal is one story: its artifacts
sort chronologically in its deal folder. Deliver's stages are deliberately **unnumbered**
— they are re-entrant rituals, not a sequence, and pretending otherwise would be false.

## The stage contract

Every stage is one folder with one `CONTEXT.md`, ≤80 lines, in five parts:

```markdown
# <workspace>/<stage> — <the one job, in one line>

## Inputs
| Layer | File | Why |
(exactly which Layer-3/4 files to load — nothing else)

## Process
Numbered steps. WHAT and WHEN, never HOW-to-prompt.

## Gate — Jamie
What he reviews, edits or does in the outside world before the next stage.
Checkboxes here are his; read them, never tick them.

## Outputs
| Artifact | Lands in |

## Audit
Pass conditions checked before writing output — including consistency with
earlier stages' artifacts, not just this stage's inputs.
```

## Rules

- **One stage, one job.** A stage that discovers does not also quote.
- **Every output is an edit surface.** Whatever Jamie leaves in the deal folder is the
  truth the next stage reads — his edits are never "corrected" back.
- **Edit the source, not just the output.** The same fix made at the same stage twice is
  a bug in a Layer-3 file or a stage contract; amend it there so every future run
  inherits the fix.
- **Contracts ≤80 lines, reference files ≤200.** Over the cap means the file is doing two
  jobs; split it. Named exception: deliver's three rituals carry years of converged
  process and get 160 — trimming them to fit would delete working rules.
- **No secrets in Layer 4, ever.** Deal folders carry words and documents — never
  credentials, tokens, or identity documents. Access material goes into a password
  manager and the folder records only *that* it exists.
- **Neon stays authoritative for business state.** A deal folder mirrors the ladder rung
  for legibility; the dashboard row *is* the status ([CLIENTS.md](CLIENTS.md)). Money
  facts are Stripe's, always.
- **Nothing runs itself.** No stage triggers another; no script advances a deal; the
  scheduled workflows report and never write. The moment something here drives rather
  than describes, it has broken the house rule that outranks this contract.
