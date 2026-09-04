# Stub: A canonical estate asset can lose to a repo's own formatter

- feature-slug: canonical-assets-vs-repo-formatters
- lane: bug
- priority: P3
- sources: found during rails-file-is-jsonc, 2026-09-04 · CI evidence:
  k0d0minio/cafe-jardim#6, k0d0minio/dungeons-dragons#86

## What this is

`icm-check.sh` compares each repo's copy of a canonical asset against
`_system/template/` **byte-for-byte** and reports drift. A repo's formatter compares
the same file against *that repo's* style. When the two disagree, the repo has to
choose, and neither choice is good:

- **Reformat in-repo** → the check passes and `icm-check` reports permanent drift. A
  visible CI error becomes a silent one.
- **Exclude the file from the formatter** → the check passes and the file is honestly
  canonical, but the repo now carries a per-asset exemption that nothing enforces or
  remembers.

Both live repos picked the exclusion, independently, during the `.jsonc` rename:

- **cafe-jardim** — Biome, `indentStyle: "tab"`; the two-space `opencode.jsonc` took it
  12 → 13 errors. Now `"!**/opencode.jsonc"` in `biome.json`.
- **dungeons-dragons** — `format:check` over the whole tree; `opencode.jsonc` came back
  unformatted and turned a green `main` red. Now in `.prettierignore`, alongside the
  `.icm/` and `.claude/` entries that are there for the same reason.

## Why it is worth a ticket

The rails file is not special — it is just the asset that happened to move. **The same
collision is already sitting in cafe-jardim for `.claude/settings.json`**, which is in
that repo's current 12 errors and has been since before any of this. Every canonical
asset in `_system/template/` is exposed the same way, in every repo whose formatter
config differs from the template's.

It is also invisible: nothing reports that a repo has excluded a canonical asset. A repo
that quietly reformats one instead shows up only as a drift *warning*, which reads like
deliberate divergence rather than a formatter having overwritten an estate file.

## Worth knowing

Two repos is a pattern, not a coincidence — but it is a small one, and both are handled.
The bar for acting is whether a third repo hits it, or whether `.claude/settings.json`
turns out to be flagged in more places than cafe-jardim.

Options, unranked and not thought through:

1. Leave it. Per-repo exclusions, discovered by CI each time. Cheapest; the knowledge
   lives only in commit messages.
2. Have `icm-check` report canonical assets a repo excludes from its formatter. Makes
   the exemption visible, but means parsing three or four different lint configs.
3. Make the canonical assets match nothing and everything — i.e. accept that the
   template owns formatting and have repos exclude `_system/template`-derived paths as a
   class, the way `dungeons-dragons` already excludes `.icm/` and `.claude/`.

## Acceptance criteria (rough)

- [ ] Decided whether this is worth systematising at all, or stays per-repo
- [ ] If systematised: the exemption is visible somewhere a human reads
- [ ] `cafe-jardim`'s `.claude/settings.json` format error understood — same cause or not

## Prompt

Read `.icm/intake/triage/canonical-assets-vs-repo-formatters.md` in the icm-board repo
(`~/Apps`). Estate canonical assets are drift-checked byte-for-byte against
`_system/template/`, but each repo's formatter checks them against its own style; when
those disagree the repo must either reformat (silent permanent drift) or exclude the file
(an invisible exemption). Two repos hit this during the `opencode.jsonc` rename and both
chose exclusion. Settle with Jamie whether this is worth systematising or stays per-repo,
and check first whether `cafe-jardim`'s `.claude/settings.json` format error has the same
cause. Run on Jamie's machine — `projects/*` is local-only.
