# Stub: icm-board reads main again — the board, hygiene, the hook, the two canonical skills, the day and project contracts

- feature-slug: board-reads-main
- epic: one-branch-two-targets
- priority: P1
- size: S
- depends-on: none
- sequence: 2 of 5
- sources: D39 §1, §8 · the dependency map (D39 log row): `_system/scripts/lib/ticket-base.sh:20-56`,
  `tickets-board.sh:13-16,93`, `ticket-hygiene.sh:26-28,78-85,205`, `.claude/hooks/wrap-reminder.sh:38-60`,
  `.claude/skills/pr-conventions`, `.claude/skills/ticket-craft`, `workspaces/deliver/stages/day/CONTEXT.md:23-36,96-110,124`,
  `workspaces/deliver/stages/project/CONTEXT.md:144-145`, `_system/contracts/TICKETS.md:189-192,233-242`

## Problem

D38 taught icm-board's board and hygiene to read each client repo at `origin/<uat.branch>`, the
Stop hook to compare against it, and the two canonical skills to demand a ticket PR merged with
`--admin`. Under D39 the ticket base is `main` everywhere and ticket commits are direct again.

## Proposed change

- `_system/scripts/lib/ticket-base.sh`: the base is always `origin/main`; **keep** the
  `git archive` materialisation into a scratch dir (the shared `projects/` tree races are real and
  unrelated to UAT); drop the `project.json` lookup. `tickets-board.sh`, `ticket-hygiene.sh`:
  comments only.
- `.claude/hooks/wrap-reminder.sh` and its template twin
  `_system/template/claude/hooks/wrap-reminder.sh`: compare with `origin/main` only; the message
  says the board reads `main`. Byte-identical, both.
- `.claude/skills/pr-conventions/SKILL.md` and `_system/template/claude/skills/pr-conventions/`:
  "Ticket state goes straight to `main` in every repo — `Plan:`/`Wrap:`/`Scope:` commits, stage
  paths explicitly"; the ticket PR section, `--admin` and `type:tickets` go; "the one PR an agent
  merges" → no PR an agent merges. Same for `ticket-craft` (the standing rule about the ticket
  base branch). Byte-identical, both copies (`self-check.sh` / `icm-check.sh` compare them).
- `workspaces/deliver/stages/day/CONTEXT.md`, `project/CONTEXT.md`, `.claude/commands/day.md`:
  "ticket base branch" → `main`; step 1 still runs `pull-all.sh` and verifies at `origin/main`;
  steps 2/4/5 commit a client repo's tickets straight to `main` (a worktree off `origin/main`,
  push, no PR).
- `_system/contracts/TICKETS.md`: the D38 clauses → D39 §8, one sentence, pointing at the
  register. `AGENTS.md`, `CONTEXT.md`, `_system/README.md` were reworded with the decision;
  check nothing else in Layer 0 still says "ticket PR".
- Run the board read-only against the estate before and after: open/done counts unchanged
  except for stubs that live only on a still-existing `uat` (report them; stub 3 removes the
  branches).

## Acceptance criteria (rough)

- [ ] `grep -rn 'ticket base\|type:tickets\|--admin' .claude/ workspaces/ _system/scripts/ _system/contracts/TICKETS.md _system/template/claude/` returns only history (`_done/`, `.icm/docs/`)
- [ ] `diff -q` clean between each canonical asset and its template twin
- [ ] `tickets-board.sh --today` runs on the estate; counts explained
- [ ] `/day wrap` in a client repo ends in a direct commit to `main`

## Prompt

In icm-board (`~/Apps`, local machine — `projects/` is invisible to cloud sessions), carry out
stub 2 of the `one-branch-two-targets` epic: read the breakdown, this stub and decision D39 in
`.icm/project.md`. Make icm-board's board, hygiene, Stop hook, the two canonical skills (both
copies, byte-identical) and the `/day` and `/project` contracts read and write client tickets on
`main` by direct commit, retiring D38's ticket PR. Do not touch the pipeline template's scripts
(stub 1) or any client repo. One PR on a `claude/` branch; CI is the verdict.
