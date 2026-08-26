# ICM-009 · Fill the knowledge layer from the setup questionnaire

| | |
|---|---|
| Status | ready |
| Type | process |
| Priority | P1 |
| Size | M |
| Sources | decision D6, `.icm/project.md` · `_system/setup/questionnaire.md` |

## Problem

The sell and start workspaces cite `_system/knowledge/` (services, pricing, voice,
terms, stack) and two sell references (target-profile, outreach), but those files are
honest scaffolds — every substantive section reads `— not yet established`. Until Jamie
answers the questionnaire, quotes can't be priced from bands, proposals have no voice
register, and qualification has no target profile. This is the gate between "the process
exists" and "the process is usable".

## Acceptance

- [ ] Jamie has answered `_system/setup/questionnaire.md` (skips allowed — a skipped
      question stays an honest gap)
- [ ] Answers distributed into `_system/knowledge/*.md`,
      `workspaces/sell/references/target-profile.md` and `outreach.md`, replacing the
      `— not yet established` markers they cover
- [ ] The questionnaire's Done log records the date and sections filled
- [ ] Pasted real examples are lightly redacted (no client credentials or private terms
      that don't belong in this repo)

## Prompt

Sit with Jamie and fill the business knowledge layer. Read
.icm/intake/ICM-009-fill-knowledge-layer.md, then walk _system/setup/questionnaire.md
with him question by question (concrete examples, not descriptions — push for real
pasted quotes, replies and numbers). Distribute the answers into _system/knowledge/ and
the two sell references it names, replacing only the markers his answers cover, and
record the run in the questionnaire's Done log. Ticket-only/knowledge commits: follow
the repo's branch rules in _system/README.md § House doctrine.
