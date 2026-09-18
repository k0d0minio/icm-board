# ICM Refactoring Verification — directive v5, 2026-09-18

*Executed against `ICM_Refactoring_Directive_v5.md` (Jamie, untracked at the Apps root),
grounded in `ICM_DryRun_Gap_Analysis.md` and `ICM_Deep_Dive_Stage_Audit.md` (`~/Downloads`).
Session boundary honoured: only `icm-board` (branch `claude/icm-refactoring-directive-v5-e5b685`)
and `sustentus` (branch `claude/icm-pipeline-file-ownership`,
[sustentus/sustentus#1138](https://github.com/sustentus/sustentus/pull/1138)) were touched. No
downstream repo was read for writing, synced, or edited. Decisions recorded: D20, D21
(`.icm/project.md`).*

## 1. Outcome in one paragraph

The pipeline template was re-founded from sustentus's current `.icm/` and split at file level:
28 **template-owned** files (`_system/template/icm-pipeline/MANIFEST`, `T` lines) are now
byte-identical between the template and sustentus, carry no repo identity, and read what is
repo-specific at runtime from three **project-owned** files (`.icm/project.json`,
`_shared/project-rules.md`, `_shared/knowledge-map.md`). `icm-sync.sh` moves exactly the
manifest's files and nothing else; two consecutive `--apply` runs against sustentus end in
`RESULT: UNCHANGED` with a clean tree. The `approve` substage is gone from the template and from
every file that routed it. `env-check.sh` and `validate-decisions.sh` exist, pass on sustentus,
and fail correctly on synthetic inputs.

## 2. Contract parity — template ↔ sustentus

`cmp` over every `T` entry after sustentus's Husky-formatted commit:

| Group | Files | Differ |
|---|---|---|
| Stage contracts | `stages/{01_scope,02_define,03_build,04_release}/CONTEXT.md` | 0 |
| Lanes | `lanes/{bug,tweak,chore,knowledge}/CONTEXT.md` | 0 |
| Intake formats | `intake/CONTEXT.md` | 0 |
| Shared doctrine | `_shared/{github,ci,stage-preamble,scope-template,conventions}.md` | 0 |
| Library | `scripts/lib/{gh,changed-files,project}.sh` | 0 |
| Factory scripts | `resolve-run validate-spec validate-intake validate-decisions new-run project-body project-labels ci-status close-out triage-report env-check` | 0 |
| Seeded outside `.icm/` | `.claude/skills/pipeline/SKILL.md`, `.github/pull_request_template.md` | 0 |

Project-owned files present in sustentus and untouched by every sync: `project.json`,
`_shared/project-rules.md`, `_shared/knowledge-map.md`, `scripts/{format,lint,validate-knowledge-map,notify}.sh`,
`runs/README.md`. `git status -- .icm` after the second apply: empty.

Identity removal (the deep-dive's acceptance grep, widened) over `_system/template/{icm-pipeline,claude-pipeline,github-pipeline}`:

```
grep -rn -E "[Ss]ustentus|Jamie|Paul|David|apps/docs|apps/help|apps/web|@sustentus|#alerts|Slack|release\.yaml|quality\.yaml|preview-smoke|Quality Project|Preview smoke|pipeline-runs|pipeline-intake|brand-guidelines|docs-sync|changelog-entry|route-request|CONVENTIONS\.md|\bhis\b|\bhimself\b|Vercel – (web|demo|docs|help)|Husky|pnpm|Nextra|\{\{|approve/|CSM"
```

returns nothing, with two deliberate exceptions: `scripts/notify.sh` names Slack as an *example*
webhook in a comment, and `scripts/lib/gh.sh:81` prints the GitHub Actions expression
`${{ github.token }}` in a help message (an Actions literal, not a template placeholder).

Vocabulary applied (`scratchpad/GENERALISATION-RULES.md` was the shared sheet): Jamie → *the
operator*; his/himself → their/themselves; Paul | David → *the author | call with … |
prototype | …*; `apps/docs/app/…` → *the docs tree (`docs_path` in `.icm/project.json`), the
pages `_shared/knowledge-map.md` names*; `/CONVENTIONS.md` → *the code rules
`_shared/conventions.md` points at*; `Quality Project` → *the repo's required checks
(`required_checks`)*; `Preview smoke` / `Vercel – web` → *the repo's smoke check (`smoke_check`)*;
`release.yaml` / Slack / `#alerts` → *the post-merge notification — `notify.sh` or a CI workflow
the repo owns (`project-rules.md` → Announcing)*; `apps/docs/archive/pipeline-runs` →
*`runs_archive` (default `.icm/runs/_done/`)*; `sustentus/sustentus` → *derived from `origin`*;
skill names → *the repo's <kind> skill, where it ships one*. The removed sustentus text was
re-homed verbatim into sustentus's `_shared/project-rules.md` (196 lines).

## 3. Sync validation — the run log

| Step | Command (from icm-board) | Result |
|---|---|---|
| Dry run | `icm-sync.sh --dry-run projects/sustentus` | `RESULT: DRY-RUN 24` — 21 updated, 3 new (`env-check.sh`, `validate-decisions.sh`, `lib/project.sh`); 8 project-owned listed present |
| Apply | `icm-sync.sh --apply projects/sustentus` | `RESULT: SYNCED 24` |
| Commit | sustentus `0fb8f81a2` (Husky ran prettier on 14 staged `.md`; `.prettierignore` now excludes the template-owned paths) | 0 template-owned files differ afterwards |
| Template edit | `env-check.sh`: `rg` demoted to a warning | — |
| Re-apply | `icm-sync.sh --apply` | `RESULT: SYNCED 1` (`scripts/env-check.sh`) → sustentus `e19672e4c` |
| **Idempotency** | `icm-sync.sh --apply` again | **`RESULT: UNCHANGED`**; `git status` clean |
| Guard | (by construction) a repo without `- profile: pipeline`, or with a dirty `.icm/`, is refused with exit 2; nothing is `mkdir`'d; nothing is deleted | — |

Phase 3.4 checks inside sustentus:

| Check | Result |
|---|---|
| `.icm/scripts/env-check.sh` | `RESULT: PASS` (1 warning: `rg` not in PATH — it is a zsh alias on this machine and no script needs it) |
| `.icm/scripts/validate-decisions.sh agentic-dashboard` | 11 ids `D-1…D-11` read from the live scope; `spec.md` and `notes.md` reported *not yet written*; `RESULT: OK` |
| same, synthetic run with `D-2` absent from `spec.md` | `define: … is MISSING D-2` · `RESULT: MISSING 1` · exit 2 (and `D-1` does not false-match `D-10`) |
| same, lane run with no scope | `RESULT: SKIP` · exit 0 |
| `.icm/scripts/close-out.sh agentic-dashboard --dry-run` | `RESULT: STOP` — front-only run, epic still live (the guard holds; GitHub reads only) |
| `icm-check.sh --repo projects/sustentus` | pipeline profile: **0 missing, 0 drift**. The baseline gaps it lists (`intake/README.md`, `_done/`, the canonical hooks and skills) are sustentus's standing exemption (D12), unchanged by this work |
| `icm-check.sh /home/jamie-nisbet/Apps` (estate) | 27 repos; `remi-ai (pipeline)` now reports 13 `pipeline drift` lines plus `not in the template's manifest: stages/01_scope/approve/CONTEXT.md` — exactly the downstream rollout's list; `serviflow` gaps pre-existing |

## 4. The `approve` removal — every home

Deleted: `_system/template/icm-pipeline/stages/01_scope/approve/`. Rewritten: `icm-check.sh`
(the manifest replaces the hardcoded list), `_system/contracts/PIPELINE.md`, the seeded
`/pipeline` router, `_system/template/README.md`, `runs/README.md`, the Scope and Define
contracts (sustentus's live-interrogation versions, generalised), `close-out.sh`'s comments.
`grep -rn approve _system .claude` now returns only gate wording (*Spec approved*, *approvable*,
"the human can approve"). remi-ai's orphan folder is reported by `icm-check.sh` and left for its
own PR (stub `downstream-rollout`).

## 5. Where the directive's text was not followed literally, and why

| Directive | Done instead | Reason |
|---|---|---|
| §5 `icm-sync.sh` with an `--exclude` list | `rsync --files-from` the manifest's `T` entries; refuses unless `- profile: pipeline` is declared; refuses a dirty `.icm/` on `--apply`; no `mkdir -p`; prints retired paths, never deletes | an exclude list propagates anything new uninvited; the intake-only abort would let a repo with no `.icm/` be created; the gap analysis §6.2 |
| §3B `env-check.sh` `chmod`s inside a check; `find` recursing into `lib/`; `en_US.UTF-8` | report-only, `chmod` behind `--fix`; `lib/` excluded (sourced, non-executable by design); any UTF-8 locale; a logged-in `gh` counts as a GitHub route; `rg` a warning | "conformance reports, it does not repair" (AGENTS.md); the analysis §4.5; `rg` is called by no script |
| §4 `{{PROJECT_NAME}}` / `{{DOCS_PATH}}` | generic references + `.icm/project.json` at runtime; no placeholder anywhere | §2B "zero template placeholders in contracts" and D12's "no substitutions" outrank the table's first column; its second column ("generic project reference") is what was applied |
| §2B `_shared/knowledge-map.md` unlisted | classified **project-owned**, stub in the template | it is a per-repo router of doc pages; syncing sustentus's would make every other repo read the wrong pages (analysis §2.5) |
| §3A manifest keys | plus `required_checks`, `runs_archive`, `intake_archive`, `smoke_check`, `personas` | the only way `ci-status.sh`, `close-out.sh`, `resolve-run.sh` and `project-labels.sh` can be identical everywhere and still work for sustentus |
| Phase 1 "add `env-check.sh` … to sustentus" by hand | added to the **template** as template-owned and delivered by the sync | otherwise the first sync would overwrite the hand copy anyway |
| Phase 3.4 "run `icm-check.sh` inside sustentus" | `--repo <path>` added; sustentus stays exempt from the estate walk | AGENTS.md standing rule; the analysis §5.5 |
| not in the directive | sustentus `.prettierignore` excludes the template-owned paths | its Husky pre-commit formats `.icm/**/*.md`; without the exclusion every commit would re-drift the contracts (D17/D19 precedent) |
| not in the directive | `close-out.sh`: epic step runs on a re-run after a partial close-out (E7); a `> Dropped:`/`superseded-by:` stub counts as settled (E6). `ci-status.sh`: newline-only split of required checks (E2/D2). `tickets-board.sh`: sustentus's `runs/` is live work now (E10) | deep-dive findings in the files being rewritten anyway; each is the difference between the "idempotent" claim and the behaviour |

## 6. What changed where

**icm-board** — `_system/template/icm-pipeline/` re-founded (28 `T` + 8 `P` files + `MANIFEST`);
`_system/scripts/icm-sync.sh` new; `icm-check.sh` reads the manifest, drift-reports `T` files,
seeds `P` stubs once (fills `project.json`'s `name`), gains `--repo`; `PIPELINE.md`,
`template/README.md`, `_system/README.md`, `AGENTS.md`, the conformance stage contract,
`.claude/settings.json`, the `/icm-check` command updated; `tickets-board.sh` premise corrected;
`.icm/project.md` D20–D21 + run log; epic `intake/pipeline-file-ownership/` (two stubs done, one
open: `downstream-rollout`).

**sustentus** (#1138, three commits) — `.icm/project.json`, `_shared/project-rules.md`,
`scripts/notify.sh`, the profile line, five allowlist entries, `.prettierignore`; the 24 synced
template-owned files; the generalised router and PR template.

## 7. Open for the next session

- **Downstream rollout** — `intake/pipeline-file-ownership/downstream-rollout.md`: remi-ai
  first (its ship-note flow re-homed as project-owned, `approve/` removed, two merged runs
  archived, five allowlist entries, the labels-job diff spelling).
- **`--repo` on an exempt repo** reports the baseline gaps too; if that noise matters, a
  pipeline-only mode is a one-flag addition.
- **Formatter collisions downstream**: a repo that formats `.icm/**/*.md` (remi-ai's glob covers
  it) needs the same `.prettierignore` entries in its rollout PR, or its first commit re-drifts.
- Both PRs are Jamie's to merge from GitHub; CI is the verdict on each.
