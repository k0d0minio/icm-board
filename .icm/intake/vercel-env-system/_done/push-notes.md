# Stub: Push notes — .env.example comments land on Vercel

- feature-slug: push-notes
- epic: vercel-env-system
- priority: P1
- size: S
- depends-on: example-convention-and-init
- sequence: 3 of 6
- sources: breakdown (`.icm/intake/vercel-env-system/breakdown.md`) · Jamie's ruling
  2026-09-02: notes flow repo → Vercel, edit in git, push out

## Problem

Vercel's per-var `comment` is the note Jamie wants visible in the dashboard, but the
CLI cannot set it — only the REST API can — and nothing connects the notes now living
in `.env.example` to the platform. Notes are repo-authoritative by ruling: git is where
they are edited, Vercel is where they are mirrored.

## Proposed change

- `vercel-env.sh push-notes`: for each registry entry, parse `.env.example` per the
  convention, list the project's env vars over the API, and for every key that exists
  in Vercel, set its `comment` to the note (strip the `[targets]` suffix — targets are
  structure, not prose). `PATCH /v9/projects/{id}/env/{envId}` with the per-team token.
- **Comments only.** The subcommand never creates a variable, never touches a value,
  type or target. A key documented in `.env.example` but absent from Vercel is
  *reported* (it is audit's finding too), never created — creating would mean inventing
  a value.
- Idempotent: skip when the comment already matches; safe to rerun estate-wide.
  Placeholder notes (`TODO`) are skipped, not pushed.
- Sensitive-type vars accept comments like any other — only their values are
  write-only.

## Acceptance criteria (rough)

- [ ] After an estate-wide run, every noted key in every registered project shows its
      note in the Vercel dashboard
- [ ] A run with no `.env.example` changes makes zero write calls
- [ ] Values, types and targets verifiably untouched (spot-check via `vercel env ls`
      timestamps)
- [ ] Keys missing on Vercel are listed at the end of the run, not created

## Prompt

Build the `push-notes` subcommand of the estate's Vercel env system in the icm-board
repo (`~/Apps`). Read `.icm/intake/vercel-env-system/push-notes.md` and the epic's
`breakdown.md` first; the parsing convention and registry already exist from earlier
stubs. Extend `_system/scripts/vercel-env.sh`: parse each registered `.env.example`,
upsert Vercel comments via the REST API with the per-team `VERCEL_TOKEN_<TEAM>`
tokens, comments only, idempotent. Run it estate-wide on Jamie's machine and report
what was set and what was skipped. Ship as a PR on a `claude/` branch; move this stub
to the epic's `_done/` in that PR.
