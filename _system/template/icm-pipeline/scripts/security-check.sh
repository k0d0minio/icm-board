#!/usr/bin/env bash
# security-check.sh — Release stop class 2, measured: a secret in this branch's diff, or a known-
# vulnerable dependency in a lockfile this branch changed. (TEMPLATE-OWNED)
#
# Two passes over the files this branch changed (lib/changed-files.sh — the same answer format.sh
# and lint.sh use: the fork point off <base> to the working tree, plus untracked files), and only
# over the LINES it added — a secret main already carries is main's fault, found by `--all`, not
# a reason to hold this PR:
#
#   1. Secrets   `gitleaks` when it is installed (the repo's own `.gitleaks.toml` honoured when
#                present; an inline `gitleaks:allow` comment is honoured either way): the added
#                lines of every changed file, copied under their repo-relative paths into a
#                temporary folder so one `detect --no-git` scans exactly the diff whatever the
#                gitleaks version, the line numbers mapped back. Without gitleaks, the built-in
#                pattern set below over the same lines: provider-shaped tokens (AWS, GitHub,
#                Slack, Stripe, Google, Anthropic, OpenAI, Resend, npm, SendGrid, Twilio),
#                private-key blocks, JWTs, connection strings carrying a password, and a
#                `key|secret|token|password = "<16+ mixed chars>"` assignment whose value is not
#                an obvious placeholder or an environment lookup. The patterns are a floor, not
#                gitleaks — env-check.sh names the install. Lockfiles, minified bundles, source
#                maps, media and binaries are never scanned; `error.log` itself is skipped.
#   2. Dependencies   the audit the repo's lockfile implies, at the repo root, on EVERY call
#                (`--no-audit` skips it — the audit is the one network call here, and the skip is
#                the operator's recorded waiver, never the stage's shortcut): pnpm-lock.yaml →
#                `pnpm audit --audit-level=high`; package-lock.json → `npm audit --audit-level=high`;
#                yarn.lock → `yarn npm audit --severity high` (berry) or `yarn audit --level high`
#                (classic); Cargo.lock → `cargo audit`; requirements.txt / poetry.lock /
#                pyproject.toml → `pip-audit`. High and critical count, whether or not this branch
#                touched the dependency — the repo ships what its lockfile pins. A lockfile whose
#                tool is not installed, or a registry that cannot be reached, is SKIPPED with the
#                reason — a fact about the machine, never a finding.
#
# What a finding does: it is printed as `[SECRET] <file>:<line> — <rule>` or `[AUDIT] <tool> →
# <summary>` — the matched VALUE is never printed, never logged — and, when the run is known
# (`<slug>`, or the run whose run.md records the current branch), appended to
# `.icm/runs/<slug>/03_build/output/error.log` (`--log <file>` names another file) as ONE ENTRY
# PER FINDING in the shape Build's Outputs define for that file: a dated `## ` header naming the
# source and the class (`security-check.sh — secret: <rule>` · `— audit: <tool>`), then the finding
# line verbatim. The session adds the `- resolved:` line once the secret is rotated or the bump
# landed — that is what lets `retrospective.sh` learn from it; this script never edits an entry it
# wrote. Then `RESULT: FINDINGS n`, exit 1. A secret found is a secret to ROTATE, not merely to
# remove from the diff — say so in the run's notes.
#
# It never fetches, installs, upgrades, commits or edits anything; there is no `--fix`.
#
# Usage: .icm/scripts/security-check.sh [<slug>] [--base <ref>] [--all] [--no-audit] [--no-secrets]
#                                        [--log <file>] [--quiet]
# Verdict (stdout, last line):
#   RESULT: CLEAN         exit 0  — nothing in the added lines, no high/critical advisory (or none owed)
#   RESULT: FINDINGS n    exit 1  — n findings, listed above (and in error.log) — Release stop class 2
#   RESULT: SKIP          exit 0  — nothing to scan: no changed files, and no audit owed
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$repo_root"
die() { echo "error: $*" >&2; exit 1; }

command -v git >/dev/null 2>&1 || die "git not found"
command -v jq  >/dev/null 2>&1 || die "jq not found"

slug=""; base=""; all=0; audit="yes"; do_secrets=1; log=""; quiet=0
while [ $# -gt 0 ]; do
  case "$1" in
    --base)       base="${2:-}"; [ -n "$base" ] || die "--base needs a ref"; shift 2 ;;
    --all)        all=1; shift ;;
    --no-audit)   audit="no"; shift ;;
    --no-secrets) do_secrets=0; shift ;;
    --log)        log="${2:-}"; [ -n "$log" ] || die "--log needs a file"; shift 2 ;;
    --quiet)      quiet=1; shift ;;
    -h|--help)    sed -n '2,45p' "${BASH_SOURCE[0]}"; exit 0 ;;
    --*)          die "unknown flag: $1 (usage: security-check.sh [<slug>] [--base <ref>] [--all] [--no-audit] [--no-secrets] [--log <file>] [--quiet])" ;;
    *)            [ -z "$slug" ] && slug="$1" || die "unexpected argument: $1"; shift ;;
  esac
done
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || die "not a git repository"

# shellcheck source=lib/project.sh
source "$here/lib/project.sh"
# shellcheck source=lib/changed-files.sh
source "$here/lib/changed-files.sh"

branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo HEAD)"
head_sha="$(git rev-parse --short HEAD 2>/dev/null || echo unknown)"

# --- the run, and where its findings go --------------------------------------------------------------------
run_dir=""
if [ -n "$slug" ]; then
  for d in ".icm/runs/$slug" "$runs_archive_rel/$slug"; do
    [ -f "$d/run.md" ] && { run_dir="$d"; break; }
  done
  [ -n "$run_dir" ] || die "no run.md for '$slug' in .icm/runs/ or $runs_archive_rel/ — pass --log <file>, or omit the slug"
else
  # The run whose run.md records this branch — the same `- branch:` line resolve-run.sh checks out.
  for f in .icm/runs/*/run.md; do
    [ -f "$f" ] || continue
    b="$(grep -m1 '^- branch:' "$f" 2>/dev/null | sed -E 's/^- branch:[[:space:]]*//; s/[[:space:]]+#.*$//; s/[[:space:]]*$//' || true)"
    if [ -n "$b" ] && [ "$b" = "$branch" ]; then run_dir="$(dirname "$f")"; slug="$(basename "$run_dir")"; break; fi
  done
fi
if [ -z "$log" ] && [ -n "$run_dir" ]; then log="$run_dir/03_build/output/error.log"; fi

# --- the files: this branch's changes, or the whole tree -----------------------------------------------------
if [ -z "$base" ]; then
  if git rev-parse --verify --quiet 'origin/main^{commit}' >/dev/null; then base="origin/main"
  elif git rev-parse --verify --quiet 'main^{commit}' >/dev/null; then base="main"
  else base="origin/main"; fi
fi

fork=""
declare -a files=()
if [ "$all" -eq 1 ]; then
  mapfile -t files < <({ git ls-files; git ls-files --others --exclude-standard; } | sort -u \
    | while IFS= read -r f; do [ -f "$f" ] && printf '%s\n' "$f"; done)
else
  fork="$(fork_point "$base")" || exit 1
  mapfile -t files < <(changed_files "$fork")
fi

skip_path() { # lockfiles, generated bundles, media, binaries by extension — and the log this script writes
  case "$1" in
    *.lock|pnpm-lock.yaml|*/pnpm-lock.yaml|package-lock.json|*/package-lock.json|bun.lockb|*/bun.lockb) return 0 ;;
    *.min.js|*.min.css|*.map|*.svg|*.png|*.jpg|*.jpeg|*.gif|*.webp|*.ico|*.pdf|*.woff|*.woff2|*.ttf|*.eot|*.otf) return 0 ;;
    *.zip|*.gz|*.tgz|*.tar|*.7z|*.mp3|*.mp4|*.wav|*.mov|*.webm|*.wasm|*.jar|*.class|*.pyc) return 0 ;;
    */error.log) return 0 ;;
  esac
  return 1
}

declare -a scan_files=()
skipped=0
for f in "${files[@]}"; do
  if skip_path "$f" || ! grep -Iq '' "$f" 2>/dev/null; then skipped=$((skipped + 1)); continue; fi
  scan_files+=("$f")
done

if [ "$all" -eq 1 ]; then
  echo "scanning the whole tree: ${#scan_files[@]} file(s) ($skipped skipped: lockfiles, bundles, media, binaries)"
else
  echo "scanning ${#scan_files[@]} changed file(s) on $branch against $base (fork ${fork:0:7}; $skipped skipped: lockfiles, bundles, media, binaries)"
fi

# One "<line>\t<text>" per line this branch ADDED to <file> — the whole file when it is untracked or --all.
added_lines() {
  local f="$1"
  if [ "$all" -eq 1 ] || [ -z "$fork" ] || ! git ls-files --error-unmatch -- "$f" >/dev/null 2>&1; then
    awk '{ print NR "\t" $0 }' "$f"
  else
    git diff -U0 --no-color "$fork" -- "$f" | awk '
      /^@@/     { if (match($0, /\+[0-9]+/)) n = substr($0, RSTART + 1, RLENGTH - 1) + 0; next }
      /^\+\+\+ / { next }
      /^\+/     { print n "\t" substr($0, 2); n++ }'
  fi
}

declare -a findings=() pending=()
declare -A flagged=()   # "<file>:<line>" already carrying a finding — one line, one finding
add_finding() { pending+=("$1"); }
# Print a pass's findings sorted by file and line, then bank them.
flush_findings() {
  [ "${#pending[@]}" -gt 0 ] || return 0
  local sorted
  mapfile -t sorted < <(printf '%s\n' "${pending[@]}" | sort -t: -k1,1 -k2,2n)
  [ "$quiet" -eq 1 ] || printf '  %s\n' "${sorted[@]}"
  findings+=("${sorted[@]}"); pending=()
}

# --- pass 1: secrets -----------------------------------------------------------------------------------------

# A line that is plainly not a literal secret: a placeholder, a template, an environment lookup,
# or an explicit allow comment. Case-insensitive, applied to the whole line.
placeholder='(<[^>]*>|\$\{|\$[A-Z_]{3,}|process\.env|import\.meta\.env|os\.environ|getenv\(|(^|[^A-Za-z0-9_])env\(|xxx|your[-_ ]|example|placeholder|changeme|change[-_ ]me|dummy|redacted|\*\*\*|\.\.\.|todo|fixme|sample|lorem|0000000000|1111111111|1234567890|security-check: ?allow|gitleaks:allow)'

# The built-in floor. "<name>::<ERE>"; a name ending in "(ci)" is matched case-insensitively.
# A word boundary is spelled (^|[^A-Za-z0-9_]) — `\b` is GNU-only.
patterns=(
  'aws-access-key::(^|[^A-Za-z0-9_])(A3T[A-Z0-9]|AKIA|ASIA|ABIA|ACCA)[A-Z0-9]{16}'
  'github-token::(^|[^A-Za-z0-9_])(gh[pousr]_[A-Za-z0-9]{36,}|github_pat_[A-Za-z0-9_]{22,})'
  'slack-token::(^|[^A-Za-z0-9_])xox[abprs]-[A-Za-z0-9-]{10,}'
  'slack-webhook::hooks\.slack\.com/services/T[A-Za-z0-9]+/B[A-Za-z0-9]+/[A-Za-z0-9]+'
  'stripe-key::(^|[^A-Za-z0-9_])(sk|rk)_(live|test)_[A-Za-z0-9]{16,}'
  'stripe-webhook-secret::(^|[^A-Za-z0-9_])whsec_[A-Za-z0-9]{24,}'
  'google-api-key::(^|[^A-Za-z0-9_])AIza[0-9A-Za-z_-]{35}'
  'anthropic-key::(^|[^A-Za-z0-9_])sk-ant-[A-Za-z0-9_-]{20,}'
  'openai-key::(^|[^A-Za-z0-9_])sk-(proj-)?[A-Za-z0-9_-]{32,}'
  'resend-key::(^|[^A-Za-z0-9_])re_[A-Za-z0-9]{6,}_[A-Za-z0-9]{16,}'
  'npm-token::(^|[^A-Za-z0-9_])npm_[A-Za-z0-9]{36}'
  'sendgrid-key::(^|[^A-Za-z0-9_])SG\.[A-Za-z0-9_-]{22}\.[A-Za-z0-9_-]{43}'
  'twilio-key::(^|[^A-Za-z0-9_])SK[0-9a-fA-F]{32}([^A-Za-z0-9_]|$)'
  'private-key::-----BEGIN (RSA |EC |DSA |OPENSSH |PGP )?PRIVATE KEY( BLOCK)?-----'
  'jwt::(^|[^A-Za-z0-9_])eyJ[A-Za-z0-9_-]{10,}\.eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}'
  'connection-string-password::(postgres(ql)?|mysql|mongodb(\+srv)?|redis|amqp|mssql)://[^:/@[:space:]"'"'"']+:[^@[:space:]"'"'"']{4,}@'
  'generic-assignment(ci)::(api[_-]?key|secret|token|passw(or)?d|private[_-]?key|auth[_-]?key)[A-Za-z0-9_]*[[:space:]]*[:=][[:space:]]*["'"'"'`][A-Za-z0-9_/+=.-]{16,}["'"'"'`]'
)

scan_patterns() {
  local f buf p name rx flags hits n text val
  for f in "${scan_files[@]}"; do
    buf="$(added_lines "$f")"
    [ -n "$buf" ] || continue
    for p in "${patterns[@]}"; do
      name="${p%%::*}"; rx="${p#*::}"; flags="-E"
      case "$name" in *"(ci)") flags="-Ei"; name="${name%(ci)}" ;; esac
      hits="$(printf '%s\n' "$buf" | grep $flags -- "$rx" || true)"
      [ -n "$hits" ] || continue
      while IFS=$'\t' read -r n text; do
        [ -n "$n" ] || continue
        printf '%s' "$text" | grep -Eiq -- "$placeholder" && continue
        # One line, one finding: the rules run most-specific first, and the first to name a line wins.
        [ -z "${flagged[$f:$n]+x}" ] || continue
        if [ "$name" = "generic-assignment" ]; then
          # The noisiest rule earns its finding only on a value that looks generated — digits AND letters.
          val="$(printf '%s' "$text" | grep -oE -- "[\"'\`][A-Za-z0-9_/+=.-]{16,}[\"'\`]" | head -1 || true)"
          printf '%s' "$val" | grep -q '[0-9]'    || continue
          printf '%s' "$val" | grep -q '[A-Za-z]' || continue
        fi
        flagged["$f:$n"]=1
        add_finding "[SECRET] $f:$n — $name (pattern)"
      done <<< "$hits"
    done
  done
}

# gitleaks over exactly the added lines: each file's added text lands at its own path under a
# temporary folder, a sidecar file maps the folder's line numbers back to the repo's. Returns 1
# when gitleaks could not run, so the caller falls back to the patterns.
scan_gitleaks() {
  local tmp rep f rc cfg=() file line rule real
  tmp="$(mktemp -d)"; rep="$tmp/report.json"
  for f in "${scan_files[@]}"; do
    mkdir -p "$tmp/src/$(dirname "$f")" "$tmp/map/$(dirname "$f")"
    added_lines "$f" | awk -F'\t' -v src="$tmp/src/$f" -v map="$tmp/map/$f" '
      { print $1 > map; sub(/^[^\t]*\t/, ""); print > src }'
  done
  [ ! -f .gitleaks.toml ] || cfg=(--config .gitleaks.toml)
  set +e
  gitleaks detect --no-git --source "$tmp/src" "${cfg[@]}" --report-format json --report-path "$rep" --exit-code 2 >"$tmp/out" 2>&1
  rc=$?
  set -e
  case "$rc" in
    0) ;;
    2)
      while IFS=$'\t' read -r file line rule; do
        [ -n "$file" ] || continue
        file="${file#"$tmp/src/"}"
        real="$(sed -n "${line}p" "$tmp/map/$file" 2>/dev/null || true)"
        flagged["$file:${real:-$line}"]=1
        add_finding "[SECRET] $file:${real:-$line} — $rule (gitleaks)"
      done < <(jq -r '.[] | [.File, (.StartLine|tostring), .RuleID] | @tsv' "$rep" 2>/dev/null)
      ;;
    *)
      echo "  [WARN] gitleaks exited $rc — $(tr '\n' ' ' < "$tmp/out" | head -c 160) — using the built-in patterns instead"
      rm -rf "$tmp"; return 1 ;;
  esac
  rm -rf "$tmp"; return 0
}

secrets_ran=0
lines_word="the added lines"; [ "$all" -eq 0 ] || lines_word="every line"
if [ "$do_secrets" -eq 1 ] && [ "${#scan_files[@]}" -gt 0 ]; then
  secrets_ran=1
  if command -v gitleaks >/dev/null 2>&1; then
    echo "[1/2] secrets — gitleaks over $lines_word$( [ -f .gitleaks.toml ] && echo ' (.gitleaks.toml honoured)')"
    scan_gitleaks || scan_patterns
  else
    echo "[1/2] secrets — built-in patterns over $lines_word (gitleaks not installed; env-check.sh names it)"
    scan_patterns
  fi
  flush_findings
elif [ "$do_secrets" -eq 0 ]; then
  echo "[1/2] secrets — skipped (--no-secrets)"
else
  echo "[1/2] secrets — nothing to scan"
fi

# --- pass 2: dependencies ------------------------------------------------------------------------------------

net_re='ENOAUDIT|ENOTFOUND|EAI_AGAIN|ECONNRESET|ECONNREFUSED|ETIMEDOUT|ERR_PNPM_(FETCH|META_FETCH|NO_OFFLINE)|fetch failed|couldn.t fetch|unable to fetch|Network|network|unexpected error occurred|getaddrinfo'

run_audit() { # <label> <hint> <cmd...>  — prints one line per outcome; a vulnerability is a finding
  local label="$1" hint="$2"; shift 2
  local tool="$1" out rc summary
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "  [SKIP] $label — $tool not installed ($hint)"; return 0
  fi
  echo "  running: $*"
  set +e
  if command -v timeout >/dev/null 2>&1; then out="$(timeout 180 "$@" 2>&1)"; rc=$?; else out="$("$@" 2>&1)"; rc=$?; fi
  set -e
  case "$label" in
    "yarn (classic)")
      # yarn 1 exits with a severity bitmask: 1 info · 2 low · 4 moderate · 8 high · 16 critical.
      if printf '%s' "$out" | grep -Eq -- "$net_re"; then echo "  [SKIP] $label — the registry could not be reached"; return 0; fi
      if [ $(( rc & 24 )) -eq 0 ]; then echo "  [OK] $label — no high or critical advisory"; return 0; fi
      ;;
    *)
      if [ "$rc" -eq 0 ]; then echo "  [OK] $label — no high or critical advisory"; return 0; fi
      if [ "$rc" -eq 124 ]; then echo "  [SKIP] $label — timed out after 180s"; return 0; fi
      if printf '%s' "$out" | grep -Eq -- "$net_re" && ! printf '%s' "$out" | grep -Eiq 'vulnerabilit'; then
        echo "  [SKIP] $label — the registry could not be reached"; return 0
      fi
      ;;
  esac
  summary="$(printf '%s\n' "$out" | grep -Ei -- '[0-9]+ (high|critical)|vulnerabilit(y|ies) found|found [0-9]+ known|Severity:' | tail -n1 | sed -E 's/^[[:space:]]+//' | head -c 160)"
  add_finding "[AUDIT] $label → ${summary:-exit $rc} (run: $* for the table)"
}

audit_ran=0
if [ "$audit" = "no" ]; then
  echo "[2/2] dependencies — skipped (--no-audit: the operator's waiver, recorded in the run's record)"
else
  echo "[2/2] dependencies — the lockfile's own audit, at high"
  [ -f pnpm-lock.yaml ]   && { audit_ran=1; run_audit "pnpm audit" "the repo's package manager" pnpm audit --audit-level=high; }
  [ -f package-lock.json ] && { audit_ran=1; run_audit "npm audit" "the repo's package manager" npm audit --audit-level=high; }
  if [ -f yarn.lock ]; then
    audit_ran=1
    ymaj="$(yarn --version 2>/dev/null | cut -d. -f1 || echo 1)"
    if [ "${ymaj:-1}" -ge 2 ]; then run_audit "yarn npm audit" "the repo's package manager" yarn npm audit --severity high
    else run_audit "yarn (classic)" "the repo's package manager" yarn audit --level high; fi
  fi
  [ -f bun.lock ] || [ -f bun.lockb ] && { audit_ran=1; echo "  [SKIP] bun lockfile — no audit wired for bun here; the repo's CI owns it"; }
  if [ -f Cargo.lock ]; then
    audit_ran=1
    if command -v cargo >/dev/null 2>&1 && cargo audit --version >/dev/null 2>&1; then run_audit "cargo audit" "" cargo audit
    else echo "  [SKIP] cargo audit — cargo-audit not installed (cargo install cargo-audit)"; fi
  fi
  if [ -f requirements.txt ] || [ -f poetry.lock ] || [ -f pyproject.toml ] || [ -f Pipfile.lock ]; then
    audit_ran=1
    if [ -f requirements.txt ]; then run_audit "pip-audit" "pipx install pip-audit" pip-audit -r requirements.txt
    else run_audit "pip-audit" "pipx install pip-audit" pip-audit; fi
  fi
  [ "$audit_ran" -eq 1 ] || echo "  [INFO] no lockfile at the repo root — nothing to audit"
  flush_findings
fi

# --- the record, and the verdict -----------------------------------------------------------------------------

echo "-------------------------------------------------"
n="${#findings[@]}"
if [ "$n" -gt 0 ] && [ -n "$log" ]; then
  mkdir -p "$(dirname "$log")"
  stamp="$(date -u +%FT%TZ)"
  {
    for line in "${findings[@]}"; do
      # One entry per finding, in error.log's shape: the header carries the CLASS (the rule, or
      # the audit tool) so retrospective.sh signs it as a class, never as this file:line.
      case "$line" in
        "[SECRET] "*) cls="secret: $(printf '%s' "$line" | sed -E 's/^.* — ([^ ]+) \((pattern|gitleaks)\)$/\1/')" ;;
        "[AUDIT] "*)  cls="audit: $(printf '%s' "$line" | sed -E 's/^\[AUDIT\] ([^→]+) →.*$/\1/; s/[[:space:]]+$//')" ;;
        *)            cls="finding" ;;
      esac
      echo "## $stamp security-check.sh — $cls ($branch @ $head_sha)"
      echo "$line"
      echo
    done
  } >> "$log"
  echo "appended $n entr$( [ "$n" -eq 1 ] && echo y || echo ies) to $log — add each entry's '- resolved:' line once the secret is rotated or the bump landed"
elif [ "$n" -gt 0 ]; then
  echo "no run resolved for this branch — findings printed only (pass <slug> or --log <file> to record them)"
fi

if [ "$n" -gt 0 ]; then
  echo "a secret is rotated by the operator, never just deleted from the diff; an advisory is bumped on the branch, or waived by the operator in the run's record (--no-audit)"
  echo "RESULT: FINDINGS $n"; exit 1
fi
if [ "$secrets_ran" -eq 0 ] && [ "$audit_ran" -eq 0 ]; then
  echo "RESULT: SKIP"; exit 0
fi
echo "RESULT: CLEAN"; exit 0
