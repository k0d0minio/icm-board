# Stub: route-request.sh answers a skill's own instruction body with a Route line

- lane: bug
- found-by: template-change (berceo triage/template-change-router-skill-prompts) · 2026-09-26
- priority: P2
- complexity: medium
- sources: `_system/template/claude/hooks/route-request.sh:192` (the investigation bail) · berceo release messagerie (PR 44, head ebe09eb)

## Problem

Invoking a skill (`/security-review` during berceo's Release) injected the skill's long instruction
body as a user turn, and the hook answered it with its layer-3 line —
`[pipeline-router] Route: /pipeline scope "<the story>" (multi-feature dump …)`, marked
authoritative — because the body was over 800 characters with bullet lines. The session ignored
it, but the line is a false routing verdict on every skill invocation, and the investigation bail
(`\b(analy[sz]e|…|review|…)\b`) did not match the body's "security review" wording for reasons the
stub could not confirm (the expanded body the hook receives may differ from what the session sees).

## Proposed change

Never emit a Route or Suggest line for a prompt that is a skill or slash-command body: detect the
leading `/<name>` or the expanded skill front matter (`---\nname:`), exit 0 silently, and add the
case to `route-request.test.sh`. Confirm what the hook receives for an expanded skill in both
harnesses before choosing the detector. This is a canonical `.claude/` asset: the change ships
here and is copied by hand into every repo (D7); the source stub retires with `- superseded-by:`.
