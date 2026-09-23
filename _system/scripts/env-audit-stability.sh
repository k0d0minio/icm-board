#!/usr/bin/env bash
# env-audit-stability.sh — regression check for the template's `env.sh audit` (and `lib/vercel.sh`).
#
# Found by /setup in sustentus on 2026-09-23: on an unchanged tree `env.sh audit` answered GAPS 52,
# 58 and 43 on consecutive runs. Eight Vercel projects, two unpaced GETs each: Vercel rate-limited
# some, and every project it refused silently lost its rows. setup.sh embeds that line, so
# `setup.sh --report` could never print the same bytes twice.
#
# This builds a throwaway repo from _system/template/icm-pipeline/scripts, points lib/vercel.sh at
# a local mock of the Vercel API (VERCEL_API_URL) that answers 429 to every URL twice before it
# answers it for real (deterministic, so CI never flakes — and every read has to survive the
# retry), pages every list, and keeps one declared project hidden from the token, then asserts:
#   1. `env.sh audit --twice` → the two runs are byte-identical (not RESULT: UNSTABLE);
#   2. the hidden project is ONE [UNKNOWN] row, never a run of missing-key gaps;
#   3. `lib/vercel.sh --check` reads every page and reports the mismatch against deploy.projects[];
#   4. a Vercel that refuses everything yields RESULT: UNKNOWN, with zero gaps;
#   5. no env value the mock serves ever reaches the audit's output.
#
# Needs bash, git, jq, curl, python3 (all on ubuntu-latest). Touches nothing outside a mktemp dir.
# Usage: _system/scripts/env-audit-stability.sh     Exit: 0 pass · 1 a check failed
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPTS="$ROOT/_system/template/icm-pipeline/scripts"
lab="$(mktemp -d)"; pids=()
cleanup() { for p in "${pids[@]}"; do kill "$p" 2>/dev/null; done; rm -rf "$lab"; }
trap cleanup EXIT

fails=0
check() { if eval "$2"; then echo "  ok    $1"; else echo "  FAIL  $1"; fails=$((fails + 1)); fi; }

cat > "$lab/mock.py" <<'PY'
import http.server, json, random, sys, urllib.parse
refusals, port, hide = int(sys.argv[1]), int(sys.argv[2]), len(sys.argv) > 3   # refusals < 0: always 429
seen = {}
projects = [f"p{i}" for i in range(1, 9)]
visible = projects[:-1] if hide else projects
def envs(p):
    e = [{"key": f"K{j}", "type": "sensitive" if j % 2 else "encrypted",
          "target": ["production", "preview"] if j % 3 else ["development", "preview", "production"],
          "value": "MOCK_SECRET_VALUE"} for j in range(int(p[1:]) * 3)]
    random.Random(p).shuffle(e)  # a stable, non-alphabetical order: the audit must sort, not rely on it
    return e
class H(http.server.BaseHTTPRequestHandler):
    def log_message(self, *a): pass
    def send(self, code, obj):
        b = json.dumps(obj).encode(); self.send_response(code)
        self.send_header("content-type", "application/json"); self.end_headers(); self.wfile.write(b)
    def page(self, items, key, size, q):
        start = int(q.get("until", ["0"])[0]); nxt = start + size if start + size < len(items) else None
        return self.send(200, {key: items[start:start + size], "pagination": {"count": size, "next": nxt, "prev": None}})
    def do_GET(self):
        u = urllib.parse.urlparse(self.path); q = urllib.parse.parse_qs(u.query); parts = u.path.strip("/").split("/")
        seen[self.path] = seen.get(self.path, 0) + 1
        if refusals < 0 or seen[self.path] <= refusals: return self.send(429, {"error": {"message": "rate limited"}})
        if parts == ["v9", "projects"]:
            return self.page([{"name": p, "id": "id_" + p} for p in visible], "projects", 3, q)
        if len(parts) >= 3 and parts[:2] == ["v9", "projects"]:
            p = parts[2].replace("id_", "")
            if p not in visible: return self.send(404, {"error": {"message": "not found"}})
            if len(parts) == 4 and parts[3] == "env": return self.page(envs(p), "envs", 10, q)
            return self.send(200, {"name": p, "id": "id_" + p})
        self.send(404, {})
http.server.ThreadingHTTPServer(("127.0.0.1", port), H).serve_forever()
PY

repo="$lab/repo"
mkdir -p "$repo/.icm" && cd "$repo" || exit 1
git init -q
cp -r "$SCRIPTS" .icm/scripts
jq -n '{name: "lab", deploy: {platform: "vercel", team_slug: "t", token_env: "VERCEL_TOKEN",
        projects: [range(1; 9) | {name: "p\(.)", path: "apps/p\(.)"}]}}' > .icm/project.json
for i in $(seq 1 8); do
  mkdir -p "apps/p$i"
  for j in $(seq 0 $((i * 3))); do printf '# note\nK%s=\n\n' "$j" >> "apps/p$i/.env.example"; done
done

port() { python3 -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1",0)); print(s.getsockname()[1])'; }
serve() { python3 "$lab/mock.py" "$@" >/dev/null 2>&1 & pids+=($!); }   # <refusals-per-url> <port> [hide]
wait_up() { for _ in $(seq 1 50); do curl -s -o /dev/null "http://127.0.0.1:$1/" && return 0; sleep 0.1; done; return 1; }
p_flaky="$(port)";  serve 2 "$p_flaky"
p_hidden="$(port)"; serve 2 "$p_hidden" hide
p_down="$(port)";   serve -1 "$p_down"
for p in "$p_flaky" "$p_hidden" "$p_down"; do wait_up "$p" || { echo "mock API did not start"; exit 1; }; done

export VERCEL_TOKEN=lab-not-a-token VERCEL_RETRY_DELAY=0 GH_TOKEN=
audit() { VERCEL_API_URL="http://127.0.0.1:$1" .icm/scripts/env.sh audit "${@:2}"; }

echo "env.sh audit stability (mock Vercel: 8 projects, paged lists, every URL refused 429 twice first)"
out="$(audit "$p_flaky" --twice)"
check "two audits of the same tree are byte-identical" 'grep -q "^RESULT: \(OK\|GAPS\)" <<<"$out" && ! grep -q "RESULT: UNSTABLE" <<<"$out"'
check "…and every project was read (no UNKNOWN under retry)" '! grep -q "UNKNOWN" <<<"$out"'
check "no env value reaches the output" '! grep -q MOCK_SECRET_VALUE <<<"$out"'
[ "$fails" -eq 0 ] || printf '%s\n' "$out" | grep -E '^[-+@]' | head -20

out="$(audit "$p_hidden")"
check "a project the token cannot see is one [UNKNOWN] row" '[ "$(grep -c "\[UNKNOWN\] Vercel/p8" <<<"$out")" = 1 ] && ! grep -q "missing on Vercel/p8" <<<"$out"'
# shellcheck disable=SC2034  # read inside check's eval string
chk="$(VERCEL_API_URL="http://127.0.0.1:$p_hidden" bash .icm/scripts/lib/vercel.sh --check 2>/dev/null)"
check "vercel.sh --check pages every project and names the mismatch" 'grep -q "7 project(s) visible" <<<"$chk" && grep -q "8 declared, 7 visible" <<<"$chk" && grep -q "RESULT: MISMATCH 1" <<<"$chk"'

out="$(VERCEL_RETRIES=2 audit "$p_down")"
check "a Vercel that refuses everything is UNKNOWN, never GAPS" 'grep -q "^RESULT: UNKNOWN 8" <<<"$out"'

echo
if [ "$fails" -eq 0 ]; then echo "RESULT: PASS"; else echo "RESULT: FAIL $fails"; fi
[ "$fails" -eq 0 ]
