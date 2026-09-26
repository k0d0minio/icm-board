# Estate audit — rolling record

*Live state of the `Apps/` estate and the `~/.claude` global layer: what is broken, what is
unresolved, what has been settled. Split out of [README.md](README.md) on 2026-08-14 so
doctrine (stable) and audit (decays) stop sharing a file. Rewritten on 2026-09-26 from the
full estate audit ([`.icm/docs/2026-09-26-estate-audit.md`](../.icm/docs/2026-09-26-estate-audit.md))
and Jamie's rulings on it; every line below was verified that day.*

> The control layer is this repo, `k0d0minio/icm-board` (decision D1, 2026-08-26); every other
> repo Jamie owns is cloned under `projects/<repo>`, gitignored here. `projects/serviflow` is
> David Hamilton's consultancy clone — hands-off, never audited or synced from here.

## The estate by shape

| Shape | Repos |
|---|---|
| Pipeline (template-owned `.icm/`, synced by `icm-sync.sh`) | agorasim, berceo, casey-hebbel, jamienisbet, lourenco-botelho, remi-ai, sustentus, vinecliff |
| Active, no pipeline | dungeons-dragons |
| Dormant (`.icm/dormant`; baseline only) | barzinho, boystomenretreat, cafe-jardim, collabimmo, courseday, escondidinho, firedough, garmani, grafitala, kau-american-bbq, le-pavillon-vert, little-grass-shack, messy-play, miriamfridman, pierpont, simnao, the-library, and the ten cloned on 2026-09-26 (ericeirafishing, gui-demo, houseoftherisingmojo, maja-grunzner, sell-my-stuff, shake-easy, website-starter; curated-property, event-flow and flow-stage are archived on GitHub) |

## Still open — security

- **P0 Visibility.** This repo is **public** until Jamie flips it at the end of September 2026
  (it went public to recover Actions minutes). Its deal folders, quotes and `_system/AUDIT.md`
  are readable by anyone until then; the five `private/` files were untracked on 2026-09-26
  (`triage/retrack-deal-private-after-flip`). Public client repos track client documents:
  remi-ai (`registre-des-actionnaires.pdf` and 61 other docs under `.icm/docs/`), agorasim
  (proposal, commission agreement, prices PDFs), berceo (`berceo-answers.pdf`, the cahier).
  Jamie's call per repo: private, or purge from history.
- **P0 kau-american-bbq** (public, dormant since 2026-09-26): the seeded admin password is still
  tracked in `drizzle/0006_kau_accounts_and_settings.sql:9`. Rotate it, then strip it — the
  pick-up note in the repo's `AGENTS.md` says so; the value is deliberately not repeated here.
- **P1 barzinho history scrub** — Jamie ruled "scrub it all" on 2026-09-26; see Done once the
  rewrite and force-push land.
- **P2** `Bash(git push:*)` sits on the tracked allow-list of agorasim, remi-ai and sustentus.
- **P3** Orphaned vercel-plugin OAuth material in `~/.claude/.credentials.json`.
- ✅ Global secrets deny-list in place machine-wide (`.env*`, `*.pem`, `*.key`, `secrets/**`).
- ✅ Estate-wide credential grep over tracked files (2026-09-26): clean apart from a serviflow
  `sk_test_placeholder` literal.

## Still open — broken config

- sustentus: `.claude/settings.local.json:57` (untracked, machine-local) still registers an
  `impeccable` PostToolUse hook whose `hook.mjs` does not exist.
- courseday (dormant): `AGENTS.md:77` names a `caveman-mode` skill; the folder is `caveman`.
- garmani (dormant): `.env` is tracked (only `NEXT_PUBLIC_SITE_URL`, public by construction);
  the 2026-09-03 "untracked on `claude/untrack-env`" note below was wrong — no such branch or
  PR ever existed. Not a secret; untrack it when the repo is next touched.
- sustentus: `release.yaml`'s announce step failed on every run from 2026-09-25 (`report.sh` →
  Slack `invalid_json`) — the curl config bug is fixed in the template and in sustentus's copy
  on 2026-09-26; verify with `report.sh selftest` on the next release.

## Still open — docs vs reality

The estate's consistent failure mode: **aspirational docs are richer than the running
system.** `/project` and the register exist to attack this.

- sustentus `CLAUDE.md`'s monorepo table omits `apps/agent`, `apps/console` and `apps/e2e`
  (stub `claude-md-monorepo-table-omits-agent-and-console`).
- agorasim `.icm/docs/launch-runbook.md:30-31,39` still describes the pre-D39 gating model.
- remi-ai `.icm/intake/README.md` carries the decision register D-1…D-24 and a status table
  that mirrors (and contradicts) the folders; the decisions need a home
  (`.icm/project.md` does not exist there yet).
- Layer 0 over the 90-line ceiling (`icm-check.sh` warns): remi-ai 140, sustentus 98,
  icm-board 96 (`triage/trim-agents-md-to-90-lines`), berceo 93, agorasim 91. Long guidance
  belongs in `.claude/rules/*.md` scoped by `paths:`.

## Decisions needed from Jamie

Everything numbered 1–9 in earlier versions is settled (below). Open now:

1. **Public client repos with client documents** — private (Actions cost) or purge (history
   rewrite), per repo: remi-ai, agorasim, berceo.
2. **agorasim's non-production Neon project** — still on the Free plan's 10-branch cap
   (`triage/neon-uat-branch-limit-blocks-previews`): pay, shorter TTL, or fewer concurrent runs?

## Done (don't re-litigate)

- **Rulings of 2026-09-26** (the estate audit): the template's stub fields are the contract
  (`scope:`, `scope-slug:`, `complexity:`); `## Prompt` is optional and the board sends only
  the verb and the slug; dropped work is deleted or archived, never left open; a front run
  archives with its scope; cafe-jardim and kau-american-bbq are dormant altogether; serviflow
  is hands-off; remi-ai runs one database with preview and production and no UAT; barzinho
  and escondidinho are dormant; every repo Jamie owns is on disk; `estate-conformance.sh`
  is retired in favour of the `estate-housekeeping` routine running `icm-check.sh`; the four
  commands are skills; OpenCode agent twins live in `.opencode/agents/`.
- **AUDIT #5, the `gh` CLI (closed 2026-09-26)**: no sustentus document bans it any more; the
  template's own `lib/gh.sh` uses it and the only grants are two specific `gh pr create`
  lines in a local settings file. Nothing to decide.
- **AUDIT #6, the Layer-0 size rule (closed 2026-09-26)**: the "≤50 lines" teaching material
  no longer exists; the conformance contract's 30–90 stands and `icm-check.sh` warns above 90.
- **AUDIT #8 scheduled routines (closed)**: the `estate-housekeeping` desktop routine runs
  `/day` steps 1–2 daily and stops at the gate. **AUDIT #9 (closed)**: tenderdesk is gone from
  the org; courseday is dormant.
- **garmani `.env` — it was never a secret** (2026-09-03): one variable, `NEXT_PUBLIC_SITE_URL`,
  public by construction. The untrack recorded then never landed (see Broken config); no
  history scrub is warranted either way.
- **Sanity token revoked, plaintext backup deleted** (2026-08-27): both steps Jamie's and
  confirmed by him; the token value was never read in a session.
- Old vercel-plugin disabled · global `CLAUDE.md` created · Sanity MCP removed from live
  config · permissions deduplicated and tightened (2026-07-15).
- Global skills emptied to `~/.claude/skills-archive-2026-08-10/` · hook double-fire fixed
  (global defers to repo copy) · `settings.json` allow shrunk 53→9 with a deny-list added
  (2026-08-10).
- Client sites are build-once-hand-off — stub configs are fine, by Jamie's July answer.
- The ICM business factory retired (2026-08-12); the business processes returned as ICM
  *workspaces* (D3, 2026-08-26) — contracts and human gates, never a driver.
- **Skills layering + hook strategy decided** (2026-08-26, D7): canonical assets in
  `_system/template/claude/`; `icm-check.sh` seeds what's missing and reports drift, never
  overwrites — the repo's copy wins.
- **Merging answered** (2026-08-27): merging a PR is an outward action Claude may take,
  cautiously — green CI and a PR whose scope Jamie has seen, never a blanket licence.
- **barzinho answered** (2026-08-26): the deal with Karen is not live; folder kept as
  precedent.
- Six commands consolidated to three; `PROCESS.md` and `WORK-TRACKING.md` retired (2026-08-14).

---

*Decision-support only. Nothing here supersedes a repo's own contracts — the repo owns its
pipeline semantics.*
