#!/usr/bin/env bash
# deploy-status-superseded.sh — regression check for the template's `deploy-status.sh` SUPERSEDED read.
#
# Found by sustentus (merge fd9e290, PR 1168; fcf6580 the same way), 2026-09-25: Vercel canceled a
# queued production build when the next `main` commit landed — CANCELED, no errorCode, no
# errorMessage — and Release step 9(a) read `RESULT: ERROR demo marketing` and pointed at the hotfix
# lane while production served the descendant 5710a2e, READY. A cancel that a READY deployment of a
# descendant commit carries is SUPERSEDED, counted as READY; only a cancel with no descendant
# deployment at all stays ERROR.
#
# Builds a throwaway origin (B → M → C → G on main, S on a side branch off B) and a clone of it
# holding the template scripts at .icm/scripts with two deploy projects, points lib/vercel.sh at a
# local mock of the Vercel API (VERCEL_API_URL) serving each case's deployments, reads M, asserts:
#   1. M CANCELED (no errorMessage), C READY → `- production: READY on M — demo superseded by C
#      · marketing superseded by C`, RESULT: READY, exit 0 (the request's fixture);
#   2. M CANCELED, nothing newer (a person's cancel) → ERROR, exit 3;
#   3. C still BUILDING → PENDING, exit 4 (the read waits on it within the bound);
#   4. C READY, newest G ERROR → READY via C (production serves a descendant that carries M);
#   5. C the only descendant, ERROR → ERROR, exit 3;
#   6. a newer READY on a non-descendant → ERROR, exit 3;
#   7. an Ignored Build Step cancel → SKIP, exit 0 (unchanged);
#   8. the clone does not know C and C's deployment names no branch → one `git fetch` of the
#      branch, then ancestry → READY;
#   9. the clone does not know C and cannot fetch → the same-branch fallback → READY.
#
# Needs bash, git, jq, curl, python3 (all on ubuntu-latest). Touches nothing outside a mktemp dir.
# Usage: _system/scripts/deploy-status-superseded.sh     Exit: 0 pass · 1 a check failed
# shellcheck disable=SC2034  # out, rc, m7, c7 are read inside check()'s eval strings
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPTS="$ROOT/_system/template/icm-pipeline/scripts"
lab="$(mktemp -d)"; pids=()
cleanup() { for p in "${pids[@]}"; do kill "$p" 2>/dev/null; done; rm -rf "$lab"; }
trap cleanup EXIT

fails=0
check() { if eval "$2"; then echo "  ok    $1"; else echo "  FAIL  $1"; fails=$((fails + 1)); fi; }

# --- a mock Vercel API: a project's id by name; /v6/deployments filtered as Vercel does -------------
cat > "$lab/mock.py" <<'PY'
import http.server, json, os, sys
from urllib.parse import urlparse, parse_qs
DB = os.environ["LAB_DB"]
class H(http.server.BaseHTTPRequestHandler):
    def log_message(self, *a): pass
    def do_GET(self):
        u = urlparse(self.path); q = parse_qs(u.query); code, obj = 200, None
        if u.path.startswith("/v9/projects/"):
            obj = {"id": "prj_" + u.path.split("/")[3]}
        elif u.path == "/v6/deployments":
            deps = [d for d in json.load(open(DB)) if "prj_" + d["project"] == q["projectId"][0]]
            if "target" in q: deps = [d for d in deps if d.get("target") == q["target"][0]]
            if "sha" in q: deps = [d for d in deps if d["meta"].get("githubCommitSha") == q["sha"][0]]
            deps.sort(key=lambda d: -d["created"])
            obj = {"deployments": deps[: int(q.get("limit", ["20"])[0])], "pagination": {"next": None}}
        else:
            code, obj = 404, {}
        b = json.dumps(obj).encode(); self.send_response(code)
        self.send_header("content-type", "application/json"); self.end_headers(); self.wfile.write(b)
http.server.ThreadingHTTPServer(("127.0.0.1", int(sys.argv[1])), H).serve_forever()
PY
export LAB_DB="$lab/deployments.json"
port="$(python3 -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1",0)); print(s.getsockname()[1])')"
python3 "$lab/mock.py" "$port" >/dev/null 2>&1 & pids+=($!)
for _ in $(seq 1 50); do curl -s -o /dev/null "http://127.0.0.1:$port/" && break; sleep 0.1; done
curl -s -o /dev/null "http://127.0.0.1:$port/" || { echo "mock API did not start"; exit 1; }

export VERCEL_API_URL="http://127.0.0.1:$port" VERCEL_TOKEN=lab-not-a-token VERCEL_RETRIES=1

# --- the history: origin B → M → C → G on main, S off B; the pipeline repo is a clone of it ---------
git_() { git -c user.email=test@example.com -c user.name=Test "$@"; }
git_ init -q -b main "$lab/origin"
for c in B M C G; do echo "$c" > "$lab/origin/f"; git_ -C "$lab/origin" add f; git_ -C "$lab/origin" commit -qm "$c"; done
git_ -C "$lab/origin" checkout -q -b side main~3
echo S > "$lab/origin/s"; git_ -C "$lab/origin" add s; git_ -C "$lab/origin" commit -qm S
git_ -C "$lab/origin" checkout -q main
B="$(git -C "$lab/origin" rev-parse main~3)"; M="$(git -C "$lab/origin" rev-parse main~2)"
C="$(git -C "$lab/origin" rev-parse main~1)"; G="$(git -C "$lab/origin" rev-parse main)"
S="$(git -C "$lab/origin" rev-parse side)"
repo="$lab/repo"
git clone -q "$lab/origin" "$repo"; git -C "$repo" fetch -q origin side:side
mkdir -p "$repo/.icm"; cp -r "$SCRIPTS" "$repo/.icm/scripts"
echo '{"name":"lab","deploy":{"platform":"vercel","projects":[{"name":"demo","class":"product"},{"name":"marketing","class":"quiet"}]}}' > "$repo/.icm/project.json"
# Forget everything after M, as a Release clone that has not fetched the later merges.
forget_after_m() {
  git -C "$repo" reset -q --hard "$M"
  git -C "$repo" update-ref -d refs/remotes/origin/main 2>/dev/null
  git -C "$repo" reflog expire --expire=now --all; git -C "$repo" gc -q --prune=now
}

# One deployment per project: <id> <sha> <state> <created> [<branch> ('' = none)] [<errorMessage>]
dpl() {
  local p
  for p in demo marketing; do
    jq -nc --arg p "$p" --arg id "$1" --arg s "$2" --arg st "$3" --argjson c "$4" --arg r "${5-main}" --arg e "${6-}" \
      '{project: $p, uid: $id, url: ($id + ".vercel.app"), target: "production", state: $st, created: $c,
        meta: ({githubCommitSha: $s} + (if $r == "" then {} else {githubCommitRef: $r} end))}
       + (if $e == "" then {} else {errorMessage: $e} end)'
  done
}
out=""; rc=0
read_m() { # <deployment json lines…> → $out, $rc
  printf '%s\n' "$@" | jq -s . > "$LAB_DB"
  out="$("$repo/.icm/scripts/deploy-status.sh" --sha "$M" --no-wait 2>/dev/null)"; rc=$?
}
prev="$(dpl dpl_prev "$B" READY 100)"; canceled="$(dpl dpl_m "$M" CANCELED 200)"
m7="${M:0:7}"; c7="${C:0:7}"

echo "1. merge canceled by a newer main commit, child READY → READY"
read_m "$prev" "$canceled" "$(dpl dpl_c "$C" READY 300)"
check "record line names the descendant"  '[ "$(grep "^- production:" <<< "$out")" = "- production: READY on $m7 — demo superseded by $c7 · marketing superseded by $c7" ]'
check "project line in the SUPERSEDED form" 'grep -qxF "demo (product): SUPERSEDED — canceled dpl_m · live dpl_c on $c7 (carries $m7) — https://dpl_c.vercel.app" <<< "$out"'
check "RESULT: READY, exit 0"              '[ "$(tail -n1 <<< "$out")" = "RESULT: READY" ] && [ "$rc" -eq 0 ]'

echo "2. a person's cancel, nothing newer → ERROR"
read_m "$prev" "$canceled"
check "RESULT: ERROR demo marketing, exit 3" '[ "$(tail -n1 <<< "$out")" = "RESULT: ERROR demo marketing" ] && [ "$rc" -eq 3 ]'

echo "3. the descendant still building → PENDING"
read_m "$prev" "$canceled" "$(dpl dpl_c "$C" BUILDING 300)"
check "record names it unsettled"  'grep -qF "demo superseded by $c7 BUILDING" <<< "$out"'
check "RESULT: PENDING, exit 4"    '[ "$(tail -n1 <<< "$out")" = "RESULT: PENDING" ] && [ "$rc" -eq 4 ]'

echo "4. a READY descendant beats a newer failed one"
read_m "$prev" "$canceled" "$(dpl dpl_c "$C" READY 300)" "$(dpl dpl_g "$G" ERROR 400)"
check "live on C, RESULT: READY"   'grep -qF "live dpl_c on $c7" <<< "$out" && [ "$(tail -n1 <<< "$out")" = "RESULT: READY" ] && [ "$rc" -eq 0 ]'

echo "5. the only descendant failed → ERROR"
read_m "$prev" "$canceled" "$(dpl dpl_c "$C" ERROR 300)"
check "RESULT: ERROR, exit 3"      '[ "$(tail -n1 <<< "$out")" = "RESULT: ERROR demo marketing" ] && [ "$rc" -eq 3 ]'

echo "6. a newer READY that is not a descendant → ERROR"
read_m "$prev" "$canceled" "$(dpl dpl_s "$S" READY 300 side)"
check "RESULT: ERROR, exit 3"      '[ "$(tail -n1 <<< "$out")" = "RESULT: ERROR demo marketing" ] && [ "$rc" -eq 3 ]'

echo "7. an Ignored Build Step cancel → SKIP"
read_m "$prev" "$(dpl dpl_m "$M" CANCELED 200 main 'canceled as a result of running the command defined in the "Ignored Build Step" setting.')"
check "RESULT: SKIP, exit 0"       '[ "$(tail -n1 <<< "$out")" = "RESULT: SKIP" ] && [ "$rc" -eq 0 ]'

echo "8. the clone does not know C, its deployment names no branch → fetch, then ancestry"
forget_after_m
check "the clone does not know C"  '! git -C "$repo" cat-file -e "$C^{commit}" 2>/dev/null'
read_m "$prev" "$canceled" "$(dpl dpl_c "$C" READY 300 '')"
check "RESULT: READY after the fetch" '[ "$(tail -n1 <<< "$out")" = "RESULT: READY" ] && [ "$rc" -eq 0 ]'

echo "9. the clone does not know C and cannot fetch → same-branch fallback"
forget_after_m; git -C "$repo" remote remove origin
read_m "$prev" "$canceled" "$(dpl dpl_c "$C" READY 300)"
check "RESULT: READY by githubCommitRef" '[ "$(tail -n1 <<< "$out")" = "RESULT: READY" ] && [ "$rc" -eq 0 ]'

echo
if [ "$fails" -eq 0 ]; then echo "RESULT: PASS"; exit 0; fi
echo "RESULT: FAIL $fails"; exit 1
