# Breakdown: OpenCode sidecar — set icm-board up for a second harness

- epic-slug: opencode-sidecar
- sources: provider-agnostic research session 2026-08-29 (harness pick: OpenCode; model
  and jurisdiction findings in the session's report) · Jamie's words: cut the repo-side
  setup only — he installs and configures OpenCode himself

## What I understood

Jamie wants light, well-scoped stubs runnable on cheaper non-Anthropic models through
OpenCode, with icm-board as the pilot repo. ICM is already provider-agnostic where it
counts — contracts, stubs and gates are plain markdown — so the repo-side work is thin:
move Layer 0 to the vendor-neutral AGENTS.md filename (Claude Code keeps reading it via
a one-line `@AGENTS.md` import in CLAUDE.md), commit an inert `opencode.json` that
carries the repo's rails (no local checks — CI is truth) for any OpenCode session, and
make the tickets contract's `## Prompt` wording agent-neutral so pick-up prompts stop
naming Claude specifically. Installing OpenCode, choosing providers/models, and any
estate-wide rollout are all deliberately not in this epic.

## Build order

1. agents-md-layer0 — Layer 0 moves to AGENTS.md; CLAUDE.md becomes the importer — depends-on: none
2. opencode-config — commit repo-side opencode.json with the estate rails — depends-on: none
3. agent-neutral-prompts — generalize "fresh Claude session" in the tickets contract + copies — depends-on: none

## Out of scope (whole epic)

- Installing, authenticating or model-configuring OpenCode — Jamie's, by his own word.
- Estate-wide rollout: template AGENTS.md, conformance checks for it, other repos — a
  later epic once this pilot holds.
- Any dispatch/orchestration tooling — D3 stands; dispatch stays "copy the prompt".
- `- tier: light` delegation markers on stubs — recut from evidence if the pilot shows
  the need.
