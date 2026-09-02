# Stub: .env.example convention and init — the manifest every flow reads

- feature-slug: example-convention-and-init
- epic: vercel-env-system
- priority: P1
- size: M
- depends-on: registry-and-link
- sequence: 2 of 6
- sources: breakdown (`.icm/intake/vercel-env-system/breakdown.md`) · Jamie's ruling
  2026-09-02: use the existing `.env.example`, not a new manifest file

## Problem

`.env.example` becomes the single committed source of truth for env var *documentation*
(names, notes, target environments — never values), but only 9 of 24 repos have one,
none carry notes, and there is no convention for later flows to parse. Two files saying
similar things would be drift waiting to happen, so the existing file is upgraded in
place rather than shadowed.

## Proposed change

- The convention (document it in the script header and `_system/contracts/` if a
  natural home exists — do not invent a new contract file without one): the `#` comment
  line(s) directly above a `KEY=` line are its note; an optional trailing `[targets]`
  suffix scopes it (`production`, `preview`, `development` — default all three); notes
  must fit Vercel's 500-char comment limit; keys keep empty values. A plain
  `.env.example` with no notes stays valid — the convention is additive.
- `vercel-env.sh init`: for each registry entry, list the project's current var names
  and targets over the REST API (names only — values are never fetched by this
  subcommand) and append any key missing from that app's `.env.example`, with an empty
  note line ready to fill. Creates the file where absent. **Never overwrites, reorders
  or deletes existing lines** — seed-what's-missing, the icm-check discipline.
- Fan-out: the touched `.env.example` files live in the client repos. Commit per repo
  following that repo's own conventions (sustentus and remi-ai govern themselves).
  Local disk only — cloud sessions cannot see `projects/`.
- Filling in the actual note text is Jamie's editorial pass, not this stub's — init
  leaves visible `# TODO: note` placeholders that audit (stub 5) will count.

## Acceptance criteria (rough)

- [ ] Convention written down once, in the script header (plus contract home if one
      fits) — parseable and human-first
- [ ] `init` run estate-wide: every registered app dir has a `.env.example` covering
      every Vercel var name, existing content untouched
- [ ] Rerun is a no-op when nothing changed in Vercel
- [ ] No value ever appears in a `.env.example`

## Prompt

Build the `.env.example` convention and `init` subcommand of the estate's Vercel env
system. Work from the icm-board repo (`~/Apps`); read
`.icm/intake/vercel-env-system/example-convention-and-init.md` and the epic's
`breakdown.md` first. Extend `_system/scripts/vercel-env.sh` with `init` (REST API,
per-team `VERCEL_TOKEN_<TEAM>` env vars, var names only), define the note/`[targets]`
comment convention, and run it across the registry on Jamie's machine, committing the
seeded `.env.example` files in each client repo per that repo's conventions. Ship the
script change as a PR on a `claude/` branch here; move this stub to the epic's
`_done/` in that PR.
