# icm-board — project register

> Seeded 2026-08-26 at the split from `k0d0minio/jamienisbet`, from intent Jamie stated
> directly in that session. **Not yet a `/project` run** — the empty sections below are
> real gaps, not omissions. Run `/project icm-board` to interrogate and fill them.
> Maintained by `/project`. Amend by re-running it, not by hand-editing during a session.

## What this is

The orchestrator of Jamie Nisbet's repo estate: the contracts every repo is measured
against, the scripts that measure them, the three commands that do the work, and the
workflows that keep the measurement honest without needing the repos on disk. It holds no
application code and ships no product. Its one user is Jamie; its one job is that every
other repo in the estate stays aligned and well structured.

## Intent

- **For whom** — Jamie, and every Claude session opened at `~/Apps` or in any estate repo.
- **The job** — keep the estate conformant: every repo carries `.icm/` and a Layer-0
  `CLAUDE.md`, every ticket meets the contract, and drift is visible before it compounds.
- **Done looks like** — a repo can be adopted, analysed and ticketed without anyone
  remembering how; and a repo that has drifted says so without being asked.
- **Explicitly not** — a pipeline driver. The folders are the orchestration. This repo
  *checks* structure; it never runs a build, a deploy, or a client's work. The house rule
  "never build an orchestrator" survives the rename of this repo, and outranks it.

## Business logic

- **The repo wins.** Where a repo's own contracts conflict with the estate baseline, the
  repo is authoritative. Sustentus is the standing example and is exempt outright.
- **Tickets live next to the logic they describe.** A ticket about `_system/scripts/` lives
  here; a ticket about the dashboard lives in `jamienisbet`. This is why the `JN-*` series
  was split at the 2026-08-26 separation.
- **Gates are human checkboxes.** Read, never tick. Anything that cannot be verified from
  the repo (a Vercel setting, a token, a secret) is a human ticket that says so in its
  Prompt.
- **Conformance reports, it does not repair.** `icm-check.sh --fix` seeds only what is
  missing and never overwrites; the scheduled workflow reports and never writes.

## Features
| Feature | State | Tickets |
|---|---|---|
| Three commands — `/project`, `/day`, `/icm-check` | shipped | — |
| Four estate scripts — icm-check, tickets-board, ticket-hygiene, pull-all | shipped | ICM-003, ICM-004 |
| Self-check CI — shellcheck, contract links, ticket lint | shipped | — |
| Remote conformance CI over the `k0d0minio` org | shipped, unproven | ICM-005 |
| Estate heartbeat — scheduled digest | wanted | ICM-001 |
| `/day` run log | wanted | ICM-002 |

## Constraints

- **The estate is half-invisible to CI.** Client repos are gitignored and live only on this
  machine, so anything running in Actions must reach them over the GitHub API and is
  limited to what a read-only token can see.
- **Legal / data** — client repo names and business state are not public; this repo is
  private and `_system/AUDIT.md` is one reason why.
- **Commercial** — solo operator. Every rule here has to earn its maintenance cost.

## Decisions
| ID | Decision | Date | Supersedes |
|---|---|---|---|
| D1 | The control layer gets its own repo, `icm-board`; `jamienisbet` becomes a normal repo under `projects/` and keeps its remote, CI and tickets | 2026-08-26 | the 2026-08-12 consolidation |
| D2 | Ticketing and workflows live next to the code whose logic they describe, not centrally | 2026-08-26 | — |

## Open questions

- Does the estate roster come from the `k0d0minio` org listing, or from Neon
  (`biz.clients.github_repo`) the way the dashboard's board does? The workflow currently
  assumes the org. *Answerable by: Jamie. Blocks: nothing yet — it only affects which
  repos get checked.*
- Should `icm-board` hold the estate `.icm/docs/` research (contabilista, founder brief)
  that stayed in `jamienisbet`? *Answerable by: Jamie. Blocks: nothing.*

## Run log
| Date | Commit | What changed |
|---|---|---|
| 2026-08-26 | — | Seeded at the split. Not a `/project` run; intent taken verbatim from the session that created this repo. |
