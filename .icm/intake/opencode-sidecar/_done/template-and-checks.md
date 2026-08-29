# Stub: Template canonizes the AGENTS.md shape; conformance tolerates both

- feature-slug: template-and-checks
- epic: opencode-sidecar
- priority: P1
- size: M
- depends-on: agents-md-layer0
- sequence: 4 of 6
- sources: Jamie's widening, 2026-08-29 · `_system/scripts/icm-check.sh:160` and
  `estate-conformance.sh:149` (the "no CLAUDE.md" warn) · icm-check.sh:17 ("CLAUDE.md
  reported only — never templated")

## Problem

The template and the conformance scripts still describe the old shape: identity lives
in CLAUDE.md, reported-only, never templated. After the icm-board pilot the estate's
shape becomes AGENTS.md (per-repo, never templated) plus a one-line CLAUDE.md importer
— which, being identical everywhere, *can* now be a canonical templated asset, as can
the repo-side opencode.json proven in stub 2. If the scripts flip to demanding the new
shape before the rollout lands, every un-migrated repo goes warning-red at once —
nothing may break mid-transition.

## Proposed change

In `_system/template/`: add the canonical one-line CLAUDE.md importer (`@AGENTS.md`)
and the canonical `opencode.json` to the baseline asset set that `--fix` seeds
(seed-only, never overwrite — a repo with a full legacy CLAUDE.md is left alone).
In `icm-check.sh` and `estate-conformance.sh`: the identity warn becomes
shape-tolerant — a repo satisfies it with *either* a full legacy CLAUDE.md *or* the
AGENTS.md + importer pair; only a repo with neither warns. AGENTS.md itself stays
reported-only, never templated (each repo writes its own, exactly as CLAUDE.md was).
Comment the check with the transition reasoning. Sustentus stays exempt throughout —
the tooling continues to leave it alone.

## Acceptance criteria (rough)

- [ ] `--fix` on an un-migrated repo seeds nothing identity-related and overwrites nothing
- [ ] `--fix` on a migrated repo missing opencode.json seeds only that
- [ ] A conformance run over the current, un-migrated estate shows no new warnings
- [ ] Sustentus untouched by both scripts, as before
- [ ] CI green

## Out of scope (this feature)

- Actually migrating any repo — that is estate-rollout's work.
- Retiring the legacy-CLAUDE.md tolerance — decide after the rollout completes, as its
  own triage stub with evidence.

## Prompt

Adapt the estate template and conformance scripts for the AGENTS.md shape without
breaking un-migrated repos. Read
.icm/intake/opencode-sidecar/template-and-checks.md for full context, and the
completed agents-md-layer0 stub for the shape being canonized. Template gains the
one-line CLAUDE.md importer and opencode.json as seed-only canonical assets; the
identity check in _system/scripts/icm-check.sh and estate-conformance.sh accepts
either the legacy or the new shape; sustentus stays exempt. Open a PR on a claude/
branch; do not run local checks — CI is the source of truth.
