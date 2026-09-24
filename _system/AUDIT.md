# Estate audit — rolling record

*Live state of the `Apps/` estate and the `~/.claude` global layer: what is broken, what is
unresolved, what has been settled. Split out of [README.md](README.md) on 2026-08-14 so
doctrine (stable) and audit (decays) stop sharing a file.*

> **Consolidated 2026-08-12:** the control layer lives at the root of the
> `k0d0minio/jamienisbet` monorepo (the Apps root); client repos moved to
> `projects/<repo>`, gitignored. The former `k0d0minio/apps-estate` repo is archived.
> References to "k0d0minio/<repo>" paths mean `projects/<repo>` on disk.

## The estate by generation

| Generation | Pattern | Repos |
|---|---|---|
| Gen 3 — ICM engineering pipeline | thin routing `CLAUDE.md` + staged `.icm/` with contracts, gates, runs | **sustentus** (reference impl — and, since 2026-08-28, the source of the estate template, decision D12) · **remi-ai** (specified, 0 runs — superseded pending its migration decision) |
| Gen 2 — ICM business workspaces | 5-layer folder-is-the-architecture, no orchestration code | jamienisbet, barzinho, agorasim |
| Gen 1 — monolithic | one big always-loaded `CLAUDE.md` + copied skill library | courseday, tenderdesk |
| Gen 0 — stubs | `@AGENTS.md` one-liner or nothing | ~15 client sites (fine — build-once-hand-off) |

## Still open — security

- **P1** barzinho history scrub: the P&L PDFs were **untracked and the ignore pattern fixed (2026-08-28)** — but both files remain in the pushed GitHub history (`k0d0minio/barzinho` remote confirmed). Rewrite history or accept it: Jamie's call, deliberately not taken in a session.
- **P1** dungeons-dragons: a Linear API key shipped in the public browser bundle via a `NEXT_PUBLIC_` prefix and has never been revoked. (Its ticket went in the D14 clean-slate purge — this line is the record until a fresh `/project` run re-cuts it.)
- **P2** Over-broad grants: remi-ai `Bash(cat > *)` and home-wide `Read()`; `git push`/`gh pr merge` on allow.
- **P3** Orphaned vercel-plugin OAuth material in `~/.claude/.credentials.json`.
- ✅ Global secrets deny-list now in place machine-wide (`.env*`, `*.pem`, `*.key`, `secrets/**`).

## Still open — broken config (pure fixes, no decision needed)

- sustentus: dead `impeccable` PostToolUse hook errors on **every** Edit/Write; two corrupted markdown tables; dead `architecture-map` + `automation-offload` links; orphaned `packages/ui/SKILL.md`.
- courseday: `CLAUDE.md` calls a `caveman-mode` skill that's named `caveman`; routes to a nonexistent `TICKETS.md`.
- remi-ai: `route-request.sh` present but unregistered while `SKILL.md` still expects it; `project-labels.sh` mislabelled read-only.
- Permission cruft: dead sustentus session grants + nonexistent scripts; tenderdesk's byte-copy of courseday's local settings; stale `~/.claude/projects/` memory dirs for pre-move paths.

## Still open — docs vs reality

The estate's consistent failure mode: **aspirational docs are richer than the running
system.** `/project` exists partly to attack this — the register records what is true, and
the run log dates it.

- sustentus `SKILLS.md` claims no test infrastructure — tests exist in `turbo.json` + CI.
- sustentus README (untouched since Jun 12) lists a nonexistent app, dead scripts, a pipeline shape that never existed.
- jamienisbet `.env.example` has **zero overlap** with the real `.env.local`.
- barzinho: the deployed `site/` app and the newest analysis file are invisible to the declared routing; deal terms duplicated in 4 files.
- learn-with-jake-van-clief: `CLAUDE.md`/`CONTEXT.md` are unfilled templates.

## Decisions needed from Jamie

1. ~~**Skills layering**~~ — decided 2026-08-26 (see Done): canonical library in
   `_system/template/claude/`, seeded + drift-reported, repo wins.
2. ~~**Pipeline upstream**~~ — answered 2026-08-28 (decision D12, `.icm/project.md`):
   Gen-3 **is** a template product, extracted from sustentus into `_system/template/`
   as tiered profiles (`contracts/PIPELINE.md`). Sustentus stayed exempt as the source until D44 (2026-09-24);
   remi-ai's zero-run `pipeline/` is superseded — its keep-or-retire call happens in
   its migration (`estate-migration/migrate-remi-ai`).
3. ~~**Hook strategy**~~ — decided 2026-08-26 (see Done): same canonical library; seeded
   hooks stay inert until a repo's `settings.json` wires them, and `icm-check` reports that.
4. ~~**Is merging a PR**~~ — answered 2026-08-27 (see Done): Claude may merge, cautiously.
5. **`gh` CLI** — banned by sustentus docs, granted in settings. Which is real?
6. **The ≤50-line `CLAUDE.md` rule** — teaching material says it, flagship repos break it. Which moves?
7. ~~**barzinho**~~ — answered 2026-08-26 (see Done): the deal is dead, so nothing gates
   the history scrub any more — `ICM-008` proceeds on its own merits.
8. **Scheduled routines** — wanted in July, none exist. First candidate: a weekly automated re-run of this audit's checks.
9. **tenderdesk / courseday** — active, migrate, or archive?

## Done (don't re-litigate)

- **garmani `.env` untracked — it was never a secret** (2026-09-03): the estate's only
  tracked env file held one variable, `NEXT_PUBLIC_SITE_URL` — public by construction
  (Next.js inlines `NEXT_PUBLIC_*` into the client bundle) and the sole `process.env.*`
  reference in the repo. Its **value was never read in a session**: the machine-wide
  `.env` deny-list held, and no workaround was attempted; the identification rests on
  the code, the repo's `AGENTS.md`, and the 45-byte file. `git rm --cached` plus the
  estate's env ignore block shipped on `claude/untrack-env` (`.env` stays on disk).
  The `k0d0minio/garmani` remote exists, so the line is in pushed history — but a public
  site URL is not a credential, so **no history scrub is warranted**, and nothing here
  needs rotating. Unlike barzinho, this closes with no P1 left behind. Follow-on parked
  in garmani's own triage: the `Dockerfile` still `COPY`s `.env`, so a fresh clone
  cannot build the image.
- **Sanity token revoked, plaintext backup deleted** (2026-08-27, ICM-007): the token
  carried in `~/.claude.json.bak-20260715` was revoked in the Sanity management console
  and the backup file removed from Jamie's machine. Both steps were his and confirmed by
  him — neither is verifiable from a session, and the token value was never read here.
  Older backup snapshots (Time Machine et al.) may still hold the string; revocation is
  what makes that harmless.
- Old vercel-plugin disabled · global `CLAUDE.md` created · Sanity MCP removed from live config · permissions deduplicated and tightened (2026-07-15).
- Global skills emptied to `~/.claude/skills-archive-2026-08-10/` · hook double-fire fixed (global defers to repo copy) · `settings.json` allow shrunk 53→9 with a deny-list added (2026-08-10).
- Client sites are build-once-hand-off — stub configs are fine, by Jamie's July answer.
- The ICM business factory retired (2026-08-12); the control layer is `_system/` + `.claude/`, not a factory.
  **Narrowly superseded 2026-08-26** (decision D3, `.icm/project.md`): the business
  processes returned as ICM *workspaces* — stage contracts + human gates under
  `workspaces/`, per `_system/contracts/WORKSPACES.md`. Nothing auto-runs; the
  never-build-an-orchestrator rule stands.
- **Skills layering + hook strategy decided** (2026-08-26, D7): the canonical estate
  assets live in `_system/template/claude/` (2 hooks, 2 skills); `icm-check.sh` seeds
  what's missing and reports drift, never overwrites — the repo's copy wins. The old
  3-way hook drift becomes visible via the drift report instead of being resolved by fiat.
- **jamienisbet** — question retired 2026-08-14: the repo *is* the estate control layer, so "run a client through it or freeze it" no longer applies.
- **Merging answered** (2026-08-27): merging a PR *is* an outward action, and Claude may
  take it — **cautiously**. Read as: green CI and a PR whose scope Jamie has seen, not a
  blanket licence. It does not widen anything else; no outbound message, no dashboard
  write, and no ticking of a human gate ever leaves a session.
- **barzinho answered** (2026-08-26, the ICM-011 adoption sweep): the deal with Karen is
  **not live**. Proposal sent 2026-06-30, her counter analysed and answered 2026-07-08,
  then silence — every later commit is estate housekeeping. Marked `lost` in Neon and
  adopted as `workspaces/deals/karen/`, folder and negotiation documents kept as
  precedent. The history-scrub urgency this question gated is therefore gone:
  `ICM-008` (untrack the P&L PDFs) stands on its own, at its own priority.
- Six commands consolidated to three; `PROCESS.md` and `WORK-TRACKING.md` retired into the commands and the specs (2026-08-14).

---

*Decision-support only. Nothing here supersedes a repo's own contracts — the repo owns its
pipeline semantics.*
