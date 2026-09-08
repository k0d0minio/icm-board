# Stub: A canonical estate asset can lose to a repo's own formatter

- feature-slug: canonical-assets-vs-repo-formatters
- lane: bug
- priority: P3
- sources: found during rails-file-is-jsonc, 2026-09-04 · CI evidence:
  k0d0minio/cafe-jardim#6, k0d0minio/dungeons-dragons#86
- settled: 2026-09-08 — stays per-repo (decision D17)

## Outcome

**Option 1: leave it.** Per-repo exclusion, discovered by that repo's CI, is the rule.
No estate machinery. The bar this stub set for acting — a third repo, or
`.claude/settings.json` flagged beyond `cafe-jardim` — is not met, and the survey that
checked it shrank the problem rather than confirming it.

Recorded as **D17** in [`project.md`](../../../project.md); the rule and the surface are
written into [`_system/template/README.md`](../../../../_system/template/README.md), which
is what someone seeding a canonical asset reads.

## What the survey found

**The exposed surface is one file, not the whole asset library.** Formatters in this
estate touch JSON/JSONC and markdown. Of the drift-checked assets that leaves:

- `hooks/session-start.sh`, `wrap-reminder.sh`, `vercel-env-hydrate.sh` — shell. Neither
  Biome nor Prettier formats it.
- `skills/ticket-craft/SKILL.md`, `skills/pr-conventions/SKILL.md` — markdown that
  satisfies Prettier's defaults today. `remi-ai` runs `prettier --check "**/*.{ts,tsx,md}"`
  with no `.claude/` or `.icm/` exclusion and is green.
- `opencode.jsonc` — the only one that collides.

**And only in some repos.** Nine repos carry a formatter config; six invoke one in CI:

| repo | formatter in CI | style | canonical assets in scope |
|---|---|---|---|
| `cafe-jardim` | `biome check .` | tab | **collides** — `opencode.jsonc` excluded |
| `dungeons-dragons` | `prettier --check .` | 2sp | **collided** — `opencode.jsonc` excluded, `.icm/` + `.claude/` already were |
| `escondidinho` | `biome check` | 2sp/2 | agrees with the template; red for 92 lint errors of its own |
| `courseday` | `prettier --check .` | 2sp | agrees; carries no `opencode.jsonc` |
| `remi-ai` | `prettier --check "**/*.{ts,tsx,md}"` | 2sp | markdown assets in scope and green; `.jsonc` outside the glob |
| `sustentus` | `format:check` | — | exempt from the baseline |

`collabimmo` has a tab `biome.json` its CI never runs (CI runs ESLint) — latent, not a
hit. The remaining seventeen repos run no formatter at all.

Note `dungeons-dragons` did not collide on indent width: both sides are two-space, and
Prettier still rewrote the JSONC structurally. So the trigger is "the repo's formatter
output differs from the template bytes", of which tab-vs-space is only the loudest case.

## `.claude/settings.json` — same cause, no dilemma

Confirmed from CI (`cafe-jardim` run 34250246711): the failure is exactly the tab-vs-space
diff, one of twelve Biome errors — the other eleven are that repo's own `.tsx`/`.ts` and
`package.json`.

But **`settings.json` is not a drift-checked asset.** It is absent from `CANONICAL` in
[`icm-check.sh`](../../../../_system/scripts/icm-check.sh): required to exist, seeded when
missing, never compared. Every repo edits its own hook wiring, which is the point. So
reformatting it costs nothing — there is no drift to go silent. It was reformatted to
tabs in `cafe-jardim` rather than given a second exemption.

That dissolves half of what this stub was built on. D16 and the template README both
asserted `settings.json` was flagged "for the same reason"; the formatter reason was
right, the consequence was not. Both are corrected.

## Acceptance criteria

- [x] Decided whether this is worth systematising at all, or stays per-repo — **per-repo**
- [x] If systematised: the exemption is visible somewhere a human reads — n/a; the *rule*
      is in `_system/template/README.md`, and each repo's exclusion carries a comment
      giving its reason (`dungeons-dragons`' `.prettierignore` already does)
- [x] `cafe-jardim`'s `.claude/settings.json` format error understood — same cause, but
      the file is not drift-checked, so it was reformatted

## Rejected

- **Have `icm-check` report canonical assets a repo excludes.** Parsing Biome, Prettier
  and ignore-file syntaxes to police one file in one repo.
- **Seed a template-derived ignore class into every repo.** Reaches into each repo's lint
  config — the same ground D16 already rejected for `opencode.json` parse failures.

## Revisit if

A third repo genuinely collides, or a formatter-checked repo starts failing on the
markdown assets — that would mean the surface is two files, not one, and the case for a
class-level exclusion returns.
