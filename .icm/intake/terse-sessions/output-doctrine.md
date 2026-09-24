# Stub: The output doctrine — `_shared/output.md`, one rule for what a session says

- feature-slug: output-doctrine
- epic: terse-sessions
- priority: P2
- size: S
- depends-on: none
- sequence: 1 of 3
- sources: the breakdown (Jamie's seven answers, 2026-09-24) · `_system/template/icm-pipeline/MANIFEST`
  · `_system/template/icm-pipeline/_shared/run-pack/handoff.md` · `.icm/project.md` (D39 is the
  last decision)

## Problem

Nothing in the template says how much a session says, or in what shape. Each of the ten stop
steps improvises its own sign-off, and narration between tool calls is unbounded, so the lines
Jamie must act on are buried in prose the files already carry.

## Proposed change

- New `_system/template/icm-pipeline/_shared/output.md`, template-owned (`T _shared/output.md`
  in MANIFEST). Short — under ~60 lines. It states:
  - **Audience.** The chat is read by the operator only; agents and cloud sessions read files.
    Anything a later session needs goes in a file (`handoff.md`, `status.md`, `notes.md`, the PR
    body), never only in chat.
  - **While working:** one line per phase change; no narration of tool calls, no restating a
    file, a diff or a command's output.
  - **At a stop:** the one shape — outcome line (`<stage/lane> <outcome> · CI <verdict> · <PR>`),
    `Operator:` as `- [ ]` items, `Unverified:` only when non-empty. No recap of what changed.
  - **Split by actor:** `handoff.md` = next session's steps; `Operator:` = human-only acts that
    never land in git (gate tick, merge, dashboard/env change, secret rotation, DNS). No fact in
    both, except an operator act that blocks the run, which is also a `handoff.md` → Blockers
    line `blocked on operator: <act>`.
  - **Never trimmed:** a STOP and its reason, a red check, anything skipped or unverified, a
    plaintext credential found. Brevity never outranks "report outcomes faithfully".
  - Plain words over estate shorthand in the `Operator:` items — the act must be doable from
    the line alone (where to click, what to set), no decision number without its meaning.
- Decision **D40** in `.icm/project.md` (register row + session log row): the doctrine, the
  split by actor, why no output style and no hook (harness-neutral; no mechanical gate on
  prose), and what it does not cover (icm-board's own commands, the global CLAUDE.md).
- No contract or skill changes here — stub 2 wires them.

## Acceptance criteria (rough)

- [ ] `_shared/output.md` exists, is listed `T` in MANIFEST, and `self-check.sh` passes on CI
- [ ] It contains the stop-report shape verbatim and the never-trimmed list
- [ ] D40 is in the register with its source and what it rejected

## Prompt

In icm-board (`~/Apps`), carry out stub 1 of the `terse-sessions` epic: read
`.icm/intake/terse-sessions/breakdown.md` and this stub (`output-doctrine.md`) for the full
brief. Write the template-owned doctrine file
`_system/template/icm-pipeline/_shared/output.md` — how much a session says, the one
stop-report shape (outcome line, `Operator:` checklist of human-only acts, `Unverified:` when
non-empty), the split between `handoff.md` and the chat checklist, and what is never trimmed —
add it to the MANIFEST as `T`, and record decision D40 in `.icm/project.md`. Do not edit any
stage or lane contract or skill (stub 2), and do not touch any client repo. One PR on a
`claude/` branch; CI is the verdict.
