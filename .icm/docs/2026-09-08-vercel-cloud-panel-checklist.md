# Vercel cloud panels — the one-time token pass

> The manual half of `cloud-session-hook` (epic `vercel-env-system`). The hook is
> committed and canonical; it does nothing at all until a cloud environment panel hands
> a session a `VERCEL_TOKEN`. That pasting is Jamie's, once per repo, and this is the
> per-repo reading of what to paste and what to expect afterwards.
>
> Estate state read 2026-09-08, from the registry and the `.env.example` manifests that
> `init` seeded from Vercel — key names and target scopes, never values. Nothing in this
> file is a secret and nothing in it needs updating when a value changes in Vercel.

## The token

**One token, pasted into 24 panels.** The kodominio team token — the same value already
exported locally as `$VERCEL_TOKEN_KODOMINIO` — goes into each repo's panel under the
plain name **`VERCEL_TOKEN`**. The hook needs no team lookup because a team-scoped token
already carries its team.

Sustentus and remi-ai are separated boundaries and are **not** on this list: `icm-check`
does not seed the hook into them, and whether their repos take it is decided in their
repos, with their own team tokens.

The panel is web-only (there is no management API for it), and panel variables are
invisible to the panel's own setup script — [anthropics/claude-code#63541] — which is
why this is a `SessionStart` hook and not a setup step.

[anthropics/claude-code#63541]: https://github.com/anthropics/claude-code/issues/63541

## Before the panels: two things that are not the panel's fault

**1. Fan the hook out.** `icm-check --fix` seeds `.claude/hooks/vercel-env-hydrate.sh`
into every kodominio repo that lacks it. `session-start.sh` also changed (it invokes the
sibling), and drift is *reported, never repaired* — so that one is a copy per repo, and
`icm-check` going quiet is the proof it landed:

```bash
_system/scripts/icm-check.sh --fix ~/Apps
```

```bash
for r in ~/Apps/projects/*/; do [ -f "$r/.claude/hooks/session-start.sh" ] && cp ~/Apps/_system/template/claude/hooks/session-start.sh "$r/.claude/hooks/"; done
```

Both files then commit straight to `main` in each client repo — estate plumbing does not
go through a PR.

**2. Register the hooks where nothing registers them — done, 2026-09-08.** The hook rides
`session-start.sh`'s existing `SessionStart` entry, and thirteen repos never made that
entry: their `.claude/settings.json` had no `hooks` key at all, and `pierpont` had no
`settings.json`. That put **8 of the 17 repos with something to hydrate** out of reach.

`icm-check --fix` now merges the registration in itself — decision **D18**: it appends the
template's own entry only for a hook the repo's file does not already name, and rewrites
nothing. All 25 non-exempt repos register both hooks, and `icm-check` reports no "exists
but settings.json never registers it" warnings. Closed as
[`triage/_done/settings-json-without-hooks.md`](../intake/triage/_done/settings-json-without-hooks.md),
which records the two things the merge turned out to need.

Nothing is left to do here before the panels.

## The panels

`VERCEL_TOKEN` in every row. The hook pulls the **production** environment by default
(Jamie's call, 2026-09-08 — almost nothing runs locally). That turns out to be the only
sensible default here: **every documented key in the kodominio estate is targeted at
production**, and only six repos scope anything to `development` at all.

The count below is each repo's manifest — the keys Vercel holds for that project. It is
an **upper bound on what arrives**, not a promise: Vercel never reads a `type: sensitive`
variable back, and 248 of the estate's 464 keys are sensitive (every `*_SECRET`, every
Neon-injected `POSTGRES_*` alias, `RESEND_API_KEY`, `AUTH_SECRET`). `cafe-jardim`
documents 26 keys and a pull delivered 3 of them. So expect a hydrated file with holes in
it wherever a secret matters — that is Vercel's design, not a gap in this system, and the
generated header says so.

### Hydrates something — the whole configured estate

| Repo | Vercel project | Manifest keys |
|---|---|---|
| `agorasim` | `agorasim` | 39 |
| `courseday` | `courseday` | 32 |
| `cafe-jardim` | `cafe-jardim` | 26 |
| `jamienisbet` | *three — see below* | 25 / 20 / 19 |
| `kau-american-bbq` | `kau` | 22 |
| `vinecliff` | `vinecliff` | 22 |
| `the-library` | `the-library` | 20 |
| `casey-hebbel` | `casey-hebbel` | 19 |
| `dungeons-dragons` | `dungeons-dragons-mafra` | 19 |
| `messy-play` | `happymessmakers` | 17 |
| `collabimmo` | `collabimmo` | 14 |
| `pierpont` | `pierpont` | 14 |
| `boystomenretreat` | `boystomenretreat` | 3 |
| `lourenco-botelho` | `lourenco-botelho` | 2 |
| `barzinho` | `barzinho-proposal` | 1 |
| `escondidinho` | `escondidinho` | 1 |
| `little-grass-shack` | `little-grass-shack` | 1 |

Eight of these were the unwired ones — **courseday, cafe-jardim, messy-play, collabimmo,
pierpont, boystomenretreat, little-grass-shack, lourenco-botelho** — and all eight now
register the hook, so the token is the only thing standing between them and a hydrated
session.

`boystomenretreat` additionally hides its own manifest — a committed create-next-app
`.env*` with no `!.env.example` under it — so the notes the hook would interleave there
are not in its git. Same finding `init` and `pull` both reported; that `.gitignore`
belongs to that repo.

### A monorepo — needs one more variable

| Repo | Vercel projects | Extra panel variable |
|---|---|---|
| `jamienisbet` | `jamie-nisbet` (25 keys), `portfolio` (20), `client-referrals` (19) | `VERCEL_PROJECT=<one of the three>` |

The remote maps to three projects and a session's working directory is the repo root, so
the hook will not choose. Without `VERCEL_PROJECT` it names the three and hydrates
nothing; with it, it pulls into that project's root directory.

### No variables in Vercel at all — the token buys nothing yet

The static marketing sites. Paste the token if you want them uniform; skip them and
nothing is missing. Any of them will start hydrating the day it gains a variable.

`berceo` · `firedough` · `garmani` · `grafitala` · `le-pavillon-vert` · `miriamfridman`
· `simnao`

### If a repo should not pull production

`VERCEL_ENV_TARGET=preview` (or `development`) in that repo's panel. Worth knowing before
you decide: a cloud session's `.env.local` will hold live production configuration, and
whatever that session runs talks to production. The sensitive keys never come down, so the
file is configuration rather than credentials — but it is production configuration.

## Taking the proof

Open a cloud session on **`courseday`** (32 documented keys, the second largest set in
the estate and the one with the most prose already written) once its panel holds the token
and its `settings.json` registers the hook. The session should open with a line like:

```
Vercel env: .env.local hydrated from kodominio/courseday (production) — <n> keys, <n> documented, <n> still `# TODO: note`.
```

and `.env.local` should hold those values under the notes from the repo's own
`.env.example`. Nothing else in the working tree should have changed — in particular
`.gitignore`, which `vercel env pull` edits unprompted and the hook puts back.

## What the panel never holds

No value that is not the token. No project ids, no team slugs, no per-key configuration —
all of that is read from Vercel at session start, which is the whole point: change a
variable in the dashboard and the next cloud session simply has it. The panels are
configured once and never touched again.
