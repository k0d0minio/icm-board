# Stub: Sustentus operates in OpenCode — opencode.json only, nothing else moves

- feature-slug: sustentus-opencode
- epic: opencode-sidecar
- priority: P1
- size: S
- depends-on: opencode-config
- sequence: 6 of 6
- sources: Jamie's widening, 2026-08-29 ("nothing breaks, especially not sustentus —
  but sustentus can also operate within opencode") · OpenCode reads CLAUDE.md natively
  as its instruction-file fallback (opencode.ai/docs/rules) · verified 2026-08-29:
  sustentus has CLAUDE.md, no AGENTS.md, no opencode.json

## Problem

Sustentus is exempt from the estate baseline — its `.icm/` is authoritative and the
tooling leaves it alone — yet it should be drivable from OpenCode like the rest of the
estate. Migrating it to the AGENTS.md shape would be change for change's sake in the
one repo where breakage costs most.

## Proposed change

The minimal path, made possible by OpenCode's native CLAUDE.md fallback: leave
sustentus's CLAUDE.md and `.icm/` entirely untouched and add only a repo-side
`opencode.json`, adapted from the one proven in icm-board (stub 2) to sustentus's own
conventions — its CONVENTIONS.md and CI setup decide what the deny patterns are, not
the estate template. Once Jamie has OpenCode installed, verify in a live session at the
sustentus root that it loads CLAUDE.md and respects the permission rails. The change
goes through sustentus's own PR process.

## Acceptance criteria (rough)

- [ ] `opencode.json` in sustentus, deny rules matching its own conventions
- [ ] CLAUDE.md, `.icm/`, and every other file untouched — the diff is one added file
- [ ] Live OpenCode session at sustentus root loads CLAUDE.md as instructions (waits on
      Jamie's install)
- [ ] Sustentus CI green; board reads it exactly as before

## Out of scope (this feature)

- AGENTS.md in sustentus — deliberately never in this epic; revisit only if a harness
  that cannot read CLAUDE.md ever matters there.
- Any edit to sustentus's `.icm/` — authoritative, exempt, untouched.

## Prompt

Make sustentus operable from OpenCode with the smallest possible diff. Read
.icm/intake/opencode-sidecar/sustentus-opencode.md for full context. Add only a
repo-side opencode.json to projects/sustentus — deny patterns drawn from sustentus's
own CONVENTIONS.md and CI, modeled on icm-board's proven config — and change nothing
else: CLAUDE.md stays (OpenCode reads it natively), .icm/ is authoritative and
untouched. Open the PR through sustentus's own process; do not run local checks — CI
is the source of truth.
