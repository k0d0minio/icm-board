# template — canonical scaffold + asset library for the estate

Consumed by `_system/scripts/icm-check.sh`:

1. **The baseline** `--fix` seeds when a repo is missing it (never overwrites).
2. **The canonical Claude-asset library** — the estate-wide hooks and skills every repo
   should carry. Seeded when missing; **drift is reported, never repaired** — repos own
   their copies (decision D7, [`.icm/project.md`](../../.icm/project.md)).
3. **The pipeline profile** — seeded *only* into repos whose `.icm/CONTEXT.md` declares
   `- profile: pipeline` ([contracts/PIPELINE.md](../contracts/PIPELINE.md)). Declaring
   the profile is Jamie's act; the fix never upgrades one.

Sustentus is exempt (its `.icm/` is authoritative — it is the source this template was
extracted from, decision D12).

```
icm/                             → copied to <repo>/.icm/           (every live repo)
  CONTEXT.md                     ← the repo's .icm map; carries the `- profile:` line
  intake/
    README.md                    ← micro-copy of contracts/TICKETS.md
    triage/_done/.gitkeep        ← the parking lane
    _done/.gitkeep               ← the archive (completed epics + legacy tickets)
  docs/.gitkeep                  ← ad hoc reports land here (estate convention)
claude/                          → copied to <repo>/.claude/        (every live repo)
  settings.json                  ← clean policy: schema + secrets deny-list + hook wiring
  hooks/
    session-start.sh             ← the repo's own board greets every session
    wrap-reminder.sh             ← Stop hook: unpushed .icm changes block the stop once
  skills/
    ticket-craft/SKILL.md        ← the intake contract as working knowledge
    pr-conventions/SKILL.md     ← branches, commits, CI-is-truth, no secrets
icm-pipeline/                    → copied to <repo>/.icm/           (pipeline profile only)
  stages/{01_define,02_build,03_release}/   lanes/{bug,tweak,chore}/
  _shared/{github,ci,stage-preamble}.md   runs/README.md
  scripts/{resolve-run,validate-spec,validate-intake,new-run,ci-status}.sh
claude-pipeline/                 → copied to <repo>/.claude/        (pipeline profile only)
  skills/pipeline/SKILL.md       ← the /pipeline router
github-pipeline/                 → copied to <repo>/.github/        (pipeline profile only)
  pull_request_template.md       ← carries both gate anchors
```

Rules:

- **Never overwrite.** The script only creates what's missing; existing files win. In a
  repo whose `settings.json` predates the hook wiring, the hook files are seeded but
  inert — the drift report says so, and wiring them is Jamie's per-repo call
  (`/icm-check` step 3 proposes it).
- **Drift is a report line, not a repair.** `icm-check.sh` compares each repo's copy of
  a canonical asset against this folder and warns on divergence. Deliberate divergence
  is fine — the repo wins — but it should be visible, not silent.
- **No substitutions.** Nothing in the template is templated per repo: identity is the
  `epic/slug` path (no prefixes), and the pipeline scripts derive the GitHub repo from
  `origin` (override with `GITHUB_REPO`). A copy is exact, which is what makes the drift
  report honest.
- Template edits here propagate only to repos fixed *after* the edit; the script never
  retro-syncs existing files. That is deliberate — repos own their copies, and the
  drift report is how divergence stays honest.
