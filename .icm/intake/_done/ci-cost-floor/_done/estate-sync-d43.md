# Stub: The rest of the estate takes the template — sync the T files, the other CI workflows when touched

- feature-slug: estate-sync-d43
- epic: ci-cost-floor
- priority: P2
- size: S
- depends-on: template-contract
- sequence: 7 of 7
- sources: D43 · `.icm/docs/2026-09-24-github-actions-audit.md` (the public repos)

## Problem

The five rollout PRs sync the T files in the repos they touch. vinecliff and serviflow are on
the template and were not part of the rollout; cafe-jardim, collabimmo, courseday,
dungeons-dragons and escondidinho carry a hand-written `ci.yml` (separate lint / build / test
jobs, `push` to `main` and `develop`, a `next build`) but are public and cost nothing today.

## Proposed change

- `icm-sync.sh --apply` vinecliff and serviflow (serviflow: Railway, no Vercel status — its
  verdict is Railway's; `required_checks` stays whatever it declares).
- The five public non-pipeline repos take the `quality.yaml` shape the next time a session is
  in them — not a fan-out for its own sake.
- Global `~/.claude/hooks/block-local-checks.sh` and each repo's copy: the doctrine comment
  names CI as the verdict for format/lint/typecheck; reword to the deploy + the advisory job.
  Behaviour unchanged (the changed-files scripts never matched the hook).

## Acceptance

- [ ] `icm-check.sh` reports no T-file drift on vinecliff and serviflow.

## Prompt

Read `.icm/intake/ci-cost-floor/estate-sync-d43.md`. Sync the two repos; leave the public five
for their next session.
