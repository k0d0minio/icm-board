# Stub: Pull documented — .env.local generated with its notes inline

- feature-slug: pull-documented
- epic: vercel-env-system
- priority: P1
- size: S
- depends-on: example-convention-and-init
- sequence: 4 of 6
- sources: breakdown (`.icm/intake/vercel-env-system/breakdown.md`) · Jamie's ruling
  2026-09-02: values flow Vercel → local only

## Problem

`vercel env pull` writes a bare `.env.local` — values with no explanation — and
overwrites the whole file each run. Local files should carry the same documentation
the dashboard now shows, and pulling by hand across ~24 repos and three monorepos is
exactly the toil the system exists to remove.

## Proposed change

- `vercel-env.sh pull`: for each registry entry, `vercel env pull .env.local --yes`
  (development target — the local-dev default) with the per-team token, then rewrite
  the generated file interleaving each key's note from `.env.example` as `#` line(s)
  directly above it. Keys Vercel returns that `.env.example` lacks get pulled bare —
  audit's finding, not pull's problem.
- One-way: the subcommand never writes anything back to Vercel, and never edits
  `.env.example`.
- Known caveats, stated in the script header: sensitive-type vars are write-only and
  will simply be absent locally; production-only vars don't arrive in a development
  pull; the whole file is regenerated each run, so local-only overrides belong in
  `.env.development.local`, never `.env.local`.
- Verify every touched `.env.local` is gitignored in its repo before writing; refuse
  and report where it is not (the garmani lesson).

## Acceptance criteria (rough)

- [ ] `pull` run estate-wide leaves every registered app dir with a current, readable,
      note-annotated `.env.local`
- [ ] A repo whose `.env.local` would be git-tracked is refused with a clear message
- [ ] No write to Vercel or `.env.example` in any code path
- [ ] Monorepo app dirs each get their own correct file

## Prompt

Build the `pull` subcommand of the estate's Vercel env system in the icm-board repo
(`~/Apps`). Read `.icm/intake/vercel-env-system/pull-documented.md` and the epic's
`breakdown.md` first; registry, tokens and the `.env.example` convention exist from
earlier stubs. Extend `_system/scripts/vercel-env.sh`: per registry entry run
`vercel env pull` with the right team token, then interleave the `.env.example` notes
into the generated `.env.local`, refusing any repo where that file is not gitignored.
Run estate-wide on Jamie's machine. Ship as a PR on a `claude/` branch; move this stub
to the epic's `_done/` in that PR.
