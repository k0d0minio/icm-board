#!/usr/bin/env bash
# icm-check.sh — verify (and with --fix, populate) the estate-wide .icm/.claude baseline.
#
# Discovers git repos the same way pull-all.sh does — the root repo itself (icm-board,
# .git at the Apps root) plus every repo up to 2 levels below Apps/ — skips sustentus
# (its .icm/ carries its own pipeline semantics; it is the source the template was
# extracted from), and checks each repo against _system/template/:
#
#   .icm/CONTEXT.md          the repo's .icm map; carries the `- profile:` line
#   .icm/intake/README.md    micro-copy of the intake contract (epics + stubs + triage)
#   .icm/intake/triage/      the parking lane
#   .icm/intake/_done/       the archive (completed epics + legacy tickets)
#   .icm/docs/               ad hoc reports
#   .claude/settings.json    clean policy baseline
#   .claude/hooks/*          canonical estate hooks (session-start, wrap-reminder)
#   .claude/skills/*         canonical estate skills (ticket-craft, pr-conventions)
#   CLAUDE.md                reported only — never templated (each repo writes its own)
#   .icm/project.md          reported only — /project writes it from an interrogation
#
# A repo whose .icm/CONTEXT.md declares `- profile: pipeline` (contracts/PIPELINE.md) is
# additionally checked — and with --fix, seeded — against the pipeline profile:
# template/icm-pipeline/ → .icm/, template/claude-pipeline/ → .claude/,
# template/github-pipeline/ → .github/. Declaring the profile is Jamie's act; the fix
# never upgrades one.
#
# --fix creates ONLY what is missing, from the template; existing files are never
# touched. A repo's copy of a canonical asset that has diverged from the template is
# reported as drift and never repaired — repos own their copies (template/README.md).
# Legacy flat PREFIX-NNN tickets are reported as unmigrated, never converted.
#
# Usage: _system/scripts/icm-check.sh [--fix] [root]
# Exit:  0 all conformant (warnings allowed) · 1 gaps remain · 2 bad invocation

set -uo pipefail

FIX=0
APPS_ROOT=""
for arg in "$@"; do
  case "$arg" in
    --fix) FIX=1 ;;
    -*) echo "Unknown flag: $arg" >&2; exit 2 ;;
    *) APPS_ROOT="$arg" ;;
  esac
done
[[ -n "$APPS_ROOT" ]] || APPS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TEMPLATE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/template"

if [[ ! -d "$APPS_ROOT" ]]; then echo "Not a directory: $APPS_ROOT" >&2; exit 2; fi
if [[ ! -d "$TEMPLATE/icm" || ! -d "$TEMPLATE/claude" ]]; then
  echo "Template missing or incomplete: $TEMPLATE" >&2; exit 2
fi

EXEMPT=("sustentus")

# Canonical Claude assets (template/claude/…): seeded when missing, drift-reported when
# a repo's copy diverges — never overwritten. Paths relative to <repo>/.claude/.
CANONICAL=(
  "hooks/session-start.sh"
  "hooks/wrap-reminder.sh"
  "skills/ticket-craft/SKILL.md"
  "skills/pr-conventions/SKILL.md"
)

# Pipeline profile (template/icm-pipeline/…): paths relative to <repo>/.icm/.
PIPELINE_ICM=(
  "stages/01_define/CONTEXT.md"
  "stages/02_build/CONTEXT.md"
  "stages/03_release/CONTEXT.md"
  "lanes/bug/CONTEXT.md"
  "lanes/tweak/CONTEXT.md"
  "lanes/chore/CONTEXT.md"
  "_shared/github.md"
  "_shared/ci.md"
  "_shared/stage-preamble.md"
  "runs/README.md"
  "scripts/resolve-run.sh"
  "scripts/validate-spec.sh"
  "scripts/validate-intake.sh"
  "scripts/new-run.sh"
  "scripts/ci-status.sh"
)
PIPELINE_CLAUDE=( "skills/pipeline/SKILL.md" )
PIPELINE_GITHUB=( "pull_request_template.md" )

bold=$'\033[1m'; red=$'\033[31m'; green=$'\033[32m'; yellow=$'\033[33m'; dim=$'\033[2m'; off=$'\033[0m'
[[ -t 1 ]] || { bold=; red=; green=; yellow=; dim=; off=; }

mapfile -t repos < <(
  find "$APPS_ROOT" -mindepth 2 -maxdepth 3 -name .git \
    \( -type d -o -type f \) \
    -not -path '*/node_modules/*' \
    -not -path '*/.*/.*/.git' \
    -printf '%h\n' | sort
)
# The root repo itself (icm-board, .git at the Apps root), checked like any other. It
# holds the baseline, so it is measured against it — a rule this repo exempts itself
# from is a rule it should delete (CLAUDE.md, standing rules).
[[ -e "$APPS_ROOT/.git" ]] && repos=("$APPS_ROOT" "${repos[@]}")

total=0; conformant=0; fixed=0; warnings=0; gaps=0

for repo in "${repos[@]}"; do
  name="${repo#"$APPS_ROOT"/}"
  base="$(basename "$repo")"
  [[ "$repo" == "$APPS_ROOT" ]] && name="$base"

  skip=0
  for e in "${EXEMPT[@]}"; do [[ "$base" == "$e" ]] && skip=1; done
  if (( skip )); then
    echo "${dim}${name} — exempt${off}"
    continue
  fi

  total=$((total + 1))
  missing=(); warns=(); actions=()

  pipeline=0
  grep -qE '^- *profile: *pipeline' "$repo/.icm/CONTEXT.md" 2>/dev/null && pipeline=1

  # --- .icm baseline ---
  [[ -f "$repo/.icm/CONTEXT.md" ]]        || missing+=(".icm/CONTEXT.md")
  [[ -d "$repo/.icm/intake" ]]            || missing+=(".icm/intake/")
  [[ -f "$repo/.icm/intake/README.md" ]]  || missing+=(".icm/intake/README.md")
  [[ -d "$repo/.icm/intake/triage" ]]     || missing+=(".icm/intake/triage/")
  [[ -d "$repo/.icm/intake/_done" ]]      || missing+=(".icm/intake/_done/")
  [[ -d "$repo/.icm/docs" ]]              || missing+=(".icm/docs/")

  # --- .claude baseline ---
  [[ -d "$repo/.claude" ]]               || missing+=(".claude/")
  [[ -f "$repo/.claude/settings.json" ]] || missing+=(".claude/settings.json")
  for asset in "${CANONICAL[@]}"; do
    [[ -f "$repo/.claude/$asset" ]] || missing+=(".claude/$asset")
  done

  # --- pipeline profile (only when the repo declares it) ---
  if (( pipeline )); then
    for p in "${PIPELINE_ICM[@]}";    do [[ -f "$repo/.icm/$p"     ]] || missing+=(".icm/$p"); done
    for p in "${PIPELINE_CLAUDE[@]}"; do [[ -f "$repo/.claude/$p"  ]] || missing+=(".claude/$p"); done
    for p in "${PIPELINE_GITHUB[@]}"; do [[ -f "$repo/.github/$p"  ]] || missing+=(".github/$p"); done
  fi

  # --- canonical drift (report-only, never repaired — repos own their copies) ---
  for asset in "${CANONICAL[@]}"; do
    if [[ -f "$repo/.claude/$asset" ]] && ! cmp -s "$TEMPLATE/claude/$asset" "$repo/.claude/$asset"; then
      warns+=("drift from canonical: .claude/$asset differs from _system/template/claude/$asset")
    fi
  done
  # Hooks seeded into a repo whose settings.json predates the wiring are inert; say so.
  if [[ -f "$repo/.claude/settings.json" ]]; then
    for hook in session-start.sh wrap-reminder.sh; do
      if [[ -f "$repo/.claude/hooks/$hook" ]] && \
         ! grep -q "$hook" "$repo/.claude/settings.json" 2>/dev/null; then
        warns+=("hook .claude/hooks/$hook exists but settings.json never registers it (inert)")
      fi
    done
  fi

  # --- report-only checks (agent/human territory, never auto-fixed) ---
  [[ -f "$repo/CLAUDE.md" ]] || warns+=("no CLAUDE.md (Layer-0 identity/routing file)")
  # Deliberately never templated: an empty register is worse than none, because it
  # reads as established intent. /project writes it from a real interrogation.
  [[ -f "$repo/.icm/project.md" ]] || warns+=("no .icm/project.md — /project has never run here")
  legacy=0
  for f in "$repo/.icm/intake"/*.md; do
    [[ -e "$f" ]] || continue
    case "$(basename "$f" | tr '[:upper:]' '[:lower:]')" in readme.md|context.md) continue ;; esac
    legacy=$((legacy + 1))
  done
  (( legacy > 0 )) && warns+=("$legacy legacy flat ticket(s) in .icm/intake/ — unmigrated to the epic layout (/project re-cuts them; never converted here)")
  if git -C "$repo" check-ignore -q .icm 2>/dev/null; then
    warns+=(".gitignore excludes .icm — tickets would never reach the board")
  fi
  if git -C "$repo" check-ignore -q .claude/settings.json 2>/dev/null; then
    warns+=(".gitignore excludes .claude/settings.json — policy won't ship to cloud sessions")
  fi
  if [[ -f "$repo/.claude/settings.local.json" ]] && \
     ! git -C "$repo" check-ignore -q .claude/settings.local.json 2>/dev/null; then
    warns+=(".claude/settings.local.json is not gitignored (accretion layer should stay local)")
  fi
  for loose in TODO.md BACKLOG.md; do
    [[ -f "$repo/$loose" ]] && warns+=("loose $loose at root — should be stubs in .icm/intake/")
  done

  # --- fix ---
  if (( FIX )) && (( ${#missing[@]} > 0 )); then
    mkdir -p "$repo/.icm/intake/_done" "$repo/.icm/intake/triage/_done" "$repo/.icm/docs" "$repo/.claude"
    [[ -f "$repo/.icm/intake/_done/.gitkeep" ]] || : > "$repo/.icm/intake/_done/.gitkeep"
    [[ -f "$repo/.icm/intake/triage/_done/.gitkeep" ]] || : > "$repo/.icm/intake/triage/_done/.gitkeep"
    # .gitkeep only if docs/ is empty, so it can be dropped once real docs land
    if [[ -z "$(ls -A "$repo/.icm/docs" 2>/dev/null)" ]]; then
      : > "$repo/.icm/docs/.gitkeep"
    fi
    if [[ ! -f "$repo/.icm/CONTEXT.md" ]]; then
      cp "$TEMPLATE/icm/CONTEXT.md" "$repo/.icm/CONTEXT.md"
      actions+=("created .icm/CONTEXT.md (profile: intake)")
    fi
    if [[ ! -f "$repo/.icm/intake/README.md" ]]; then
      cp "$TEMPLATE/icm/intake/README.md" "$repo/.icm/intake/README.md"
      actions+=("created .icm/intake/README.md")
    fi
    if [[ ! -f "$repo/.claude/settings.json" ]]; then
      cp "$TEMPLATE/claude/settings.json" "$repo/.claude/settings.json"
      actions+=("created .claude/settings.json")
    fi
    for asset in "${CANONICAL[@]}"; do
      if [[ ! -f "$repo/.claude/$asset" ]]; then
        mkdir -p "$(dirname "$repo/.claude/$asset")"
        cp "$TEMPLATE/claude/$asset" "$repo/.claude/$asset"
        case "$asset" in hooks/*) chmod +x "$repo/.claude/$asset" ;; esac
        actions+=("created .claude/$asset")
      fi
    done
    if (( pipeline )); then
      for p in "${PIPELINE_ICM[@]}"; do
        if [[ ! -f "$repo/.icm/$p" ]]; then
          mkdir -p "$(dirname "$repo/.icm/$p")"
          cp "$TEMPLATE/icm-pipeline/$p" "$repo/.icm/$p"
          case "$p" in scripts/*) chmod +x "$repo/.icm/$p" ;; esac
          actions+=("created .icm/$p")
        fi
      done
      for p in "${PIPELINE_CLAUDE[@]}"; do
        if [[ ! -f "$repo/.claude/$p" ]]; then
          mkdir -p "$(dirname "$repo/.claude/$p")"
          cp "$TEMPLATE/claude-pipeline/$p" "$repo/.claude/$p"
          actions+=("created .claude/$p")
        fi
      done
      for p in "${PIPELINE_GITHUB[@]}"; do
        if [[ ! -f "$repo/.github/$p" ]]; then
          mkdir -p "$repo/.github"
          cp "$TEMPLATE/github-pipeline/$p" "$repo/.github/$p"
          actions+=("created .github/$p")
        fi
      done
    fi
    fixed=$((fixed + 1))
    missing=()
    # re-verify what we just created
    for p in .icm/CONTEXT.md .icm/intake/README.md .icm/intake/triage .icm/intake/_done .icm/docs .claude/settings.json; do
      [[ -e "$repo/$p" ]] || missing+=("$p (fix failed)")
    done
    for asset in "${CANONICAL[@]}"; do
      [[ -f "$repo/.claude/$asset" ]] || missing+=(".claude/$asset (fix failed)")
    done
    if (( pipeline )); then
      for p in "${PIPELINE_ICM[@]}";    do [[ -f "$repo/.icm/$p"    ]] || missing+=(".icm/$p (fix failed)"); done
      for p in "${PIPELINE_CLAUDE[@]}"; do [[ -f "$repo/.claude/$p" ]] || missing+=(".claude/$p (fix failed)"); done
      for p in "${PIPELINE_GITHUB[@]}"; do [[ -f "$repo/.github/$p" ]] || missing+=(".github/$p (fix failed)"); done
    fi
  fi

  # --- report ---
  label="$name"
  (( pipeline )) && label="$name ${dim}(pipeline)${off}"
  if (( ${#missing[@]} == 0 && ${#warns[@]} == 0 && ${#actions[@]} == 0 )); then
    echo "${green}ok${off}   $label"
    conformant=$((conformant + 1))
  else
    if (( ${#missing[@]} > 0 )); then
      echo "${red}GAP${off}  ${bold}$label${off}"
      gaps=$((gaps + 1))
    else
      echo "${green}ok${off}   ${bold}$label${off}"
      conformant=$((conformant + 1))
    fi
    for a in "${actions[@]}"; do echo "       ${green}+${off} $a"; done
    for m in "${missing[@]}"; do echo "       ${red}missing${off} $m"; done
    for w in "${warns[@]}"; do echo "       ${yellow}warn${off} $w"; warnings=$((warnings + 1)); done
  fi
done

echo
echo "RESULT: $total repos checked, $conformant conformant, $gaps with gaps, $fixed fixed, $warnings warnings$( (( FIX )) || echo ' (check only — rerun with --fix to populate)')"
(( gaps == 0 ))
