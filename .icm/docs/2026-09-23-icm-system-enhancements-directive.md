# Agent Directive: Advanced ICM System Enhancements (Skills, Model Routing, DB Branching, Security & Canonical Files)

*Received 2026-09-23 (Jamie, via the session prompt). Recorded as received; the narrowings
and what shipped are in `.icm/project.md` → D27 and the verification report of the same date.*

## EXPLICIT EXECUTION BOUNDARY
- **Target Directories**: `_system/template/icm-pipeline` (in `icm-board`)
- **Goal**: Implement 5 advanced system capabilities derived from research sources while preserving the local-first, plain-text ICM ethos.
- **Explicit Exclusion**: Do NOT implement LSFS / vector embedding indexes. Keep file operations strictly local and deterministic via standard shell utilities (`find`, `rg`, `jq`).

---

## 1. Progressive Skill Disclosure Framework (`.icm/skills/`)

Implement the 3-tier progressive disclosure pattern (`SKILL.md` specification) to keep system prompts lean while exposing modular agency capabilities:

1. **Directory Structure**:
   - Create `.icm/skills/` with modular subdirectories (e.g., `.icm/skills/security-audit/`, `.icm/skills/database-migration/`, `.icm/skills/preview-deploy/`).
2. **3-Tier Skill Structure**:
   - **Level 1 (Metadata)**: Each skill folder contains a `SKILL.md` with lightweight YAML frontmatter (`name`, `description`, `triggers` ~30-50 tokens).
   - **Level 2 (Instructions)**: The body of `SKILL.md` contains step-by-step procedural rules, loaded into context ONLY when triggered.
   - **Level 3 (Execution Assets)**: Supporting scripts and reference templates live in subdirectories inside the skill folder and are invoked on demand.
3. **Skill Index Script (`.icm/scripts/list-skills.sh`)**:
   - Create a script that parses all `.icm/skills/*/SKILL.md` frontmatter and prints a compact JSON/markdown registry for system prompt injection.

---

## 2. Advisor-Executor Model Routing (`.icm/scripts/select-model.sh`)

Implement task-complexity cost routing and the Advisor-Executor pattern:

1. **3-Tier Model Allocation**:
   - **Tier 1 (Fast / Low Cost - Haiku / Luna)**: Pre-commit linting, file formatting, single-file edits, simple syntax fixes.
   - **Tier 2 (Balanced - Sonnet)**: Feature implementation, unit test generation, PR drafting, build execution.
   - **Tier 3 (Frontier Reasoning - Opus / Fable)**: Architectural design, multi-file refactoring, planning, race-condition debugging.
2. **Advisor-Executor Pattern Rules**:
   - **Planning Passes** (Stage 01 Scope & Stage 02 Define): Dispatched to Tier 3 (**Opus / Fable**) as the **Advisor**.
   - **Execution Passes** (Stage 03 Build & subagents): Dispatched to Tier 2 (**Sonnet**) as the **Executor**.
   - **Validation Passes** (Pre-commit formatting/linting): Dispatched to Tier 1 (**Haiku**).
3. **Script Update (`.icm/scripts/select-model.sh`)**:
   - Update `select-model.sh` to take `--stage` and `--complexity` arguments and output the precise model harness flags (`--model sonnet`, `--model opus`, etc.).

---

## 3. Isolated Database Branching & Out-of-Order Migrations (`.icm/scripts/db-branch.sh`)

1. **Database Branching Hook (`.icm/scripts/db-branch.sh`)**:
   - Create `.icm/scripts/db-branch.sh` to spin up or bind an isolated, local ephemeral database container (or schema namespace) for each Git worktree run (`.icm/runs/<stub-slug>/`).
2. **UTC Millisecond Migration Naming**:
   - Enforce UTC millisecond timestamps (`V20260922070000104__add_tokens.sql`) for all database migrations.
3. **Out-of-Order Migration Configuration**:
   - Configure Flyway/Prisma/Drizzle settings (`flyway.outOfOrder=true`) in `.icm/project.json` so parallel agent branches can merge in any order without checksum failures or execution locks.

---

## 4. Pre-Commit Zero-Trust Security Gate (`gitleaks`)

1. **Security Gate Script (`.icm/scripts/security-check.sh`)**:
   - Embed local `gitleaks` secret detection into `.icm/scripts/security-check.sh`:
     ```bash
     gitleaks protect --staged --verbose --redact
     ```
   - Run dependency vulnerability checks (`npm audit --audit-level=high` or equivalent).
2. **Failure Trapping**:
   - If an API key, database string, or high vulnerability is found, immediately abort the commit, write the redacted trace to `.icm/runs/<slug>/03_build/output/error.log`, and return exit `1`.

---

## 5. Canonical File Pack for Agent Session Continuity

Standardize the following inspectable plain-text state files inside every active run directory (`.icm/runs/<stub-slug>/`):

- `project.md` — Project context and constraints.
- `plan.md` — Multi-pass architectural execution layers.
- `tasks.md` — Task queue with explicit Definition of Done checkboxes (`- [ ]`).
- `decisions.md` — Recorded `D-n` decision IDs.
- `status.md` — Current execution phase and block flags.
- `handoff.md` — Explicit next steps and blockers for subsequent agent sessions.
- `FAILURE.md` — Logged error retrospectives and learned rules (synced to `.icm/_shared/project-rules.md` on close-out).

---

## Verification
1. Run `.icm/scripts/env-check.sh` to verify script permissions.
2. Run `.icm/scripts/list-skills.sh` to verify `SKILL.md` parsing.
3. Test `.icm/scripts/select-model.sh --stage 01_scope --complexity high` and verify output reads `opus`/`fable`.
