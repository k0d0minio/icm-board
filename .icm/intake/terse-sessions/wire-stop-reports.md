# Stub: Every stop reports in one shape — the ten stop steps, the four skills, the handoff template

- feature-slug: wire-stop-reports
- epic: terse-sessions
- priority: P2
- size: M
- depends-on: output-doctrine
- sequence: 2 of 3
- sources: the breakdown · stop steps: `_system/template/icm-pipeline/stages/01_scope/CONTEXT.md:164`,
  `02_define/CONTEXT.md:113`, `03_build/CONTEXT.md:192-199`, `04_release/CONTEXT.md:234`,
  `lanes/bug/CONTEXT.md:73`, `lanes/chore/CONTEXT.md:69`, `lanes/tweak/CONTEXT.md:70`,
  `lanes/hotfix/CONTEXT.md:76`, `lanes/handover/CONTEXT.md:51`, `lanes/knowledge/CONTEXT.md` ·
  `_system/template/claude-pipeline/skills/{pipeline,setup}/SKILL.md` ·
  `.claude/skills/{pr-conventions,ticket-craft}/SKILL.md` and their `_system/template/claude/skills/`
  twins · `_shared/run-pack/handoff.md`

## Problem

With the doctrine written (stub 1), nothing yet cites it. Each stop step still phrases its own
"tell the user", and the canonical skills — which also run in repos with no pipeline, so no
`.icm/_shared/` to point at — say nothing about output at all.

## Proposed change

- **Stop steps (4 stages + 6 lanes):** replace each freeform "tell the user/operator …" with
  "Report per `_shared/output.md`", keeping only what is stage-specific, recast as `Operator:`
  items or the outcome line — e.g. Build's preview URLs become `- [ ] smoke the previews:
  <urls>`, then `- [ ] tick Ready to merge`. The pointer lives in each stop step, **not** only in
  `stage-preamble.md`: Scope, Define and the lanes never run the preamble.
- **Mid-session line:** one sentence in `stage-preamble.md`'s isolation rules or the router
  (`/pipeline` SKILL.md) pointing at the doctrine's "while working" rule — wherever every
  stage and lane is sure to load it; decide by reading, not by adding it everywhere.
- **Skills:** `/pipeline` and `/setup` cite `.icm/_shared/output.md`. `pr-conventions` and
  `ticket-craft` carry the rule **inline** (three or four lines: one line per phase change, the
  stop shape, never-trimmed), since they run in non-pipeline repos too. Both copies of each
  canonical skill byte-identical.
- **`_shared/run-pack/handoff.md`:** the Blockers placeholder names the operator form —
  `blocked on operator: <act>` — and a one-line note that non-blocking operator acts live in
  the chat checklist, not here.
- Bump nothing by hand in client repos: the sync is `icm-sync.sh --apply <repo>` on Jamie's
  word, after merge, recorded in the log.

## Acceptance criteria (rough)

- [ ] `grep -n "Tell the user\|tell the operator" _system/template/icm-pipeline/{stages,lanes}` returns only STOP-reason lines inside steps, none in a stop step's sign-off
- [ ] every stage and lane stop step names `_shared/output.md`
- [ ] `diff -q` clean between each canonical skill and its template twin; `self-check.sh` green on CI
- [ ] one real run on the first synced repo ends in the stop shape (checked by Jamie reading it)

## Prompt

In icm-board (`~/Apps`), carry out stub 2 of the `terse-sessions` epic: read
`.icm/intake/terse-sessions/breakdown.md`, this stub (`wire-stop-reports.md`) and
`_system/template/icm-pipeline/_shared/output.md` (written by stub 1). Make every stage and
lane stop step in `_system/template/icm-pipeline/` report per that doctrine instead of its own
freeform sign-off, point `/pipeline` and `/setup` at it, give the canonical `pr-conventions`
and `ticket-craft` skills the rule inline (both copies byte-identical), and add the
`blocked on operator:` form to the `handoff.md` run-pack template. Do not sync any client
repo. One PR on a `claude/` branch; CI is the verdict.
