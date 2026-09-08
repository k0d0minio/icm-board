# Vercel cloud panels — the one-time token pass

> The manual half of `cloud-session-hook` (epic `vercel-env-system`). The hook is
> committed and canonical; it does nothing at all until a cloud environment panel hands
> a session a `VERCEL_TOKEN`. That pasting is Jamie's, once per repo, and this is the
> per-repo reading of what to paste and what to expect afterwards.
>
> Estate state read 2026-09-08, from the registry, the `.env.example` manifests and the
> `.env.local` files the 2026-09-08 estate-wide `pull` left on disk. Nothing in this file
> is a secret and nothing in it needs updating when a value changes in Vercel.

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

**2. Register the hooks where nothing registers them.** The hook rides
`session-start.sh`'s existing `SessionStart` entry, and **13 kodominio repos never make
that entry**: their `.claude/settings.json` has no `hooks` key at all (and `pierpont` has
no `settings.json`). That is a pre-existing estate gap — those repos get no board
greeting either — but it lands squarely on this epic, because **every repo that has
something to hydrate today is one of them**. `icm-check` names them ("hook … exists but
settings.json never registers it"); the fix is the `hooks` block from
`_system/template/claude/settings.json`, merged into each repo's own file by hand.

Unwired, in the order it matters: **pierpont** (no settings.json at all), **courseday**,
**messy-play**, **collabimmo**, **cafe-jardim** — then boystomenretreat, firedough,
garmani, grafitala, le-pavillon-vert, little-grass-shack, lourenco-botelho, miriamfridman,
simnao. Parked as
[`triage/settings-json-without-hooks.md`](../intake/triage/settings-json-without-hooks.md).

## The panels

`VERCEL_TOKEN` in every row. The last column is what the row buys **today** — the key
count a `development` pull actually delivered on 2026-09-08, which is what a cloud
session will find in `.env.local`.

### Hydrates immediately — do these five first

These are the repos where the proof can be taken. All five are also in the unwired list
above, so both edits happen together.

| Repo | Vercel project | Keys a development pull delivers |
|---|---|---|
| `courseday` | `courseday` | 24 |
| `messy-play` | `happymessmakers` | 17 |
| `pierpont` | `pierpont` | 14 |
| `collabimmo` | `collabimmo` | 13 |
| `cafe-jardim` | `cafe-jardim` | 3 |

### Has variables, but nothing reachable at `development`

The token still belongs here — it costs nothing and the repo is ready the moment values
exist — but a session in one of these will report an empty hydrate and say why. Two ways
to close it, both Jamie's call per repo: add `development` values in Vercel, or set
`VERCEL_ENV_TARGET=preview` in that repo's panel. (The estate holds **no**
development-scoped variables outside these few; `audit` also found 248 of 464 keys are
`type: sensitive`, and Vercel never reads those back at all — which is why `cafe-jardim`
documents 26 development keys and delivers 3.)

| Repo | Vercel project | Manifest keys | Delivered |
|---|---|---|---|
| `agorasim` | `agorasim` | 39 | 0 |
| `kau-american-bbq` | `kau` | 22 | 0 |
| `vinecliff` | `vinecliff` | 22 | 0 |
| `the-library` | `the-library` | 20 | 0 |
| `casey-hebbel` | `casey-hebbel` | 19 | 0 |
| `dungeons-dragons` | `dungeons-dragons-mafra` | 19 | 0 |
| `boystomenretreat` | `boystomenretreat` | 3 | 0 |
| `lourenco-botelho` | `lourenco-botelho` | 2 | 0 |
| `barzinho` | `barzinho-proposal` | 1 | 0 |
| `escondidinho` | `escondidinho` | 1 | 0 |
| `little-grass-shack` | `little-grass-shack` | 1 | 0 |

`boystomenretreat` additionally hides its own manifest — a committed create-next-app
`.env*` with no `!.env.example` under it — so the notes the hook would interleave there
are not in its git. Same finding `init` and `pull` both reported; that `.gitignore`
belongs to that repo.

### A monorepo — needs one more variable

| Repo | Vercel projects | Extra panel variable |
|---|---|---|
| `jamienisbet` | `jamie-nisbet`, `portfolio`, `client-referrals` | `VERCEL_PROJECT=<one of the three>` |

The remote maps to three projects and a session's working directory is the repo root, so
the hook will not choose. Without `VERCEL_PROJECT` it names the three and hydrates
nothing; with it, it pulls into that project's root directory.

### No variables in Vercel at all — the token buys nothing yet

The static marketing sites. Paste the token if you want them uniform; skip them and
nothing is missing. Any of them will start hydrating the day it gains a variable.

`berceo` · `firedough` · `garmani` · `grafitala` · `le-pavillon-vert` · `miriamfridman`
· `simnao`

## Taking the proof

Open a cloud session on **`courseday`** (24 keys, the largest development set in the
estate) once its panel holds the token and its `settings.json` registers the hook. The
session should open with a line like:

```
Vercel env: .env.local hydrated from kodominio/courseday (development) — 24 keys, <n> documented, <n> still `# TODO: note`.
```

and `.env.local` should hold those values under the notes from the repo's own
`.env.example`. Nothing else in the working tree should have changed — in particular
`.gitignore`, which `vercel env pull` edits unprompted and the hook puts back.

## What the panel never holds

No value that is not the token. No project ids, no team slugs, no per-key configuration —
all of that is read from Vercel at session start, which is the whole point: change a
variable in the dashboard and the next cloud session simply has it. The panels are
configured once and never touched again.
