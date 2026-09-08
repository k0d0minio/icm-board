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
a repo that never registers that hook hydrates nothing in a cloud session — and **8 of the
17 kodominio repos with variables to hydrate are on the unwired list**: courseday (32
keys), cafe-jardim (26), messy-play (17), collabimmo (14), pierpont (14), boystomenretreat
(3), lourenco-botelho (2), little-grass-shack (1). The panel token pass closes those by
hand; the six empty ones stay silently inert until someone gives them a variable.

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

- [x] Decided whether `--fix` may merge into an existing `settings.json`, or this stays a
      hand pass
- [x] All 14 repos either register both canonical hooks or are a deliberate exception
- [x] `icm-check` reports no "exists but settings.json never registers it" warnings

## Outcome — 2026-09-08

**Option 2, Jamie's call: `--fix` learned the merge.** Recorded as **D18**, not D17 — a
concurrent session claimed D17 the same afternoon for the canonical-asset formatter
ruling. D18 narrows D7 one level down, the way D11 narrowed D3: `--fix` may append the
template's own registration for a hook the repo's settings.json does not already name
anywhere, and only that. Nothing the repo already holds is rewritten. Both the event and
the entry are read from the template, so registering a future hook is a template edit and
nothing more. Needs `jq`; without it the merge is skipped and the warning stands with the
reason attached.

Two things the implementation turned up that the stub did not predict:

- The inert-hook check had to move **after** the seeding step. It ran before, so a repo
  with no hooks at all (courseday) was seeded and left newly inert, unreported. Judged on
  the state the pass leaves behind, that repo now comes out wired.
- `jq` re-emits the whole document, so a repo that hand-packs an array onto one line gets
  it reflowed — content-identical, but visible to a repo whose CI format-checks
  `.claude/`. Accepted, and named in D18 and at the code.

`pierpont` needed no decision in the end: `--fix` already creates a settings.json from the
template when one is absent, hooks and all.

**Estate state: all 25 non-exempt repos register both hooks**, and all but `remi-ai`
carry `vercel-env-hydrate.sh` (a separated team boundary, correctly excluded).
`icm-check` reports zero "never registers" warnings. The panel token pass is unblocked.

Worth knowing for next time: this landed across three concurrent sessions plus the
machine's own sweep, and the estate log shows it — 22 repos took the fan-out under `icm
update` commits rather than reasoned ones, and `cafe-jardim`'s hook registration was
swept into a commit about whitespace (corrected on `main` in `23599fa`). courseday and
pierpont were reset mid-pass and re-landed by other sessions. Nothing was lost that
belonged to this ticket; courseday's own staged `CLAUDE.md → AGENTS.md` migration was
discarded by the sweep and is not this ticket's to restore.

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
