#!/usr/bin/env bash
# close-out-working-tree.sh — regression check for the template's `close-out.sh` archive move.
#
# Found by agorasim (8ba2ccc) and sustentus (PRs 1168, 1189, 1202), 2026-09-25/26: every lane and
# Release appends `usage-snapshot.sh <slug> <stage> end` to .icm/runs/<slug>/usage.md immediately
# before `close-out.sh`, and close-out moved the run with a bare `git mv` — which carries the INDEX
# copy. The archived usage.md lost its end line (`usage.md | 0` in the close-out commit), the tree
# was left dirty, and every run needed a follow-up commit. `.icm/intake/triage/
# template-close-out-archives-the-working-tree.md` is the ticket.
#
# Builds a throwaway repo from _system/template/icm-pipeline/scripts, points lib/gh.sh at a local
# mock of the GitHub API (GITHUB_API_URL) that answers every PR as open, then asserts:
#   1. a lane run with an unstaged append and an untracked file → CLOSED; the archive commit
#      carries both, and the working tree is clean;
#   2. --dry-run stages nothing;
#   3. the front run that rides along with a finished epic carries its own unstaged append too.
#
# Needs bash, git, jq, curl, python3 (all on ubuntu-latest). Touches nothing outside a mktemp dir.
# Usage: _system/scripts/close-out-working-tree.sh     Exit: 0 pass · 1 a check failed
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPTS="$ROOT/_system/template/icm-pipeline/scripts"
lab="$(mktemp -d)"; pids=()
cleanup() { for p in "${pids[@]}"; do kill "$p" 2>/dev/null; done; rm -rf "$lab"; }
trap cleanup EXIT

fails=0
check() { if eval "$2"; then echo "  ok    $1"; else echo "  FAIL  $1"; fails=$((fails + 1)); fi; }

# --- a mock GitHub API: every PR is open ------------------------------------------------------------
cat > "$lab/mock.py" <<'PY'
import http.server, json, sys
class H(http.server.BaseHTTPRequestHandler):
    def log_message(self, *a): pass
    def do_GET(self):
        code, obj = (200, {"state": "open", "merged": False}) if "/pulls/" in self.path else (404, {})
        b = json.dumps(obj).encode(); self.send_response(code)
        self.send_header("content-type", "application/json"); self.end_headers(); self.wfile.write(b)
http.server.ThreadingHTTPServer(("127.0.0.1", int(sys.argv[1])), H).serve_forever()
PY
port="$(python3 -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1",0)); print(s.getsockname()[1])')"
python3 "$lab/mock.py" "$port" >/dev/null 2>&1 & pids+=($!)
for _ in $(seq 1 50); do curl -s -o /dev/null "http://127.0.0.1:$port/" && break; sleep 0.1; done
curl -s -o /dev/null "http://127.0.0.1:$port/" || { echo "mock API did not start"; exit 1; }

export GITHUB_API_URL="http://127.0.0.1:$port" GITHUB_TOKEN=lab-not-a-token GH_TOKEN='' GITHUB_REPO=lab/repo

# A fresh repo per case: the template scripts at .icm/scripts, a run branch checked out.
new_repo() {
  local d="$lab/$1"
  mkdir -p "$d/.icm" && cd "$d" || exit 1
  git init -q -b main
  git config user.email test@example.com
  git config user.name Test
  cp -r "$SCRIPTS" .icm/scripts
  echo '{"name": "lab"}' > .icm/project.json
}
seed_run() { # <slug> [pr]
  mkdir -p ".icm/runs/$1"
  printf '# Run: %s\n\n' "$1" > ".icm/runs/$1/run.md"
  [ -n "${2:-}" ] && printf -- '- pr: #%s\n' "$2" >> ".icm/runs/$1/run.md"
  printf '| %s | build | start |\n' "$1" > ".icm/runs/$1/usage.md"
}

# --- 1. a lane run with an unstaged end line and an untracked file ---------------------------------
new_repo lane
seed_run lane-run 7
git add -A && git commit -qm seed && git checkout -qb claude/lane-run
echo "| lane-run | release | end |" >> .icm/runs/lane-run/usage.md
echo "late note" > .icm/runs/lane-run/notes.md
out="$(.icm/scripts/close-out.sh lane-run 2>&1)"; rc=$?
check "1. close-out reports CLOSED" "[ $rc -eq 0 ] && grep -q 'RESULT: CLOSED' <<<\"\$out\""
check "1. the archived usage.md carries the end line" \
  "git show HEAD:.icm/runs/_done/lane-run/usage.md 2>/dev/null | grep -q 'release | end'"
check "1. an untracked file in the run rides the archive" \
  "git cat-file -e HEAD:.icm/runs/_done/lane-run/notes.md 2>/dev/null"
check "1. the working tree is clean afterwards" "[ -z \"\$(git status --porcelain)\" ]"
check "1. the live run folder is gone" "[ ! -e .icm/runs/lane-run ]"
[ "$fails" -eq 0 ] || printf '%s\n' "$out"

# --- 2. --dry-run stages nothing ------------------------------------------------------------------
new_repo dry
seed_run dry-run 8
git add -A && git commit -qm seed && git checkout -qb claude/dry-run
echo "| dry-run | release | end |" >> .icm/runs/dry-run/usage.md
out="$(.icm/scripts/close-out.sh dry-run --dry-run 2>&1)"; rc=$?
check "2. dry-run reports CLOSED" "[ $rc -eq 0 ] && grep -q 'RESULT: CLOSED' <<<\"\$out\""
check "2. dry-run leaves the index untouched" "git diff --cached --quiet"
check "2. dry-run leaves the append unstaged in place" "! git diff --quiet -- .icm/runs/dry-run/usage.md"

# --- 3. the front behind a finished epic carries its own unstaged append ---------------------------
new_repo front
seed_run ep                       # the front: no `- pr:` line
seed_run ep-stub 9                # the epic's one stub, spun out into this run
mkdir -p .icm/intake/ep/_done
echo "# Stub: ep-stub" > .icm/intake/ep/_done/ep-stub.md
git add -A && git commit -qm seed && git checkout -qb claude/ep-stub
echo "| ep | scope | end |" >> .icm/runs/ep/usage.md
out="$(.icm/scripts/close-out.sh ep-stub 2>&1)"; rc=$?
check "3. close-out reports CLOSED" "[ $rc -eq 0 ] && grep -q 'RESULT: CLOSED' <<<\"\$out\""
check "3. the epic and its front are archived" \
  "git cat-file -e HEAD:.icm/intake/_done/ep/_done/ep-stub.md 2>/dev/null && git cat-file -e HEAD:.icm/runs/_done/ep/run.md 2>/dev/null"
check "3. the front's archived usage.md carries its end line" \
  "git show HEAD:.icm/runs/_done/ep/usage.md 2>/dev/null | grep -q 'scope | end'"
check "3. the working tree is clean afterwards" "[ -z \"\$(git status --porcelain)\" ]"
[ "$fails" -eq 0 ] || printf '%s\n' "$out"

echo
if [ "$fails" -eq 0 ]; then echo "RESULT: PASS"; else echo "RESULT: FAIL $fails"; fi
[ "$fails" -eq 0 ]
