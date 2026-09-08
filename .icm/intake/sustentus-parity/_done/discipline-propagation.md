# Stub: Carry the updated pr-conventions skill to all 23 client repos, one PR each

- feature-slug: discipline-propagation
- epic: sustentus-parity
- priority: P1
- size: L
- depends-on: intake-agent-economy
- sequence: 4 of 6
- sources: breakdown (`.icm/intake/sustentus-parity/breakdown.md`) · Jamie's ruling 2026-09-03 —
  per-repo PRs, no `--sync` tooling · precedent: `opencode-executor/push-gate-propagation`
  (24 repos, commit 179cd26) · byte-drift check 2026-09-03: all 23 client copies of
  `pr-conventions/SKILL.md` identical to the template

## Problem

Template edits reach only repos fixed *after* the edit. `icm-check.sh --fix` creates only what is
missing; a repo's existing copy is never touched, and divergence is reported as drift and never
repaired — repos own their copies (D7, `_system/template/README.md`).

So the moment stub 3 lands, all 23 client copies become drift: the improvement exists in the
template and in none of the repos that need it. Every one of those repos is a small Vercel site
whose sessions are the ones burning turns on deploy-event noise.

Jamie's ruling 2026-09-03: keep D7, no sync tool. Propagate by hand, one PR per repo — the same
way `push-gate-propagation` carried the narrowed OpenCode push gate across the estate.

## Proposed change

One pass over `projects/`, driven from the local disk — `projects/` is gitignored in icm-board and
invisible to cloud sessions, so this cannot run in the cloud.

For each of the 23 repos carrying `.claude/skills/pr-conventions/SKILL.md`:

1. **Re-verify byte-identity against the pre-change template** before copying. A repo that has
   drifted in the meantime is listed and **skipped**, never overwritten — D7 is not suspended
   because a rollout is convenient.
2. Copy in the updated canonical skill; branch `claude/pr-conventions-agent-economy`; commit
   touching that one file only.
3. Push and open the PR. Read each result from the checks — never subscribe to the PRs this stub
   opens, which is the rule it is shipping.

Finish with `_system/scripts/icm-check.sh` showing no `pr-conventions` drift across the estate,
and a short report in `.icm/docs/` naming any repo skipped and why.

`courseday` and `pierpont` are out — they carry no `.icm/` at all and are tracked separately in
`.icm/intake/triage/courseday-pierpont-unadopted.md`. Sustentus is exempt.

## Acceptance criteria (rough)

- [ ] Every repo whose copy was byte-identical to the pre-change template now carries the new one
- [ ] Any repo that had drifted is named in the report and left untouched
- [ ] One PR per repo on a `claude/` branch, each touching only
      `.claude/skills/pr-conventions/SKILL.md`
- [ ] No PR opened by this stub is subscribed to
- [ ] `icm-check.sh` reports zero `pr-conventions` drift afterwards
- [ ] A dated report lands in `.icm/docs/` listing repos changed, skipped, and why

## Prompt

Roll the updated `pr-conventions` skill out to the estate, from the icm-board repo (`~/Apps`) —
**on the local machine only**, since `projects/` is gitignored here and invisible to cloud
sessions. Read `.icm/intake/sustentus-parity/discipline-propagation.md` and the epic's
`breakdown.md` for full context; `.icm/intake/opencode-executor/_done/push-gate-propagation.md`
is the precedent for the fan-out. For each repo under `projects/` carrying
`.claude/skills/pr-conventions/SKILL.md`, first confirm its copy is byte-identical to the
template as it stood before the `intake-agent-economy` change — skip and report any that drifted,
never overwrite one — then copy in the new canonical skill and open one PR per repo on a
`claude/` branch touching only that file. Skip `courseday`, `pierpont` and `sustentus`. Do not
subscribe to any PR you open; read results from the checks. Finish by running
`_system/scripts/icm-check.sh` to confirm zero drift, and write a dated report into `.icm/docs/`
naming what changed and what was skipped. Do not run local checks — CI is the source of truth.
Move this stub to the epic's `_done/` in the icm-board PR that carries the report.
