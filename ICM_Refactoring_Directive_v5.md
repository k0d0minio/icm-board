# Agent Directive: ICM Pipeline Architecture & Refactoring Specification (v5.0 Master)

**Target Agent**: Fable 5.1 / Claude Opus  
**Context**: Interpretable Context Methodology (ICM) Estate Refactoring  
**Reference Implementation**: `sustentus`  
**Target Specification**: 100% Standalone, File-Decoupled, Local-First Pipeline Architecture  
**Session Scope Boundary**: **STRICTLY CONSTRAINED TO `icm-board` AND `sustentus` REPOSITORIES ONLY.**  

---

## 1. Executive Summary & Session Constraint

This master directive instructs you to execute Phase 1 and Phase 2 of the Interpretable Context Methodology (ICM) pipeline refactoring. Grounded in the ICM theory paper [29], the estate audit (`ICM_SDLC_Architecture_Audit.md`) [1, 2], the dry-run gap analysis (`ICM_DryRun_Gap_Analysis.md`), and the multi-stage deep dive (`ICM_Deep_Dive_Stage_Audit.md`), your objectives for **this session** are strictly bounded:

1. **Refine `sustentus`** as the estate's gold-standard reference implementation [1].
2. **Generalise `sustentus` assets** to re-found the central template inside `_system/template/icm-pipeline` (within the `icm-board` repository), stripping all repository-specific identities [130+ tokens].
3. **Deploy the corrected, idempotent sync tool** (`_system/scripts/icm-sync.sh`) in `icm-board`.
4. **Test & Verify Idempotency** by running `icm-sync.sh` against `sustentus` to guarantee zero unexpected diffs and complete file-ownership isolation.

> **CRITICAL BOUNDARY**: Do NOT touch, modify, or sync any downstream repositories (`remi-ai`, `serviflow`, or intake repositories) during this session. Downstream rollout will take place in a subsequent session once the template and sync tool are proven 100% idempotent between `_system/template/icm-pipeline` and `sustentus`.

---

## 2. Theoretical Foundations & Architectural Rules

### A. Pipe-and-Filter & Plain-Text Interfaces
- **Unix Modularity**: Each stage handles one discrete SDLC phase (`01_scope` -> `02_define` -> `03_build` -> `04_release`) plus 4 targeted lanes (`bug`, `tweak`, `chore`, `knowledge`) [7, 36, 48]. Stage handoffs occur exclusively via plain markdown and JSON files stored in designated `output/` directories (Layer 4 working artifacts) [49, 56].
- **Layered Context Scoping**: Restrict prompt context windows to 2,000–8,000 tokens per stage [58]. Never load raw source code trees or un-scoped context into early stages [12, 42].

### B. File-Level Decoupling (Idempotent Sync Rules)
Enforce strict **file-level ownership isolation** to prevent template drift while supporting local project variations:
- **Template-Owned Files (100% Immutable)**: Core stage contracts (`stages/*/CONTEXT.md`), lane definitions (`lanes/*/CONTEXT.md`), shared framework rules (`_shared/ci.md`, `_shared/github.md`, `_shared/stage-preamble.md`), standard reference templates (`_shared/scope-template.md`, `_shared/conventions.md`), and shared helper libraries (`scripts/lib/***` including `changed-files.sh` and `gh.sh`) [4, 17, 18]. Sync operations (`icm-sync.sh`) overwrite these files atomically.
- **Project-Owned Files (100% Local)**: Project rules (`_shared/project-rules.md`), project metadata manifest (`.icm/project.json`), project formatting (`scripts/format.sh`), project static analysis (`scripts/lint.sh`), doc tree validators (`scripts/validate-knowledge-map.sh`), and notification hooks (`scripts/notify.sh`) [20, 21]. These are created during project setup and are **never touched or overwritten by central sync scripts**.
- **Zero Intra-File Parsing**: Never use HTML comment markers or regex section boundaries inside markdown files to merge template changes.
- **Zero Template Placeholders in Contracts**: Stage contracts MUST remain 100% literal and identical across all repositories. Project specifics (project name, doc paths, required secrets) are read dynamically at runtime from `.icm/project.json`.

### C. Shift-Left Local-First Execution
- **Instant Pre-Commit Feedback**: Local scripts in `.icm/scripts/` (`format.sh`, `lint.sh`, `validate-decisions.sh`) execute locally on changed files (`git diff`), capturing failing stderr traces in `output/error.log` [20, 42].
- **Thin Cloud Release Gates**: GitHub Actions runners serve strictly as final deployment triggers and PR validation gates, eliminating remote build-minute waste during agentic development iterations [7, 21].

### D. Synchronous Live Interrogation Model
- Standardise 100% on **live operator interrogation** (`AskUserQuestion`) during Stage 1 (`01_scope`) [6, 13].
- **Completely delete** the legacy asynchronous question-sheet substage (`01_scope/approve/`) from templates and external routing scripts (`icm-check.sh`, `PIPELINE.md`, `SKILL.md`) [5, 13].

### E. Semantic Traceability & Decision Records
- Require `01_scope` to emit explicit **Decision Record IDs (`D-n`)** in its `## Decisions` table [15].
- Enforce deterministic verification via `validate-decisions.sh`: shell scripts scan downstream stage outputs (`02_define/output/spec.md` and `03_build/output/notes.md`) to ensure all `D-n` decisions carry forward without silent assumptions [11, 15].

### F. Gate Anchor Resets
- In Stage 2 (`02_define`), when a specification is updated, `project-body.sh --apply` MUST re-project the PR description and reset the `Spec approved` gate anchor to prevent revised specifications from inheriting stale approvals.

---

## 3. Production Environment & Manifest Specifications

### A. Project Metadata Manifest (`.icm/project.json`)
Every pipeline repository MUST maintain a project-owned `.icm/project.json` file to store local metadata without mutating template contracts:
```json
{
  "name": "sustentus",
  "profile": "pipeline",
  "docs_path": "apps/docs/app",
  "required_env": [
    "GH_TOKEN",
    "VERCEL_TOKEN"
  ]
}
```

### B. Pre-Flight Environment Script (`.icm/scripts/env-check.sh`)
Deploy the following production pre-flight script to `.icm/scripts/env-check.sh`:

```bash
#!/usr/bin/env bash
# Pre-Flight Environment & Dependency Sanity Check
set -euo pipefail

echo "=== ICM Pipeline Pre-Flight Environment Check ==="

ERRORS=0
WARNINGS=0

# 1. Check Required System CLI Binaries
echo "[1/6] Checking Critical System Tooling..."
for tool in bash git rsync rg jq; do
  if command -v "$tool" >/dev/null 2>&1; then
    echo "  [OK] Binary found: $tool"
  else
    echo "  [FAIL] Missing required binary: $tool"
    ERRORS=$((ERRORS + 1))
  fi
done

# 2. Check Deployment CLIs & Global Tokens
echo "[2/6] Checking Global Deployment CLIs & Authentication Tokens..."
if command -v gh >/dev/null 2>&1; then
  echo "  [OK] Binary found: gh (GitHub CLI)"
  if [ -n "${GH_TOKEN:-}" ] || [ -n "${GITHUB_TOKEN:-}" ]; then
    echo "  [OK] GitHub Token present in environment"
  else
    echo "  [WARN] Neither GH_TOKEN nor GITHUB_TOKEN set in shell"
    WARNINGS=$((WARNINGS + 1))
  fi
else
  echo "  [WARN] GitHub CLI (gh) not found in PATH"
  WARNINGS=$((WARNINGS + 1))
fi

# 3. Check Project-Specific Required Environment Variables
echo "[3/6] Checking Project-Specific Environment Secrets (.icm/project.json)..."
if [ -f ".icm/project.json" ]; then
  REQ_ENVS=$(jq -r '.required_env[]?' .icm/project.json 2>/dev/null || true)
  if [ -n "$REQ_ENVS" ]; then
    for var in $REQ_ENVS; do
      if [ -n "${!var:-}" ]; then
        echo "  [OK] Required environment variable set: $var"
      else
        echo "  [WARN] Missing required environment variable: $var"
        WARNINGS=$((WARNINGS + 1))
      fi
    done
  else
    echo "  [INFO] No required_env variables declared in .icm/project.json"
  fi
else
  echo "  [WARN] .icm/project.json not found"
  WARNINGS=$((WARNINGS + 1))
fi

# 4. Check Directory Structure
echo "[4/6] Checking Local ICM Directory Integrity..."
if [ -d ".icm" ]; then
  echo "  [OK] Local .icm directory present"
  for sub in stages _shared scripts; do
    if [ -d ".icm/$sub" ]; then
      echo "  [OK] Subdirectory present: .icm/$sub"
    else
      echo "  [FAIL] Missing expected subdirectory: .icm/$sub"
      ERRORS=$((ERRORS + 1))
    fi
  done
else
  echo "  [FAIL] Current directory lacks an .icm folder"
  ERRORS=$((ERRORS + 1))
fi

# 5. Check Script Execution Permissions
echo "[5/6] Checking Script Execution Permissions..."
if [ -d ".icm/scripts" ]; then
  NON_EXEC=$(find .icm/scripts -name "*.sh" ! -executable 2>/dev/null | wc -l || echo "0")
  if [ "$NON_EXEC" -gt 0 ]; then
    echo "  [WARN] $NON_EXEC scripts in .icm/scripts lack +x permissions. Fixing..."
    chmod +x .icm/scripts/*.sh || true
  else
    echo "  [OK] All scripts in .icm/scripts possess executable permissions"
  fi
fi

# 6. Check Locale & UTF-8 Encoding
echo "[6/6] Checking System Locale & Encoding..."
if [[ "${LANG:-}" =~ UTF-8|utf8|UTF8 ]]; then
  echo "  [OK] Locale UTF-8 string support verified ($LANG)"
else
  echo "  [WARN] LANG is set to '${LANG:-unset}' (recommended: en_US.UTF-8 for decision regex checks)"
  WARNINGS=$((WARNINGS + 1))
fi

echo "-------------------------------------------------"
if [ "$ERRORS" -eq 0 ]; then
  echo "=== Environment Check PASSED ($WARNINGS warnings) ==="
  exit 0
else
  echo "=== Environment Check FAILED ($ERRORS critical errors, $WARNINGS warnings) ==="
  exit 1
fi
```

### C. Abstracted Release Notification Hook (`.icm/scripts/notify.sh`)
Deploy a project-owned notification hook stub to `.icm/scripts/notify.sh`:
```bash
#!/usr/bin/env bash
# Project Release Notification Hook
# Usage: .icm/scripts/notify.sh "<release_notes_summary>"
set -euo pipefail

RELEASE_NOTES="${1:-No release notes provided.}"

echo "=== Release Notification Hook ==="
echo "  Notes: $RELEASE_NOTES"

# Project-specific webhook implementation (e.g., Slack, Discord, Email)
# Example:
# if [ -n "${SLACK_WEBHOOK_URL:-}" ]; then
#   curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"$RELEASE_NOTES\"}" "$SLACK_WEBHOOK_URL"
# fi

exit 0
```

---

## 4. Contract Generalisation Guide (`sustentus` -> Template)

When re-founding `_system/template/icm-pipeline` from `sustentus`, Fable 5.1 MUST apply the following token substitution rules:

| Hardcoded `sustentus` Token | Generalised Template Replacement | Context / Purpose |
| :--- | :--- | :--- |
| `sustentus` | `{{PROJECT_NAME}}` / generic project reference | Project name in contract headers. |
| `jamie` / `david` | `Human Reviewer` / `Operator` | Role references in review gates and prompts. |
| `apps/docs/app` | `{{DOCS_PATH}}` (read from `.icm/project.json`) | Documentation directory root. |
| `#sustentus-dev` | Call `.icm/scripts/notify.sh` | Abstracted release notification. |
| Hardcoded repo URLs | Relative Git paths (`./`) | Git origin and remote links. |
| `03_build/output/run.md` | `03_build/output/notes.md` | Fixes incorrect file name reference for decision checks. |

---

## 5. Corrected Idempotent Sync Tool Specification (`icm-sync.sh`)

Fable 5.1 must deploy `_system/scripts/icm-sync.sh` inside `icm-board`:

```bash
#!/usr/bin/env bash
# Idempotent ICM Template Sync Script (v5.0 Corrected)
set -euo pipefail

DRY_RUN=1
TARGET_REPO=""

for arg in "$@"; do
  case "$arg" in
    --apply) DRY_RUN=0 ;;
    --dry-run) DRY_RUN=1 ;;
    *) if [ -z "$TARGET_REPO" ]; then TARGET_REPO="$arg"; fi ;;
  esac
done

if [ -z "$TARGET_REPO" ]; then
  echo "Usage: icm-sync.sh [--apply|--dry-run] <path-to-target-repo>"
  exit 1
fi

# Resolve TEMPLATE_DIR relative to script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$(cd "$SCRIPT_DIR/../template/icm-pipeline" && pwd)"
ICM_TARGET="$TARGET_REPO/.icm"

echo "=== ICM Template Sync ==="
echo "  Template Source: $TEMPLATE_DIR"
echo "  Target Repo:     $TARGET_REPO"
echo "  Execution Mode:  $([ "$DRY_RUN" -eq 1 ] && echo "DRY-RUN (Simulated)" || echo "APPLY (Live Changes)")"

# Profile Guard: Verify target is an SDLC pipeline project
TARGET_CONTEXT="$ICM_TARGET/CONTEXT.md"
if [ -f "$TARGET_CONTEXT" ]; then
  if grep -q "profile: intake" "$TARGET_CONTEXT"; then
    echo "  [ABORT] Target repository has 'profile: intake'. Skipping pipeline sync."
    exit 0
  fi
fi

mkdir -p "$ICM_TARGET"

RSYNC_FLAGS=("-av" "--checksum" "--itemize-changes")
if [ "$DRY_RUN" -eq 1 ]; then
  RSYNC_FLAGS+=("--dry-run")
fi

# Sync Template-Owned assets while protecting Project-Owned files
rsync "${RSYNC_FLAGS[@]}" \
  --exclude="_shared/project-rules.md" \
  --exclude="project.json" \
  --exclude="scripts/format.sh" \
  --exclude="scripts/lint.sh" \
  --exclude="scripts/validate-knowledge-map.sh" \
  --exclude="scripts/notify.sh" \
  "$TEMPLATE_DIR/" "$ICM_TARGET/"

echo "-------------------------------------------------"
echo "=== Sync Operation Complete ==="
```

---

## 6. Targeted Session Roadmap for Fable 5.1

### Phase 1: Refine `sustentus` Reference Implementation
1. Add `.icm/project.json` to `sustentus` (`name: "sustentus"`, `docs_path: "apps/docs/app"`).
2. Add `.icm/scripts/env-check.sh` and `.icm/scripts/notify.sh` to `sustentus`.
3. Add `.icm/scripts/validate-decisions.sh` to `sustentus`. The script MUST extract `| D-n |` IDs from `runs/<slug>/01_scope/output/scope.md` and check their presence in `02_define/output/spec.md` and `03_build/output/notes.md`.
4. Ensure `sustentus/.icm/CONTEXT.md` contains `- profile: pipeline`.

### Phase 2: Generalise & Re-Found Central Template (`icm-board`)
1. Copy stage contracts, preambles, helper libraries (`scripts/lib/***`), and 4 lanes (`bug`, `tweak`, `chore`, `knowledge`) from `sustentus` into `_system/template/icm-pipeline/`. Apply Section 4 generalisation rules.
2. Completely delete `01_scope/approve` directories from `_system/template/icm-pipeline/`.
3. Update `_system/scripts/icm-check.sh`, `_system/contracts/PIPELINE.md`, and `SKILL.md` to remove all `approve/` references.
4. Include canonical copies of `_shared/scope-template.md`, `_shared/conventions.md`, default project script stubs (`format.sh`, `lint.sh`, `validate-knowledge-map.sh`, `notify.sh`), and `scripts/env-check.sh`.

### Phase 3: Idempotency Testing & Sync Verification (`sustentus` <-> `icm-board`)
1. Run `_system/scripts/icm-sync.sh --dry-run sustentus` from `icm-board`.
2. Run `_system/scripts/icm-sync.sh --apply sustentus`.
3. Run `git status` in `sustentus` to verify that project-owned files (`project.json`, `format.sh`, `lint.sh`, `validate-knowledge-map.sh`, `notify.sh`, `project-rules.md`) remain untouched and clean.
4. Run `_system/scripts/icm-check.sh` and `.icm/scripts/env-check.sh` inside `sustentus`.

### Phase 4: Verification Output
Output a final summary report (`ICM_Refactoring_Verification.md`) detailing contract parity and sync validation between `icm-board` and `sustentus`.

---

*End of Master Directive (v5.0) — Ready for Agent Execution.*
