# Agent Directive: Continuous Learning Engine & Retrospective Collector

*Jamie's directive, received 2026-09-23 as pasted text. Only §1 arrived — the paste ends inside
its example block, so any later section was never seen by the session that adopted it. Adopted as
decision D27 (`.icm/project.md`); the narrowings are recorded there and in
`2026-09-23-retrospective-verification.md`. Saved verbatim.*

## Objective
Implement a retrospective mechanism that converts fixed build errors and edge-case solutions into persistent project rules, making the agent progressively smarter across iterations.

---

## 1. Retrospective Script (`.icm/scripts/retrospective.sh`)
Create `.icm/scripts/retrospective.sh` to run during run close-out:
- **Inputs**: Read `.icm/runs/<slug>/03_build/output/error.log` and the final `git diff` for the run.
- **Pattern Extraction**: Identify recurring lint, syntax, or framework errors encountered during iteration and how they were resolved.
- **Rule Append**: If a novel, project-specific constraint or bug pattern is identified, append a concise (1-2 line) rule to `.icm/_shared/project-rules.md`:
  ```markdown
  <!-- Retrospective Learned Rule [2026-09-22] -->
  - Always handle nullable user fields in API route handlers in this project.
  ```
