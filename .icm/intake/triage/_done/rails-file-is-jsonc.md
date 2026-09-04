# Stub: The rails `opencode.json` is JSONC, and repo linters read it as strict JSON

- feature-slug: rails-file-is-jsonc
- lane: bug
- priority: P2
- sources: found during push-gate-propagation, 2026-09-03 · introduced by
  `_system/template/root/opencode.json` in PR #25 · CI evidence:
  k0d0minio/escondidinho#2, k0d0minio/cafe-jardim#5

## What this is

PR #25 added a six-line `//` comment to the canonical rails file recording that bash
permissions are last-match-wins, so the `claude/*` push allow must stay *below* the
ask. The comment is worth having — swapping those two lines silently restores the old
behaviour, and nothing else records that. But it makes the file **JSONC, not JSON**.

OpenCode parses its own config as JSONC, so the rails work everywhere. Repo tooling
does not necessarily agree. During propagation two repos broke:

- **escondidinho** — `"lint": "biome check"` over `includes: ["**", …]`. `main` was
  fully green before the rails change and went red on nine parse errors.
- **cafe-jardim** — `"lint": "biome check ."`, same failure stacked on top of the
  pre-existing red already parked as that repo's `triage/lint-red-on-main.md`.

Both were unblocked by adding `"!**/opencode.json"` to `files.includes` in the repo's
`biome.json`, committed alongside the gate change. That is a fix, but it is a fix that
now has to be remembered for every repo that ever adopts the rails.

Two repos were only accidentally spared:

- **collabimmo** carries a `biome.json` with the same `includes: ["**/*", …]`, but its
  `lint` script is `eslint`. It breaks the day it switches to `biome check`.
- The Prettier repos (dungeons-dragons, garmani, remi-ai, sustentus) tolerate comments
  in `.json` and were unaffected.

## The decision

Not obviously one or the other, which is why this is parked rather than patched:

1. **Keep JSONC.** Add the `!**/opencode.json` ignore to the estate baseline so every
   repo carries it, and have `icm-check` report its absence. Keeps the comment where
   the footgun is. Cost: the baseline now reaches into each repo's lint config.
2. **Make the rails file strict JSON.** Move the ordering doctrine into `AGENTS.md`
   (or a sibling `opencode.md`) and drop the comment from the template. Every repo's
   file is then valid JSON, no lint accommodation anywhere. Cost: the warning no
   longer sits next to the two lines it is about — exactly where it is needed.

Whichever way it goes, the change is a template edit plus a re-propagation pass, so
it wants doing before the next repo adopts the rails.

## The ruling — 2026-09-04, recorded as D16

**Neither. A third option: rename the file to `opencode.jsonc`.**

The two options above trade the comment against the lint accommodation. The extension
buys both. OpenCode reads `opencode.jsonc` natively (project config, same precedence),
and `.jsonc` declares the dialect to every other tool — Biome 2.x parses it with
comments allowed, so `**/*` linting stops caring. The comment stays next to the two
lines it is about, no repo needs an ignore to *parse* it, and `collabimmo` stops being a
latent break the day it switches to `biome check`.

Cost, paid in this pass: the canonical asset renames in `_system/template/root/`,
`icm-check.sh` (`CANONICAL_ROOT`), `estate-conformance.sh`, and all 24 rails-carrying
repos; the two `!**/opencode.json` ignores in `escondidinho` and `cafe-jardim` no longer
match anything and are removed. Both scripts now warn on a leftover `opencode.json` at
any repo root — a half-finished rename, or a second config OpenCode also reads.

### What the rename did not fix

CI proved one thing the ruling assumed away. Once the file is `.jsonc`, a repo linting
`**/*` **includes** it — it parses, but it is also format-checked. `cafe-jardim` formats
with tabs and the canonical file is two-space, so its PR went 12 → 13 errors with a
single new `opencode.jsonc format`. Reformatting the file in-repo would trade that
visible error for silent permanent drift (canonical assets are compared byte-for-byte),
so the exclusion went back in as `!**/opencode.jsonc` — for formatting, not parsing.

It reached a second repo: `dungeons-dragons` runs `format:check` over the whole tree, and
the renamed file came back unformatted and turned a green `main` red. It is now in that
repo's `.prettierignore` beside the `.icm/` and `.claude/` entries that are there for the
same reason.

This is not new and not specific to the rails file: cafe-jardim's `.claude/settings.json`,
also a canonical estate asset, is already in the same error list (see its
`triage/lint-red-on-main.md`). Two repos is a pattern, so the general question is cut as
`triage/canonical-assets-vs-repo-formatters.md` rather than answered here.

## What CI proved

24 rails repos, one PR each on `claude/opencode-jsonc`; icm-board #26 alongside.

- **23 green.** Including `escondidinho`, which no longer needs its ignore at all, and
  `collabimmo`, which was the latent break the ruling was meant to defuse.
- **`cafe-jardim` red at 12 errors** — byte-identical to its `main`, which has been red
  since 2026-08-30 (`triage/lint-red-on-main.md`). The rename added one error and the
  formatter exclusion took it back off.
- **`sustentus` code check green**, Vercel previews still deploying. It is exempt from
  the baseline but carries the rails, so it was renamed with the rest.

No repo needed an ignore to parse the file — which was the whole question.

## Acceptance criteria (rough)

- [ ] Decision recorded on whether the rails file stays JSONC
- [ ] Template and all rails-carrying repos consistent with that decision
- [ ] `collabimmo` no longer a latent break (ignore present, or comment gone)
- [ ] `icm-check` covers whichever invariant was chosen

## Prompt

Read `.icm/intake/triage/rails-file-is-jsonc.md` in the icm-board repo (`~/Apps`) and
the canonical `_system/template/root/opencode.json`. The rails file carries `//`
comments, so it is JSONC; repos that lint `**/*` with Biome reject it as strict JSON,
and two already needed a `"!**/opencode.json"` ignore in their `biome.json`. Put the
two options in the stub to Jamie, take his ruling, then make the template and every
rails-carrying `projects/*` repo consistent with it — one PR per repo on a `claude/`
branch, CI is the source of truth, no local checks. Run on Jamie's machine: the
`projects/*` repos are local-only.
