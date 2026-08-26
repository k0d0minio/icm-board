# ICM-006 · Distill the real discovery artifacts into the sell references

| | |
|---|---|
| Status | ready |
| Type | process |
| Priority | P2 |
| Size | M |

> Amended 2026-08-26: the skeletons this ticket originally asked for now exist as
> `workspaces/sell/references/discovery-interview.md` and `discovery-questions.md`
> (built with the sell workspace, decision D3 in `.icm/project.md`). What remains is the
> half a cloud session cannot do: folding in the real artifacts, which live only on
> Jamie's machine.

## Problem

Discovery is the estate's strongest pre-sale work and its skeletons are now generic by
construction. The lived question sets — berceo's assessment `REPORT.md` +
`QUESTIONS.md` (stable IDs, `[BLOCKER]`/`[LAWYER]` tags, "the short list if we only get
one meeting") and messy-play's `DISCOVERY-PROMPT.md` (interview-as-prompt → project
brief) — were each invented from scratch in one repo and never reused. Their hard-won
questions and report shape should be folded into the sell references, de-clientified.

## Acceptance

- [ ] Every question in the berceo/messy-play artifacts either exists (or is
      deliberately declined, noted in the PR) in
      `workspaces/sell/references/discovery-questions.md`, with its ID and tags
- [ ] The interview script reflects what those engagements actually asked, generic
      (no client specifics — this repo travels to the cloud)
- [ ] Any report shape worth keeping lands as a section of the discovery-notes format
      in `workspaces/sell/stages/02_discovery/CONTEXT.md` (respect its line cap)

## Prompt

Fold the estate's real discovery artifacts into the sell workspace's references. Read
.icm/intake/ICM-006-house-discovery-templates.md for full context, then distill
projects/berceo/.icm/docs/QUESTIONS.md and REPORT.md, and
projects/messy-play/DISCOVERY-PROMPT.md (client repos beside this one, only present on
Jamie's machine) into workspaces/sell/references/discovery-questions.md and
discovery-interview.md, keeping their stable-ID + [BLOCKER]/[LAWYER] conventions and
removing all client specifics. Open a PR on a claude/ branch; do not run local checks —
CI is the source of truth.
