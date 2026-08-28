# Stub: Distill the real discovery artifacts into the sell references

- feature-slug: distill-discovery-artifacts
- epic: discovery-references
- priority: P2
- size: M
- depends-on: none
- sequence: 1 of 1
- sources: recut from ICM-006 (original purged, D14) · berceo .icm/docs/{QUESTIONS,REPORT}.md · messy-play DISCOVERY-PROMPT.md

## Problem

Discovery is the estate's strongest pre-sale work and its skeletons
(`workspaces/sell/references/discovery-interview.md`, `discovery-questions.md`) are
generic by construction. The lived question sets — berceo's stable IDs and
`[BLOCKER]`/`[LAWYER]` tags, "the short list if we only get one meeting";
messy-play's interview-as-prompt — should be folded in, de-clientified.

## Proposed change

Distill the berceo and messy-play artifacts into the two sell references, keeping their
stable-ID and tag conventions and removing all client specifics (this repo travels to
the cloud). Any report shape worth keeping lands in
`workspaces/sell/stages/02_discovery/CONTEXT.md`'s discovery-notes format, within its
line cap.

## Acceptance criteria (rough)

- [ ] Every question in the source artifacts exists (or is deliberately declined, noted
      in the PR) in discovery-questions.md, with its ID and tags
- [ ] The interview script reflects what those engagements actually asked, generic
- [ ] No client specifics anywhere in the references

## Out of scope (this feature)

- Touching the client repos themselves — read-only sources.

## Prompt

Fold the estate's real discovery artifacts into the sell workspace's references. Read
.icm/intake/discovery-references/distill-discovery-artifacts.md, then distill
projects/berceo/.icm/docs/QUESTIONS.md and REPORT.md, and
projects/messy-play/DISCOVERY-PROMPT.md (client repos beside this one, only on Jamie's
machine) into workspaces/sell/references/discovery-questions.md and
discovery-interview.md, keeping their stable-ID + [BLOCKER]/[LAWYER] conventions and
removing all client specifics. Open a PR on a claude/ branch; do not run local checks —
CI is the source of truth.
