# deliver/conformance — check, populate, review, adopt

Entered by `/icm-check` (the estate walk, §1–4) or `/icm-check adopt <repo>` (one repo
brought onto the pipeline, § Adopt). Work from the Apps root. Every repo is in the walk,
sustentus included (D44); what reaches sustentus goes through a PR there. The walk never
commits or pushes — it leaves created files uncommitted for Jamie to review per repo;
adoption commits only on his word (§ Adopt, step 5).

## Inputs

| Layer | File | Why |
|---|---|---|
| 3 | [`_system/template/`](../../../../_system/template/) | The canonical baseline + asset library being checked against |
| 3 | [`TICKETS.md`](../../../../_system/contracts/TICKETS.md) · [`PIPELINE.md`](../../../../_system/contracts/PIPELINE.md) | The intake shape and the pipeline the fix seeds |
| 4 | `_system/scripts/icm-check.sh` output | The report this ritual acts on |
| 4 | Each repo's Layer 0 (`AGENTS.md` or `CLAUDE.md`) + `.claude/` | What the per-repo review reads |

## Process

**1. Check.** Run `_system/scripts/icm-check.sh` (no flags) and show the report —
including its **drift** lines, where a repo's copy of a canonical asset has diverged
from [`_system/template/claude/`](../../../../_system/template/README.md), its
**baseline drift** lines, where a repo's `.icm/CONTEXT.md` or `.icm/intake/README.md` has
diverged from `_system/template/icm/` (D45), and its
**pipeline drift** lines, where a repo's template-owned file has diverged from
[`_system/template/icm-pipeline/`](../../../../_system/template/icm-pipeline/MANIFEST).
Then, **for every repo that carries `.icm/scripts/setup.sh`**, run
`projects/<repo>/.icm/scripts/setup.sh --report` from that repo and show its last line and
`[FAIL]` rows — one implementation, two callers (D23): the repo's own report is the
authority on whether it is complete, current and configured; this ritual does not
re-derive those checks. A repo without the script yet is measured by `icm-check.sh` alone.

**2. Populate.** If the check found gaps, run `icm-check.sh --fix` and report what was
created.
- The script only creates missing files from the template; it never overwrites. Trust
  it — do not hand-create `.icm` or `.claude` files alongside it.
- Every **adopted** repo (it carries `.icm/MANIFEST`) is checked (and, with `--fix`,
  seeded) against the one pipeline — there is nothing to declare (D22); report pipeline
  gaps in their own group. A repo never synced is labelled `no pipeline` and nothing of the
  pipeline is flagged for it — not the security gate, not the health probe: it is not being
  worked on. Adopting it is § Adopt (`/icm-check adopt <repo>`), on Jamie's word. The project-owned files
  are then filled by `/setup` in the repo, never here; an empty `health_endpoint` is fine.
- Legacy flat `PREFIX-NNN` tickets are reported as *unmigrated*, never converted —
  migration is the repo's own `/setup` (its reconcile step re-cuts them).
- Drift is **reported, never repaired** — repos own their copies. Where a drifted copy
  looks deliberate, propose registering the divergence in the repo's own docs; where it
  looks like rot, propose updating from canonical — Jamie decides per repo.
- **Pipeline drift has a repair, and it is Jamie's call per repo**: template-owned files
  (the `T` lines of the manifest) are meant to be identical everywhere, so a diverged
  copy is either the template behind the repo (fold the repo's change into the template
  first) or the repo behind the template. Show the diff with
  `_system/scripts/icm-sync.sh --dry-run <repo>`; only on Jamie's word run `--apply`,
  then the repo's own PR carries the change. Project-owned files are never synced (D20).
  A **template change request** a repo's session handed back (D33 — a
  `found-by: template-change` stub in that repo's `triage/`, its `## Prompt` the request) is
  the same move from the other end: change the template first, ship it on a `claude/` PR
  here, then sync; the repo's stub retires in its sync commit with a `- superseded-by:` line.

**3. Review each repo's `.claude` and Layer 0.** For every non-exempt repo listed,
assess how well its Claude setup serves *that* project — the estate deliberately does
not enforce cross-project consistency beyond the baseline:
- Layer 0 — exists in *either* shape? A repo satisfies the check with a legacy full
  `CLAUDE.md` or with `AGENTS.md` plus the one-line `@AGENTS.md` importer; both are
  legal until the rollout completes, and only a repo with neither warns. Thin, routing
  rather than teaching (~30–90 lines, identity + routing)? Points at `.icm/intake/` for
  planning? A migrated repo also carries the canonical `opencode.json`, which `--fix`
  seeds beside the importer — never propose migrating a repo's Layer 0 as part of this
  ritual; that is `estate-rollout`'s per-repo PR work.
- `.claude/settings.json` — clean policy only? Anything that belongs in
  `settings.local.json` (the accretion layer)? Over-broad allows?
- Skills/hooks/agents — do the ones present still match the repo (dead references,
  drifted copies)? Would the repo genuinely benefit from a canonical asset it lacks —
  or from wiring a seeded hook its settings never registered?
- Warnings from step 1 (loose TODO/BACKLOG files, gitignore problems) — fold them in.

Offload the per-repo reading to Explore subagents (batch several repos per agent); keep
the main context for synthesis. Do not read `node_modules` or app source — this is a
config review, not a code audit.

**4. Report.** One section per repo needing attention: what was populated, what to
improve, each suggestion one line with the file it touches. Repos that are fine get one
"ok" line. **Suggest only — change nothing beyond what `--fix` created** unless Jamie
asks.

## Adopt — `/icm-check adopt <repo>`

Brings one repo onto the pipeline (D22 — adopted means it carries `.icm/MANIFEST`). This is
the one step a repo cannot do for itself: it needs this repo's template. Everything after
it — the register, posture, interrogation, lenses, reconcile and the cut — is the repo's
own `/setup`, run in the repo (D45). Nothing here asks an intent or config question, and
nothing here writes `project.md` or a project-owned value.

**1. Guards — never error, always land somewhere.**

| Found | Do |
|---|---|
| Repo not on disk | Clone it (`gh repo clone k0d0minio/<name> projects/<name>`) |
| Repo not on GitHub | **Stop.** The dashboard creates client repos (`createClientRepo`); say so and end |
| Already carries `.icm/MANIFEST` | Not an adoption: say so, and point at `/setup` in the repo (or § Populate's sync for drift) |
| Uncommitted changes in the checkout | Work in a worktree off `origin/main` instead; never move the shared checkout, never `git add -A` |

**2. Formatter guard, by hand, first.** If the repo has a formatter (Prettier, Biome,
lint-staged…), exclude the template-owned paths — `.icm/` T files, `.claude/skills/**`, the
canonical agents — before any template file is committed, or the next commit rewrites
them into drift (D17/D19; remi-ai #105, sustentus#1238).

**3. Seed and sync.** `_system/scripts/icm-check.sh --fix --repo projects/<repo>` (the
baseline), then `_system/scripts/icm-sync.sh --apply projects/<repo>` (the template-owned
pipeline files, `.icm/MANIFEST`, `.icm/template-version`), then `icm-check.sh --fix --repo`
once more — now that the repo is adopted, it seeds the project-owned stubs, the pipeline's
`.claude/` skills (`setup`, `pipeline`) and its `.github/` files. Report each script's `RESULT:` line.

**4. Verify.** `icm-check.sh --repo projects/<repo>` shows no gap and no pipeline drift;
`.icm/scripts/setup.sh --report` runs (its `GAPS` are expected — they are `/setup`'s
work). A legacy `PREFIX-NNN` board is reported, never converted.

**5. Land it — on Jamie's word.** One commit straight to the repo's `main` (an estate
fan-out: paths staged explicitly — `.icm/`, `.claude/`, `.github/`, the formatter ignore
file), in the
repo's own message style; sustentus by PR. Until it is pushed, a cloud session cannot see
it.

**6. Hand over.** Say: *run `/setup` in `<repo>`* — locally or in a cloud session. Its
first run establishes the register (reading `.icm/docs/` first: adopt, never fabricate),
then config, then the first cut.

## Gate — Jamie

- Reviews and commits (or discards) what `--fix` seeded, per repo.
- Rules on each drift line: deliberate divergence or rot.
- Runs `/setup` in a repo whose report names gaps, and merges its PR; decides when an
  unmigrated repo gets its `/setup` re-cut.
- Names the repo for `/icm-check adopt`, and says when its seed is pushed (§ Adopt, 5).

## Outputs

| Artifact | Lands in |
|---|---|
| Seeded baseline files (uncommitted) | each gapped repo |
| An adopted repo's seed (one commit to `main`, on Jamie's word) | the adopted repo |
| The conformance + review report | the session |

## Audit

- Every repo in the report is accounted for: ok, gapped, seeded, no pipeline, or exempt.
- An adoption ends with `icm-check.sh --repo` clean of gaps and pipeline drift, and the
  hand-over to `/setup` named — never with a register or a ticket written from here.
- Nothing beyond `--fix`'s own writes touched any repo.
- Every drift line ends the session as either a Jamie decision or a named open question
  — not silently dropped.
