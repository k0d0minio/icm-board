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
| 0 | [`/AGENTS.md`](../../AGENTS.md) | Where am I? |
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
| [`sell/`](../../workspaces/sell/) | `01_intake → 02_look → 03_quote → 04_proposal → 05_agreement` | once per engagement | the agreement is signed (or the deal is lost) |
| [`start/`](../../workspaces/start/) | `06_onboarding → 07_kickoff` | once per signed engagement | `/project` has run in the client repo |
| [`deliver/`](../../workspaces/deliver/) | `project · day · conformance` | forever, cyclically | never |

Sell and start share one number line (01–07) because a deal is one story: its artefacts
sort chronologically in the engagement folder, and the build's end — `08-handover.md`,
written by the client repo's handover lane — closes the same line. `06_repo` was retired
into `07_kickoff`'s gate on 2026-09-22: the repo is created at signature by default, and
kickoff adopts it. Deliver's stages are deliberately **unnumbered** — they are re-entrant
rituals, not a sequence, and pretending otherwise would be false.

## The deal folder

Layer 4 for sell and start is one folder per client relationship, and inside it one folder
per engagement ([`deals/README.md`](../../workspaces/deals/README.md) has the schema):

```
workspaces/deals/<client>/
  DEAL.md                       dash-fields: client, company, contacts, repo, language,
                                engagement (the live one), source — no mirror of any Neon column
  <engagement>/                 one per deal, sequential, never two live
    01-intake.md … 08-handover.md     the artefacts, as sent / as signed
    answers/<form>.md                 immutable snapshots of Neon's form answers
    raw/                              client material; media ignored, transcripts tracked
    private/ pricing.md · negotiation.md · terms-sheet.md · economics.md
  out/                          rendered DOCX — gitignored
```

**Stage is positional**: the live engagement's stage is the highest `NN-` artefact present
in its folder, and the next stage is the one after it. Nothing writes a stage name down.

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
- **One home per fact (decision D24).** Relationship *state* — the rung, the next action,
  `stripe_customer_id`, `github_repo`, `work_started_at`, the agreed value and shape —
  lives in Neon and is never mirrored into git: `DEAL.md` carries no Ladder, Stage or Value
  row. Every deal *document*, private reasoning included, lives here. The dashboard reads
  the deal folder live and shows the rung beside the folder's stage
  ([CLIENTS.md](CLIENTS.md) § The badge); nothing syncs. **A copy is allowed only when it
  is immutable and provenance-stamped**: the snapshots a client repo receives at kickoff
  (`.icm/docs/proposal-<date>.md`, `scope-<date>.md` — the quote's scope, never its
  numbers, never anything under `private/`) and the form-answer snapshots the dashboard
  writes into `answers/`. Money facts are Stripe's, always.
- **Deal commits go straight to `main`, with a `Deal:` prefix.** A deal folder is words,
  not code — the same standing as `Plan:` and `Wrap:` commits. Stage paths explicitly.
- **`private/` never leaves this repo.** Pricing reasoning, negotiation analysis, the
  partnership term sheet, the economics roll-up — read by `03_quote` as precedent, written
  by the stages and by `run-economics.sh`, copied nowhere.
- **Nothing runs itself.** No stage triggers another; no script advances a deal; the
  scheduled workflows report and never write. The moment something here drives rather
  than describes, it has broken the house rule that outranks this contract. (What that
  rule does and does not exclude in a *project repo's own* pipeline — deterministic
  one-job scripts, post-merge CI — is decision D11, recorded in
  [`.icm/project.md`](../../.icm/project.md) and specified in
  [PIPELINE.md](PIPELINE.md). This workspace layer keeps the strict reading.)
