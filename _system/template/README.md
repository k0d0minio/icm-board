# template — canonical scaffold + asset library for the estate

Consumed by `_system/scripts/icm-check.sh`:

1. **The baseline** `--fix` seeds when a repo is missing it (never overwrites).
2. **The canonical Claude-asset library** — the estate-wide hooks and skills every repo
   should carry. Seeded when missing; **drift is reported, never repaired** — repos own
   their copies (decision D7, [`.icm/project.md`](../../.icm/project.md)).
3. **The pipeline profile** — seeded *only* into repos whose `.icm/CONTEXT.md` declares
   `- profile: pipeline` ([contracts/PIPELINE.md](../contracts/PIPELINE.md)). Declaring
   the profile is Jamie's act; the fix never upgrades one.
4. **The new-shape root assets** — seeded *only* into repos that already carry an
   `AGENTS.md` (epic `opencode-sidecar`). Migrating a repo's Layer 0 is Jamie's act; the
   fix never performs the move.

Sustentus is exempt from the estate walk (its `.icm/` is authoritative — it is the source
this template was extracted from, decision D12); `icm-check.sh --repo` measures it
voluntarily. The pipeline profile tracks that source: it was re-founded on sustentus's
current four-stage shape (Scope → Define → Build → Release, no substage) on 2026-09-18,
generalised rather than parameterised, and split at file level into **template-owned**
and **project-owned** files (decision D20, `icm-pipeline/MANIFEST`). Template-owned files
are byte-identical in every pipeline repo — sustentus included — and `icm-sync.sh` is how
they get there; project-owned files are seeded once and never touched again.

```
root/                            → copied to <repo>/                (migrated repos only)
  CLAUDE.md                      ← the one-line `@AGENTS.md` importer
  opencode.jsonc                 ← the estate's OpenCode rails (deny local checks, ask on push)
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
    vercel-env-hydrate.sh        ← cloud sessions pull their .env.local from Vercel
                                   (kodominio repos only — see below)
  skills/
    ticket-craft/SKILL.md        ← the intake contract as working knowledge
    pr-conventions/SKILL.md     ← branches, commits, CI-is-truth, no secrets
icm-pipeline/                    → copied to <repo>/.icm/           (pipeline profile only)
  MANIFEST                       ← the ownership list: T template-owned · P project-owned.
                                    Read by icm-check.sh AND icm-sync.sh; never copied
  stages/01_scope/               ← the front: source verbatim → settled live in session →
                                    scope.md (D-n decisions) → the intake cut. No substage
  stages/{02_define,03_build,04_release}/   lanes/{bug,tweak,chore,knowledge}/     (T)
  intake/CONTEXT.md              ← breakdown/stub formats, triage, archive rules       (T)
  _shared/{github,ci,stage-preamble,scope-template,conventions}.md                    (T)
  _shared/{project-rules,knowledge-map}.md   ← this repo's rules and doc pages         (P)
  project.json                   ← the project manifest (name, docs_path, archives,
                                    required checks/env, smoke check) — --fix fills name (P)
  runs/README.md                 ← the repo's own note on its runs                     (P)
  scripts/lib/{gh,changed-files,project}.sh                                           (T)
  scripts/{resolve-run,validate-spec,validate-intake,validate-decisions,new-run,
           project-body,project-labels,ci-status,close-out,triage-report,env-check}.sh (T)
  scripts/{format,lint,validate-knowledge-map,notify}.sh   ← the repo's own hooks      (P)
claude-pipeline/                 → copied to <repo>/.claude/        (pipeline profile only)
  skills/pipeline/SKILL.md       ← the /pipeline router (seeded; drift-reported)
github-pipeline/                 → copied to <repo>/.github/        (pipeline profile only)
  pull_request_template.md       ← carries both gate anchors
```

Layer 0 itself — `AGENTS.md`, or a legacy full `CLAUDE.md` — is **never templated**.
Each repo writes its own identity and routing; an empty one would read as established
intent. Only the importer is canonical, because it is identical everywhere.

`vercel-env-hydrate.sh` is the one asset with a **team boundary**: it hydrates a cloud
session's environment from the Vercel team a repo deploys under, and sustentus and remi21
are separated boundaries (epic `vercel-env-system`), so `icm-check` seeds it into the
kodominio estate and offers it to those two rather than pushing it. It is also the one
hook `settings.json` does not register — `session-start.sh` invokes it when it is there,
which is why the estate's hand-owned settings files need no edit to gain it.

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
  (decision D20).
- **No substitutions.** Nothing in the template is templated per repo: identity is the
  `epic/slug` path (no prefixes), and the pipeline scripts derive the GitHub repo from
  `origin` (override with `GITHUB_REPO`). A copy is exact, which is what makes the drift
  report — and the sync — honest. Generalising the pipeline profile out of sustentus
  therefore meant *removing* its identity — the owner/repo literal, the people, the
  check names, the deploy targets, its docs-app archive paths, its channels — never
  turning them into placeholders. What a template-owned file needs to know about one
  repo it reads at runtime from that repo's project-owned `.icm/project.json` and
  `_shared/project-rules.md`.
- Baseline and canonical-asset edits here propagate only to repos fixed *after* the
  edit; the fix never retro-syncs existing files. Pipeline template-owned edits
  propagate by a human running `icm-sync.sh` per repo — the drift report says which
  repos are behind.
