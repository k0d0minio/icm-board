# Stub: Trial Understand-Anything on the next adoption against the project-lens tech lens

- lane: chore
- found-by: notes/understand-anything.md (tool research, verdict Trial) · 2026-10-01
- priority: P2
- complexity: research
- sources: `notes/understand-anything.md` (untracked, Jamie's `~/Apps` checkout) ·
  github.com/Egonex-AI/Understand-Anything (MIT; installed here as `understand-anything@understand-anything`) ·
  `_system/template/claude/agents/project-lens.md` + `_system/template/root/.opencode/agents/project-lens.md` ·
  `_system/template/icm-pipeline/_shared/lenses.md` § 7 tech ·
  `_system/template/icm-pipeline/_shared/knowledge-map.md` · D48 (`/icm-check adopt` → `/setup`)
- touches: nothing until the trial reports. If adopted: `project-lens.md` (both harness
  copies), `lenses.md` § tech, `knowledge-map.md`, the handover lane, and the template's
  `.gitignore` for `.ua/`.

## Problem

`/setup`'s tech lens reads a repo cold through `project-lens`. That is weakest on repos the
estate inherited rather than wrote in-session, such as sustentus, serviflow and remi-ai.
Understand-Anything is already installed as a plugin, and it covers that ground:

- `/understand` writes a source-backed knowledge graph to `.ua/knowledge-graph.json`, built
  with Tree-sitter for structure and an LLM for summaries and layers.
- `/understand-domain` maps the code to business domains and flows, which is the register's
  *Business logic* section.
- `/understand-onboard` writes an onboarding guide.
- A read-only viewer opens the graph with no LLM.

Nobody has measured whether it beats the lens. The first run is token-heavy, the fidelity
direction asks for evidence before any new standing cost, and a 10 MB+ JSON per repo is a
question of its own.

## Proposed change

Trial it once, on the next `/icm-check adopt <repo>`, before that repo's `/setup`:

1. Run `/understand`, then `/understand-domain` and `/understand-onboard`. Record the tokens
   spent, the wall-clock time and the size of `.ua/`. Keep `.ua/` out of git during the trial.
2. Run `/setup`'s tech lens (`project-lens`, lens `tech`) on the same commit as usual.
3. Compare the two in a short report under `.icm/docs/`:
   - what each found that the other missed
   - which is source-cited and which is guesswork
   - whether the domain map would have filled the register's *Business logic* better than
     `/setup` did
4. Recommend one of these:
   - (a) the tech lens cites `.ua/` when it exists, as a D33 template change (PR here, then
     `icm-sync.sh`)
   - (b) the graph becomes a handover artefact only, committed in the handover lane with
     `.ua/` gitignored otherwise
   - (c) drop it and uninstall the plugin

Guardrails:

- It runs only when Jamie invokes it, once per adoption, never per run. It advances nothing
  across a gate, so the never-build-an-orchestrator rule holds.
- The viewer is a local tool, not the target app's dev server. If `block-local-checks` trips
  on it, record that rather than routing around it.

## Acceptance

- [ ] One adoption has both outputs on the same commit, with tokens, time and size recorded
- [ ] The comparison report exists, and its recommendation is a, b or c
- [ ] No template, lens or `.gitignore` change in this stub. The chosen option is cut as its
      own stub.
