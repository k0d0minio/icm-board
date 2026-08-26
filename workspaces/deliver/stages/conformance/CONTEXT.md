# deliver/conformance — check, populate, review

Entered by `/icm-check`. Work from the Apps root. Sustentus-v2 is exempt throughout
(its `pipeline/` is authoritative). Never commit or push anything — leave created files
uncommitted for Jamie to review per repo.

## Inputs

| Layer | File | Why |
|---|---|---|
| 3 | [`_system/template/`](../../../../_system/template/) | The canonical baseline + asset library being checked against |
| 3 | [`TICKETS.md`](../../../../_system/contracts/TICKETS.md) | Prefix rules for anything the fix seeds |
| 4 | `_system/scripts/icm-check.sh` output | The report this ritual acts on |
| 4 | Each repo's `CLAUDE.md` + `.claude/` | What the per-repo review reads |

## Process

**1. Check.** Run `_system/scripts/icm-check.sh` (no flags) and show the report —
including its **drift** lines, where a repo's copy of a canonical asset has diverged
from [`_system/template/claude/`](../../../../_system/template/README.md).

**2. Populate.** If the check found gaps, run `icm-check.sh --fix` and report what was
created.
- The script only creates missing files from the template; it never overwrites. Trust
  it — do not hand-create `.icm` or `.claude` files alongside it.
- Any prefix flagged *suggested* (auto-derived): list prominently. Prefixes must be
  short, unique across the estate, never reused — if a suggestion collides or reads
  badly, tell Jamie which README to edit before the first ticket is cut. Do not invent
  tickets.
- Drift is **reported, never repaired** — repos own their copies. Where a drifted copy
  looks deliberate, propose registering the divergence in the repo's own docs; where it
  looks like rot, propose updating from canonical — Jamie decides per repo.

**3. Review each repo's `.claude` and Layer 0.** For every non-exempt repo listed,
assess how well its Claude setup serves *that* project — the estate deliberately does
not enforce cross-project consistency beyond the baseline:
- `CLAUDE.md` — exists? Thin Layer-0 that routes rather than teaches (~30–90 lines,
  identity + routing)? Points at `.icm/intake/` for planning?
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
- Confirms suggested prefixes before first tickets.

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
