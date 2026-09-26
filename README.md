# icm-board — the business, as a system

The second brain of **Jamie Nisbet's** business: three ICM workspaces that sell, start
and deliver the work; the knowledge and contracts they cite; and the scripts that keep
~22 client repos plus his own web estate aligned. No application code lives here.

## The map

```text
icm-board/                     this repo — k0d0minio/icm-board (private)
├── AGENTS.md                  Layer 0 — identity & routing (read first)
├── CLAUDE.md                  one-line `@AGENTS.md` import for Claude Code
├── CONTEXT.md                 Layer 1 — where do I go?
├── README.md                  you are here
│
├── workspaces/                the processes (grammar: contracts/WORKSPACES.md)
│   ├── sell/                  01_intake → 02_look → 03_quote → 04_proposal → 05_agreement
│   ├── start/                 06_onboarding → 07_kickoff
│   ├── deliver/               project · day · conformance (the estate machine)
│   └── deals/                 Layer 4 — one folder per client, one per engagement inside it
│                              (DEAL.md · 01-…08-*.md · answers/ · raw/ · private/ · out/)
│
├── _system/                   the control layer (_system/README.md)
│   ├── contracts/             WORKSPACES · TICKETS · PIPELINE · PROJECT · LENSES · CLIENTS
│   ├── knowledge/             positioning · services · pricing · voice · terms · stack
│   ├── setup/                 the questionnaire that fills knowledge/
│   ├── scripts/               icm-check · icm-sync · tickets-board · ticket-hygiene · pull-all
│   │                          · self-check · vercel-env
│   │                          · run-economics · validate-deal · render-deal
│   ├── template/              the baseline + canonical Claude assets --fix seeds
│   ├── hooks/                 SessionStart (estate board)
│   └── AUDIT.md               what's broken or undecided across the estate
│
├── .claude/                   /client · /project · /day · /icm-check (thin routers)
├── .icm/                      this repo's own register + intake epics (+ today.md)
├── .github/workflows/         self-check
│
└── projects/                  the estate — gitignored, on this machine only
    ├── jamienisbet/           the web estate, its own repo + CI + tickets
    └── <client>/ ×22          client delivery repos
```

## How it runs

- **The folders are the orchestration.** Stage contracts plus human gates; nothing runs
  itself and no outbound action leaves a session — see `AGENTS.md` § Never build an
  orchestrator. Jamie advances every deal and every ritual himself.
- **One story per client.** `/client <name>` walks an engagement through stages 01–07;
  `07_kickoff` hands over to `/project` and the client's own repo, whose handover lane
  writes `08-handover.md` back at the end. **One home per fact** (D24): business *state*
  (the rung, the flags, the agreed value, money) lives in Neon and Stripe via the admin
  dashboard; every deal document, private reasoning included, lives in the deal folder
  here; the dashboard reads the folder live and nothing syncs. `Deal:` commits go
  straight to `main`.
- **One check, on disk.** The estate lives under `projects/` on Jamie's machine, so
  `icm-check.sh` reads it directly — baseline, canonical Claude assets, the pipeline's
  manifest — and the daily `estate-housekeeping` routine runs it there. The API-only CI
  twin was retired on 2026-09-26.
- **Tickets live next to their logic.** Work on this repo's machinery is cut here;
  dashboard work is cut in `k0d0minio/jamienisbet` — epics and stubs per
  `_system/contracts/TICKETS.md`. They commit straight to `main` — here and in every
  client repo alike (D39).
- **CI is the source of truth** — don't run checks locally.

## History

Until 2026-08-26 this control layer shared a repo with the web estate
(`k0d0minio/jamienisbet`, itself the product of a 2026-08-12 consolidation with the
now-archived `k0d0minio/apps-estate`). It was split out so that ticketing and CI could sit
next to the code whose logic they describe. On 2026-08-26 the business processes returned
as ICM workspaces (Van Clief & McDermott's Interpretable Context Methodology,
`_system/reference/icm.pdf`) — superseding, deliberately and on the record, the
2026-08-12 retirement of the "ICM business factory". What returned is contracts and
gates, not a factory.

— Start at [`AGENTS.md`](AGENTS.md), then [`CONTEXT.md`](CONTEXT.md)
