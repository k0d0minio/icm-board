# Rollout — the ticket base branch (D38) and the estate template sync, 2026-09-23

*Stub 4 of `ticket-base-branch` (`.icm/intake/ticket-base-branch/ticket-base-rollout.md`), run
the same night as stub 3 (k0d0minio/icm-board#68) and a decision-numbering review. Jamie's
rulings in the session: sync all six pipeline repos, stub 3 first; the session merges the sync
PRs and carries `main` into `uat`; the session creates the `type:tickets` labels; Jamie prunes
agorasim's Neon branches himself.*

## Before

Every pipeline repo's template-owned files matched the template **at its own stamp**, byte for
byte, so no repo had edited a `T` file in place. The drift was lag only: five repos at `5bef762`
(25 files behind, `lib/db-name.mjs` and `lib/mongo.mjs` missing) and sustentus at `be76910`
(17 behind). Neither stamp is a commit on icm-board's `main`: `5bef762` is #60's pre-squash head
(its template tree is identical to the merged one), and `be76910` is #64's branch before its
rebase over #66, a D35–D37-without-D38 template that `main` never held
(`triage/icm-sync-stamps-unmerged-commit`).

## What was done

| Repo | Sync PR | `uat` | Canonical `.claude/` refreshed | Label | Result |
|---|---|---|---|---|---|
| berceo | k0d0minio/berceo#23 merged | `main` merged into `uat` by hand: `promote-uat.sh sync` STOPped on conflicts. #21 on `uat` had carried its own `5bef762` sync, so every template file conflicted. Template files resolved to `main` (`de444cd`); `project-rules.md`, `AGENTS.md` and `README.md` resolved to `uat`, whose text was newer and already held `main`'s additions; `batch.json` kept `uat`'s batch | wrap-reminder, ticket-craft, pr-conventions, pipeline, setup | created | **in sync, `main` and `uat`** |
| agorasim | k0d0minio/agorasim#121 **open** | not yet | same five | created | Vercel preview failed "Resource provisioning failed": the Neon project is at its 10-branch cap (below) |
| jamienisbet | k0d0minio/jamienisbet#149 merged | — | same five + vercel-env-hydrate | created | in sync |
| remi-ai | k0d0minio/remi-ai#121 merged | — | same five | created | in sync |
| sustentus | sustentus/sustentus#1153 merged | — | same five; its own `session-start.sh` left alone | created | in sync. `Vercel – web` red: `main`'s web build runs out of memory since #1150 (another session has a hotfix open); `Quality Project`, the one required check, passed |
| vinecliff | k0d0minio/vinecliff#19 merged | — | same five | created | in sync |

Every sync added `type:tickets` to the repo's `.github/labels.yml`. Every sync was cut in a
worktree off `origin/main` and never on the shared checkout. Every checkout was left on `main`,
clean.

## The berceo proof

k0d0minio/berceo#24 took the ticket PR's shape: branch `claude/tickets-uat-address-20260923` cut
from `origin/uat`, label `type:tickets`, body `announce: none` / `audience: internal`. The path
guard (`git diff --name-only origin/uat...HEAD`) listed only
`.icm/intake/triage/uat-address-dns.md`. It was merged at once with `--squash --admin` through
the merge gate's bypass. `tickets-board.sh` shows the stub, read from `origin/uat`, while `main`
does not carry it. The stub itself is real work: `uat.berceo.be` does not resolve, so the
client cannot open UAT.

One-off check: `promote-uat.sh status` → `UAT 1 stub(s) · unapproved · main ahead 0`. The one
stub `_done` on `uat` and still open on `main` (`plateforme-v1/socle-design-system`) is the
unpromoted batch. It is lag, not a gap.

## Found on the way

- **`neon-cleanup.yaml` never ran on a private repo.** `permissions: {}` makes `actions/checkout`
  answer "Repository not found". Every agorasim PR close failed. Seven `preview/claude/*`
  branches of merged PRs (#114–#120) piled up to Neon's 10-branch cap, and the next preview could
  not get a database. The template is fixed in k0d0minio/icm-board#69 (merged, `contents: read`),
  and agorasim's copy rides #121. berceo is public, so its copy works; it carries the old line
  and is a reference file, left as is.
- **The board never showed a client repo's Today pick**: it keyed `projects/<repo>`, while
  `today.md` names the bare repo. Fixed in #68.
- **jamienisbet's `ticket-base-branch` epic cited D37** for the ticket rule. Fixed in
  k0d0minio/jamienisbet#148.

## Still owed

1. **Jamie:** delete the seven stale `preview/claude/*` branches in Neon project
   `nameless-sea-98952497` (agorasim), keeping `main`, `preview/uat` and
   `run/admin-quote-builder`.
2. Then re-run agorasim#121's preview (a new push, or Vercel's redeploy), merge it, and bring
   `main` into `uat` (expect the same conflict shape as berceo if `uat` carries its own sync).
   Also prove one ticket PR on agorasim; it has no ruleset, so a plain squash.
3. The jamienisbet stub `ticket-base-branch/dashboard-reads-ticket-base`: the dashboard still
   reads each repo's default branch.
4. `icm-check.sh`: after agorasim, no `pr-conventions` / `ticket-craft` drift should remain.

## 2026-09-24 — agorasim

Jamie pruned the Neon project, taking `run/admin-quote-builder` with the seven previews; its run had merged as #120, so nothing was lost. #121 merged (`99bf7d5`). `promote-uat.sh sync` stopped again: `uat` had carried its own sync. Only three template files conflicted (`database-migration` skill, `references/tools.md`, `template-version`), and all three were resolved to `main`'s. `uat` was pushed; `status` reads `UAT 1 stub(s) · unapproved · main ahead 0`. The fixed cleanup workflow ran green on #121's close. It found nothing to delete, because Vercel skipped the preview as not affected, so the delete path is still unproven on a live branch. **All six pipeline repos are now at `de444cd`.** Still owed: one real ticket PR on agorasim, and the jamienisbet dashboard stub.
