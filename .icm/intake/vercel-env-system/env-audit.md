# Stub: Env audit — the estate env report, reports and never repairs

- feature-slug: env-audit
- epic: vercel-env-system
- priority: P2
- size: M
- depends-on: example-convention-and-init
- sequence: 5 of 6
- sources: breakdown (`.icm/intake/vercel-env-system/breakdown.md`) · severity-model
  precedent: `_system/scripts/estate-conformance.sh`

## Problem

Three one-way flows with no sync means drift is expected, and drift needs a single
honest report rather than three scripts disagreeing. Nothing today can answer "is the
estate's env documentation complete and are local files current?" in one run.

## Proposed change

`vercel-env.sh audit` — read-only against the API, the registry and the local disk,
in the estate-conformance severity spirit (findings that later work would fix vs.
warnings for human judgment), with a sane exit code for scripting:

- Vercel vars absent from that app's `.env.example` — undocumented (fix: `init`).
- `.env.example` keys absent from Vercel — a deploy break waiting (fix: Jamie adds the
  value via dashboard / `vercel env add`).
- Keys whose note is empty or a `TODO` placeholder — documentation debt.
- Registry entries not `vercel link`ed, and repos on disk with a Vercel project but no
  registry entry.
- `.env.local` missing or older than a threshold (staleness, not correctness — a warn).
- Sensitive-type vars, listed so it is explicit which keys can never hydrate locally.
- Out of scope, recorded in the header: cross-project same-key value-drift comparison —
  a possible extension, deliberately not cut yet.

Reports, never repairs — no flag writes anything, matching the house conformance rule.

## Acceptance criteria (rough)

- [ ] One estate-wide run prints per-repo findings grouped by the categories above
- [ ] Exit code distinguishes clean / findings, so it can sit in a wrap ritual later
- [ ] Zero write calls to Vercel and zero file writes, any code path
- [ ] Runs with any subset of the three team tokens, skipping and naming the rest

## Prompt

Build the `audit` subcommand of the estate's Vercel env system in the icm-board repo
(`~/Apps`). Read `.icm/intake/vercel-env-system/env-audit.md` and the epic's
`breakdown.md` first, plus `_system/scripts/estate-conformance.sh` for the severity
and reporting style. Extend `_system/scripts/vercel-env.sh` with a strictly read-only
`audit` covering: undocumented Vercel vars, `.env.example` keys missing on Vercel,
empty/TODO notes, unlinked or unregistered repos, stale `.env.local`, and
sensitive-type vars. Run it estate-wide on Jamie's machine and include the first
report in the PR description. Ship as a PR on a `claude/` branch; move this stub to
the epic's `_done/` in that PR.
