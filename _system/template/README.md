# template — canonical scaffold + asset library for the estate

Consumed by `_system/scripts/icm-check.sh`:

1. **The baseline** `--fix` seeds when a repo is missing it (never overwrites). Its two
   micro-copies, `icm/CONTEXT.md` and `icm/intake/README.md`, are drift-reported like the
   canonical assets below — never repaired (decision D45).
2. **The canonical Claude-asset library** — the estate-wide hooks and skills every repo
   should carry. Seeded when missing; **drift is reported, never repaired** — repos own
   their copies (decision D7, [`.icm/project.md`](../../.icm/project.md)).
3. **The pipeline** — seeded into **every** repo ([contracts/PIPELINE.md](../contracts/PIPELINE.md);
   decision D22 retired the `- profile:` gate). What varies per repo is `complexity` in
   its own `.icm/project.json`, never which files it carries.
4. **The new-shape root assets** — seeded *only* into repos that already carry an
   `AGENTS.md` (epic `opencode-sidecar`). Migrating a repo's Layer 0 is Jamie's act; the
   fix never performs the move.

The pipeline was extracted from sustentus (decision D12); since D44 the template is the one
source and sustentus is measured like any repo. The pipeline was re-founded on sustentus's
current four-stage shape (Scope → Define → Build → Release, no substage) on 2026-09-18,
generalised rather than parameterised, and split at file level into **template-owned**
and **project-owned** files (decision D20, `icm-pipeline/MANIFEST`). Template-owned files
are byte-identical in every pipeline repo — sustentus included — and `icm-sync.sh` is how
they get there; project-owned files are seeded once and never touched again.

```
root/                            → copied to <repo>/                (migrated repos only)
  CLAUDE.md                      ← the one-line `@AGENTS.md` importer
  opencode.jsonc                 ← the estate's OpenCode rails (deny local checks, ask on push)
  .opencode/agents/{auditor,project-lens,ticket-scout}.md
                                 ← the same three agents in OpenCode's shape (`description`,
                                    `mode: subagent`, `permission.edit: deny`): OpenCode reads
                                    only .opencode/agents/, never .claude/agents/ (2026-09-26)
  .opencode/plugins/icm-session-env.js
                                 ← OPTIONAL, never required or drift-checked: the shell.env
                                    bridge that exports OPENCODE_SESSION_ID so usage-snapshot.sh
                                    can read its own numbers; Jamie's machine carries the same
                                    file in ~/.config/opencode/plugins/ (agency brief §4.4a)
icm/                             → copied to <repo>/.icm/           (every live repo)
  CONTEXT.md                     ← the repo's .icm map
  intake/
    README.md                    ← micro-copy of contracts/TICKETS.md
    triage/_done/.gitkeep        ← the parking lane
    _done/.gitkeep               ← the archive (completed epics + legacy tickets)
  docs/.gitkeep                  ← ad hoc reports land here (estate convention)
claude/                          → copied to <repo>/.claude/        (every live repo)
  settings.json                  ← clean policy: schema + secrets deny-list + hook wiring
  hooks/
    session-start.sh             ← the repo's own board greets every session
    install-deps.sh              ← async: installs deps so Husky's pre-commit exists (D44)
    route-request.sh             ← UserPromptSubmit: routes a bare stage form to /pipeline
    route-request.test.sh        ← its fixture test — run by hand, never a hook or a check
    wrap-reminder.sh             ← Stop hook: unpushed .icm changes block the stop once
    vercel-env-hydrate.sh        ← cloud sessions pull their .env.local from Vercel
  agents/
    auditor.md                   ← read-only executor the audit skills fork into
    project-lens.md              ← one-lens read-only analysis, /project fans several out
    ticket-scout.md              ← read-only scan for undocumented work and ticket candidates
  skills/
    ticket-craft/SKILL.md        ← the intake contract as working knowledge
    pr-conventions/SKILL.md     ← branches, commits, CI-is-truth, no secrets
icm-pipeline/                    → copied to <repo>/.icm/           (every adopted repo — D22)
  MANIFEST                       ← the ownership list: T template-owned · P project-owned.
                                    Read by icm-check.sh AND icm-sync.sh — and itself a T
                                    file, so every repo carries `.icm/MANIFEST` and setup.sh
                                    can answer "complete?" offline (D23). `icm-sync.sh --apply`
                                    and `setup.sh --fix` write `.icm/template-version` beside it
  stages/01_scope/               ← the front: source verbatim → settled live in session →
                                    scope.md (D-n decisions) → the intake cut. No substage
  stages/{02_define,03_build,04_release}/                                            (T)
  lanes/{bug,tweak,chore,knowledge}/  lanes/hotfix/ (human-invoked, opens READY)
  lanes/handover/ (the deal's last lane)                                              (T)
  intake/CONTEXT.md              ← breakdown/stub formats, triage, archive rules       (T)
  _shared/{github,ci,stage-preamble,scope-template,conventions}.md                    (T)
  _shared/output.md              ← the output doctrine: one stop-report shape, terse chat (D40)  (T)
  _shared/promotion.md           ← OPTIONAL in effect, always seeded: one branch, two targets —
                                    the client's UAT (a Vercel custom environment deployed from
                                    main), the batch since the last published Release, the
                                    client's word as a draft Release the operator publishes,
                                    the promotion the release workflow makes (D39). Inert
                                    until /setup declares `uat` in project.json        (T)
  _shared/template-change.md     ← the guard: a T file (or a canonical .claude/ asset) asked
                                    to change IN a repo is a template change request — a prompt
                                    for icm-board parked as a triage stub, never an edit there (T)
  _shared/run-pack/{project,plan,tasks,decisions,status,handoff,FAILURE}.md
                                 ← the canonical file pack run-pack.sh seeds into every
                                    run: context card, passes, DoD queue, D-n ledger,
                                    five-line status, handoff, retrospectives            (T)
  _shared/{project-rules,knowledge-map}.md   ← this repo's rules and doc pages         (P)
  skills/README.md  skills/{security-audit,database-migration,preview-deploy}/
                                 ← three-tier capability skills: SKILL.md front matter
                                    (Level 1, list-skills.sh prints it), body (Level 2,
                                    loaded on a trigger), references/ + scripts/ (Level 3) (T)
  project.json                   ← the project manifest (name, complexity, docs_path,
                                    archives, required checks/env, smoke check, and the
                                    deploy · reporting · migrations · support blocks) —
                                    --fix fills name                                   (P)
  runs/README.md                 ← the repo's own note on its runs                     (P)
  raw/README.md  raw/_processed/.gitkeep  processed/.gitkeep
                                 ← the drop folder for what a client sent, its archive,
                                    and where process-raw.sh writes the extracted text —
                                    recordings transcribed locally (ffmpeg + whisper.cpp),
                                    never committed                                    (T)
  output/.gitkeep                ← where client-status.sh writes client-status-latest.md
                                    (the client's view; committing it is the repo's call)  (T)
  scripts/lib/{gh,changed-files,project,vercel,neon}.sh  scripts/lib/model-prices.json (T)
  scripts/lib/{mongo,db-name}.mjs  ← run with node (the MongoDB transport on the repo's own
                                    driver; the one database-name rule the app imports — D35) (T)
  scripts/{resolve-run,validate-spec,validate-intake,validate-decisions,new-run,
           project-body,project-labels,ci-status,close-out,triage-report,env-check,
           select-model,check-migrations,process-raw,
           deploy-status,rollback,usage-snapshot,env,setup,retrospective,
           list-skills,db-branch,security-check,run-pack,health-check,
           client-status,promote}.sh                                              (T)
                                    select-model.sh routes complexity × stage → tier
                                    (haiku · sonnet · opus/fable; advisor for Scope and
                                    Define, executor for Build and the lanes, validator
                                    for a lint fix); check-migrations.sh enforces the UTC
                                    millisecond stamp (V<17>__name.sql — or the epoch form
                                    <13>-name.<ext> a MongoDB runner writes, D34) and names
                                    new files (--new); db-branch.sh binds a run to its own
                                    schema, container, Neon branch or MongoDB database, and
                                    on MongoDB proves the migrations' round trip (prove); security-check.sh is the
                                    pre-commit zero-trust gate (gitleaks + npm audit, a
                                    built-in fallback, a redacted trace in the run's
                                    error.log); run-pack.sh seeds and checks the pack;
                                    health-check.sh reads the declared health_endpoint
                                    once after the merge (Release 9a) — a failure is
                                    report.sh alert plus one uncommitted bug-lane stub
  scripts/{format,lint,validate-knowledge-map,report}.sh   ← the repo's own hooks      (P)
                                    report.sh is the reporting hook: complete as seeded,
                                    steered by project.json → reporting, never edited.
                                    notify.sh is RETIRED — reported by icm-sync.sh for git rm
claude-pipeline/                 → copied to <repo>/.claude/        (every adopted repo — D22)
  skills/pipeline/SKILL.md       ← the /pipeline router (seeded; drift-reported)
  skills/setup/SKILL.md          ← /setup: the report, the questions, the P files (seeded; drift-reported)
github-pipeline/                 → copied to <repo>/.github/        (every adopted repo — D22)
  pull_request_template.md       ← carries both gate anchors
  workflows/{release,quality}.yaml ← REFERENCE workflows: seeded ONCE by /setup — release.yaml
                                    into a repo whose reporting.announce_from is `ci` AND into
                                    every repo that declares `uat` (it is the promotion, D39) —
                                    deliberately NOT in icm-check.sh's PIPELINE_GITHUB list, so
                                    the estate walk never seeds a workflow uninvited
  workflows/db-migrate.yml       ← REFERENCE production migrator: push to main without UAT;
                                    workflow_call from release.yaml with UAT (D39 (5)). The
                                    repo's own steps replace the reference Node/Drizzle ones
  workflows/uat-deploy.yaml      ← REFERENCE, only where Vercel refuses to let the UAT custom
                                    environment track main: vercel deploy --target=<uat.target>
  workflows/{neon,mongodb}-cleanup.yaml ← REFERENCE workflows: seeded ONCE by /setup where the
                                    database block asks for one (D32, D35) — drop a closed
                                    PR's preview and run databases
```

Layer 0 itself — `AGENTS.md`, or a legacy full `CLAUDE.md` — is **never templated**.
Each repo writes its own identity and routing; an empty one would read as established
intent. Only the importer is canonical, because it is identical everywhere.

`vercel-env-hydrate.sh` hydrates a cloud session's environment from the Vercel team a repo
deploys under, keyed on plain `VERCEL_TOKEN` — each Claude Code cloud environment carries its
own team's token, so one file serves every team. The 2026-09-02 boundary ruling that kept it
out of sustentus and remi-ai is retired (D44). It is the one hook `settings.json` does not
register — `session-start.sh` invokes it when it is there. `install-deps.sh` and
`route-request.sh` are canonical in every repo and inert where they have nothing to do: no
Husky `prepare` script, no `/pipeline` skill.

Rules:

- **Never overwrite.** The script only creates what's missing; existing files win. In a
  repo whose `settings.json` predates the hook wiring, the hook files are seeded but
  inert — the drift report says so, and wiring them is Jamie's per-repo call
  (`/icm-check` step 3 proposes it).
- **Both Layer-0 shapes are legal while the rollout runs.** A repo satisfies the
  identity check with *either* a legacy `CLAUDE.md` *or* `AGENTS.md`; only a repo with
  neither warns. `root/` is gated on `AGENTS.md` being present precisely so that an
  un-migrated repo gains no gap and no warning from a move it has not made yet — the
  moment its Layer 0 lands, `--fix` seeds the importer and `opencode.jsonc` beside it.
  Retiring the legacy tolerance is a decision for after the rollout, with evidence.
- **The rails file is `.jsonc`, and the extension is the point.** It carries a `//`
  comment recording that bash permissions are last-match-wins, so the `claude/*` push
  allow must stay *below* the ask — swap those two lines and every push asks again, and
  nothing else in the estate records that. OpenCode reads `opencode.jsonc` natively, and
  the extension declares the dialect to every other tool: a repo linting `**/*` with
  Biome parses a `.json` file as strict JSON and fails on the comment, which is exactly
  what took `escondidinho` and `cafe-jardim` red in September 2026. `icm-check.sh` warns
  on a leftover `opencode.json` at any repo root.
- **A canonical asset can lose to a repo's *formatter*, and the repo excludes it.** The
  `.jsonc` rename ends the parse failures; it does not make a two-space canonical file
  match a repo that formats with tabs. Reformatting a drift-checked asset in-repo is the
  wrong trade — it swaps a visible CI error for silent permanent drift — so the repo
  excludes it from formatting. `cafe-jardim` does that for `opencode.jsonc` in
  `biome.json`; `dungeons-dragons` does it in `.prettierignore`, alongside the `.icm/`
  and `.claude/` entries already there for the same reason. It stays a per-repo call,
  discovered by that repo's CI — decision D17, settled 2026-09-08, its revisit
  fired and closed as D19 on 2026-09-09.
  **The exposed surface is two files: `opencode.jsonc` and `skills/*/SKILL.md`.** Of the
  drift-checked assets the three `hooks/*.sh` are shell, which no formatter in the estate
  touches; the rest are markdown and JSONC, and both collide. A first survey (2026-09-04)
  read the markdown as safe because `remi-ai` checks `**/*.{ts,tsx,md}` and is green —
  that held for its glob, not for `prettier --check .`. Adopting `courseday` put five
  files in scope at once and failed all five, `skills/pr-conventions/SKILL.md` among them
  (k0d0minio/courseday#277, 2026-09-08). Assume any canonical file that is not a shell
  script can collide in a repo that formats its whole tree.
  **And the collision is a property of the repo's config, not of the asset.** The four
  copies of `pr-conventions/SKILL.md` in the estate are byte-identical to this folder's:
  the same bytes pass under Prettier's defaults and fail under courseday's `printWidth:
  100`, while `ticket-craft/SKILL.md` passes under both. So there is no formatting of
  these files that would end this — Biome-with-tabs and Prettier-with-defaults cannot
  both be satisfied. Note also that **Biome does not format markdown**, so a Biome repo
  can only ever collide on `opencode.jsonc`.
  **`.claude/settings.json` is not in that surface**, and the earlier note here that it
  was is wrong: it is seeded and required, never drift-compared (it is absent from
  `CANONICAL` in `icm-check.sh`, because every repo edits its own hook wiring). A
  formatter may reformat it freely — which is what `cafe-jardim` did, rather than carry
  a second exemption.
- **Drift is a report line, not a repair — with one narrow, explicit exception.**
  `icm-check.sh` compares each repo's copy of a canonical asset against this folder and
  warns on divergence. Deliberate divergence is fine — the repo wins — but it should be
  visible, not silent. The exception is the pipeline profile's **template-owned** files
  (the `T` lines of `icm-pipeline/MANIFEST`): those are the estate's contracts, identical
  by design, and `_system/scripts/icm-sync.sh --apply <repo>` overwrites a repo's copy
  from here — invoked by a human, dry-run by default, moving nothing outside the
  manifest, deleting nothing (a retired file is reported for `git rm`). Canonical
  `.claude/` assets and every `P` file keep the old rule: reported, never repaired
  (decision D20). **`--apply` also refuses to stamp a template commit `origin/main` never
  held** — icm-board's own checkout must have its `HEAD` on `origin/main`, or the sync is
  reporting a template state that could still change before it merges, and a repo's
  `setup.sh` "current?" answer or a `git log main` lookup of the stamp would fail. The
  lab/testing override is `--apply --from-branch <repo>` (no value — the branch already
  checked out is what gets used), which writes `branch: <name>` beside the commit in
  `.icm/template-version` so the stamp says what it is. A dry run only warns.
- **No substitutions.** Nothing in the template is templated per repo: identity is the
  `epic/slug` path (no prefixes), and the pipeline scripts derive the GitHub repo from
  `origin` (override with `GITHUB_REPO`). A copy is exact, which is what makes the drift
  report — and the sync — honest. Generalising the pipeline out of sustentus
  therefore meant *removing* its identity — the owner/repo literal, the people, the
  check names, the deploy targets, its docs-app archive paths, its channels — never
  turning them into placeholders. What a template-owned file needs to know about one
  repo it reads at runtime from that repo's project-owned `.icm/project.json` and
  `_shared/project-rules.md`.
- Baseline and canonical-asset edits here propagate only to repos fixed *after* the
  edit; the fix never retro-syncs existing files. Pipeline template-owned edits
  propagate by a human running `icm-sync.sh` per repo — the drift report says which
  repos are behind.
- **The change is made here, wherever it was asked for** (decision D33). A session in a
  repo that is asked to change a template-owned file — or a canonical `.claude/` asset —
  makes no edit: it writes a **template change request** in the shape
  `icm-pipeline/_shared/template-change.md` gives (the file by template path, today's
  lines, the change, the evidence, the repo), parks it as a `found-by: template-change`
  triage stub in that repo, and carries on under the file as it is. The prompt lands in an
  icm-board session, the change ships on a `claude/` PR here, `icm-sync.sh --apply` (or the
  by-hand copy, for a `.claude/` asset) brings it back, and the stub retires in that commit.
  The operator's spoken "patch it here now" is the only override, and the request is
  written even then.
