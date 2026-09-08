# Stub: A canonical estate asset can lose to a repo's own formatter

- feature-slug: canonical-assets-vs-repo-formatters
- lane: bug
- priority: P3
- sources: found during rails-file-is-jsonc, 2026-09-04 · CI evidence:
  k0d0minio/cafe-jardim#6, k0d0minio/dungeons-dragons#86
- settled: 2026-09-08 — stays per-repo (decision D17)
- superseded in part: 2026-09-08, same day — both revisit triggers fired on
  `courseday`'s adoption. The ruling stands; the surface below was wrong.
  Follow-up: `triage/canonical-assets-markdown-collision.md`

## Outcome

**Option 1: leave it.** Per-repo exclusion, discovered by that repo's CI, is the rule.
No estate machinery. The bar this stub set for acting — a third repo, or
`.claude/settings.json` flagged beyond `cafe-jardim` — is not met, and the survey that
checked it shrank the problem rather than confirming it.

Recorded as **D17** in [`project.md`](../../../project.md); the rule and the surface are
written into [`_system/template/README.md`](../../../../_system/template/README.md), which
is what someone seeding a canonical asset reads.

## What the survey found

**The exposed surface is two files, not one** — corrected; this section said *one* on the day, and `courseday` disproved it the same day. Formatters in this
estate touch JSON/JSONC and markdown. Of the drift-checked assets that leaves:

- `hooks/session-start.sh`, `wrap-reminder.sh`, `vercel-env-hydrate.sh` — shell. Neither
  Biome nor Prettier formats it.
- `skills/ticket-craft/SKILL.md`, `skills/pr-conventions/SKILL.md` — markdown. **This
  survey read them as safe and was wrong.** The evidence was `remi-ai` running
  `prettier --check "**/*.{ts,tsx,md}"` over `.claude/` and `.icm/` and staying green —
  which held for that glob, not for `prettier --check .`. `pr-conventions/SKILL.md`
  failed the moment `courseday` was adopted, hours later.
- `opencode.jsonc` — collides.

**And only in some repos.** Nine repos carry a formatter config; six invoke one in CI:

| repo | formatter in CI | style | canonical assets in scope |
|---|---|---|---|
| `cafe-jardim` | `biome check .` | tab | **collides** — `opencode.jsonc` excluded |
| `dungeons-dragons` | `prettier --check .` | 2sp | **collided** — `opencode.jsonc` excluded, `.icm/` + `.claude/` already were |
| `escondidinho` | `biome check` | 2sp/2 | agrees with the template; red for 92 lint errors of its own |
| `courseday` | `prettier --check .` | 2sp | **collides** — recorded here as "agrees; carries no `opencode.jsonc`" because it was unadopted. Adopting it (#277) put five files in scope and failed all five: `pr-conventions/SKILL.md`, `.icm/CONTEXT.md`, `opencode.jsonc`, `.icm/project.md`, `AGENTS.md` |
| `remi-ai` | `prettier --check "**/*.{ts,tsx,md}"` | 2sp | markdown assets in scope and green; `.jsonc` outside the glob |
| `sustentus` | `format:check` | — | exempt from the baseline |

`collabimmo` has a tab `biome.json` its CI never runs (CI runs ESLint) — latent, not a
hit. The remaining seventeen repos run no formatter at all.

**The trap in this table** is the last column: it records what each repo had *in scope on
the day*, which for an unadopted repo is nothing. `courseday` looked safe because it
carried none of the assets yet. Adoption is what creates the collision, so a survey of
adopted repos systematically under-counts — which is exactly how this one reached "one
file".

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
      (D17). Held on contact: applied as written, `courseday` went green in one commit —
      but on a surface twice the size this stub measured, and re-opened the same day
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

## Revisit — fired, same day

Both conditions this stub set were met within hours, by `courseday`'s adoption
(k0d0minio/courseday#277): the markdown assets collide, and it is the third colliding
repo. The case for a class-level exclusion is back on the table, and three repos have now
independently hand-written one — `dungeons-dragons`, `courseday`, and `cafe-jardim` for
the rails file. Carried in `triage/canonical-assets-markdown-collision.md`.
