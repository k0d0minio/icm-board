# deliver/conformance — check, populate, review

Entered by `/icm-check`. Work from the Apps root. Sustentus is exempt from the walk (its
`.icm/` is authoritative; `icm-check.sh --repo` measures it only when asked) — its
template-owned files are still synced on Jamie's word, like any repo's (step 2). Never
commit or push anything — leave created files uncommitted for Jamie to review per repo.

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
from [`_system/template/claude/`](../../../../_system/template/README.md), and its
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
- Every repo is checked (and, with `--fix`, seeded) against the one pipeline — there is
  nothing to declare (D22); report pipeline gaps in their own group. The project-owned
  files are then filled by `/setup` in the repo, never here.
- Legacy flat `PREFIX-NNN` tickets are reported as *unmigrated*, never converted —
  migration is `/project`'s judgment work.
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

## Gate — Jamie

- Reviews and commits (or discards) what `--fix` seeded, per repo.
- Rules on each drift line: deliberate divergence or rot.
- Runs `/setup` in a repo whose report names gaps, and merges its PR; decides when an
  unmigrated repo gets its `/project` re-cut.

## Outputs

| Artifact | Lands in |
|---|---|
| Seeded baseline files (uncommitted) | each gapped repo |
| The conformance + review report | the session |

## Audit

- Every repo in the report is accounted for: ok, gapped, seeded, or exempt.
- Nothing beyond `--fix`'s own writes touched any repo.
- Every drift line ends the session as either a Jamie decision or a named open question
  — not silently dropped.
