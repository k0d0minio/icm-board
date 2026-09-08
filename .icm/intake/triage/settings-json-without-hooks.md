# Stub: 13 estate repos carry canonical hooks their settings.json never registers

- feature-slug: settings-json-without-hooks
- lane: chore
- priority: P2
- sources: found building `cloud-session-hook` (epic `vercel-env-system`), 2026-09-08 ·
  `icm-check.sh` already names the condition · panel checklist:
  `.icm/docs/2026-09-08-vercel-cloud-panel-checklist.md`

## What this is

`icm-check --fix` seeds `.claude/hooks/session-start.sh` and `wrap-reminder.sh` into
every repo, but it never touches an existing `settings.json` — and in **13 kodominio
repos that file has no `hooks` key at all**, so both hooks sit there inert. `pierpont`
has no `settings.json` whatsoever. The script reports it per repo ("hook … exists but
settings.json never registers it"), and has done for as long as the check has existed;
nothing has acted on it.

Unwired: `boystomenretreat`, `cafe-jardim`, `collabimmo`, `courseday`, `firedough`,
`garmani`, `grafitala`, `le-pavillon-vert`, `little-grass-shack`, `lourenco-botelho`,
`messy-play`, `miriamfridman`, `simnao` — plus `pierpont` with no file. 12 repos are
wired, and the estate's `settings.json` files are otherwise divergent enough (16 of 25
differ from the template) that a blanket overwrite is not the answer.

## Why it is worth a ticket now

It stopped being cosmetic. `vercel-env-hydrate.sh` is invoked *by* `session-start.sh`, so
a repo that never registers that hook hydrates nothing in a cloud session — and **every
kodominio repo that has values to hydrate today is on the unwired list**: courseday,
messy-play, pierpont, collabimmo, cafe-jardim. The panel token pass closes it by hand for
those five; the other nine stay silently inert.

## Worth knowing

The edit itself is small and identical everywhere — the `hooks` block from
`_system/template/claude/settings.json`, merged into whatever the repo already has. What
needs deciding is whether `icm-check --fix` should make it, which stretches "creates only
what is missing, existing files are never touched" from files to keys within a file. A
`jq` merge that adds only absent `SessionStart`/`Stop` entries and never rewrites an
existing one is arguably the same discipline one level down; it is also the first time
the script would edit a hand-owned file, which is exactly the line D7 draws.

Options, unranked:

1. Fourteen hand edits, once, and the report goes quiet. No policy change.
2. Teach `--fix` the `jq` merge, gated to hook entries the repo does not already name.
3. Leave it, and let each repo wire itself when someone next opens it.

## Acceptance criteria (rough)

- [ ] Decided whether `--fix` may merge into an existing `settings.json`, or this stays a
      hand pass
- [ ] All 14 repos either register both canonical hooks or are a deliberate exception
- [ ] `icm-check` reports no "exists but settings.json never registers it" warnings

## Prompt

Read `.icm/intake/triage/settings-json-without-hooks.md` in the icm-board repo (`~/Apps`).
Thirteen kodominio repos carry the canonical `session-start.sh` and `wrap-reminder.sh`
hooks with a `settings.json` that has no `hooks` key, and `pierpont` has no
`settings.json` at all, so those hooks — and the `vercel-env-hydrate.sh` sibling they
invoke — never run. Settle with Jamie whether `icm-check --fix` may merge missing hook
entries into an existing settings.json (decision D7 says it never touches existing files)
or whether this is a one-time hand pass, then close it either way. Run on Jamie's machine
— `projects/*` is local-only. Estate plumbing commits straight to `main` in each client
repo, not through a PR.
