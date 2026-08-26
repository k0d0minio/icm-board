# icm-board — the estate orchestrator

The control layer for **Jamie Nisbet's** repo estate: ~22 client repos plus his own web
estate, kept aligned by a handful of contracts, four scripts, three commands and two
workflows. No application code lives here.

## The map

```text
icm-board/                     this repo — k0d0minio/icm-board (private)
├── CLAUDE.md                  agent identity & routing (read first)
├── README.md                  you are here
│
├── _system/                   the control layer — START HERE (_system/README.md)
│   ├── contracts/             TICKETS · PROJECT · LENSES · CLIENTS
│   ├── scripts/               icm-check · tickets-board · ticket-hygiene · pull-all
│   │                          · estate-conformance (the API-only one)
│   ├── template/              what icm-check.sh --fix seeds a repo from
│   ├── hooks/                 SessionStart
│   └── AUDIT.md               what's broken or undecided across the estate
│
├── .claude/                   /project · /day · /icm-check · two agents · settings
├── .icm/                      this repo's own register + ICM-NNN backlog
├── .github/workflows/         self-check · estate-conformance
│
└── projects/                  the estate — gitignored, on this machine only
    ├── jamienisbet/           the web estate, its own repo + CI + tickets
    └── <client>/ ×22          client delivery repos
```

## How it runs

- **The folders are the orchestration.** This repo checks structure and reports drift. It
  never drives a pipeline — see `CLAUDE.md` § Never build an orchestrator.
- **Two halves of the same check.** On this machine the estate is on disk, so
  `icm-check.sh` reads it directly. In CI it isn't, so `estate-conformance.sh` asks the
  GitHub API the same questions about the `k0d0minio` org. The second needs an
  `ESTATE_TOKEN` secret (ticket `ICM-005`); without it, it reports nothing true.
- **Tickets live next to their logic.** Work on `_system/` is an `ICM-*` here. Work on the
  dashboard is a `JN-*` in `k0d0minio/jamienisbet`. The admin dashboard's Tickets screen
  reads both.
- **CI is the source of truth** — don't run checks locally.

## History

Until 2026-08-26 this control layer shared a repo with the web estate
(`k0d0minio/jamienisbet`, itself the product of a 2026-08-12 consolidation with the
now-archived `k0d0minio/apps-estate`). It was split out so that ticketing and CI could sit
next to the code whose logic they describe, and so the estate root could be the ICM layer
alone. `jamienisbet` kept the remote, the history, and everything under it.

— Start at [`CLAUDE.md`](CLAUDE.md), then [`_system/README.md`](_system/README.md)
