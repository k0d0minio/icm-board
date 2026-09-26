#!/usr/bin/env bash
# run-economics.sh — the per-client cost roll-up: what the pipeline spent, against what the deal is worth.
#
# icm-board's own tool, and deliberately so: it reads ACROSS projects/* (agency brief §4.4,
# decision 7), which nothing a repo carries may do. It walks every repo's live `.icm/runs/*/usage.md`
# and archived `<runs_archive>/*/usage.md` (the archive path from each repo's own
# `.icm/project.json`), pairs `start`/`end` lines per stage and session, sums per run and per repo,
# and — where a deal folder names the repo — writes the roll-up into the deal:
#
#   workspaces/deals/<client>/<engagement>/private/economics.md
#
# resolving <client> by the `- repo: <owner/name>` dash-field of each DEAL.md and <engagement> by
# its `- engagement:` field (decision D24: one home per fact — the number lives with the deal's
# private reasoning, never on a public surface, never in a client repo). A repo no DEAL.md names
# is reported as `SKIP <repo>: no deal folder names it`; with `--repo <name>` its table is printed
# instead (a repo can also print its own numbers with `usage-snapshot.sh --report <slug>`, without
# icm-board). Tokens first, list-price USD second (the synced `lib/model-prices.json`'s `as_of`
# date is named); the euro figure is a margin input against the deal's agreed value, never an
# invoice line. `economics` is a reporting kind that maps to no channel by default — nothing is sent.
#
# Read-only except for the one file it writes per deal; `--print` writes nothing at all.
# Human-invoked; never scheduled.
#
# Usage: _system/scripts/run-economics.sh [--deal <client>] [--repo <name>] [--since YYYY-MM-DD] [--print] [root]
#        --repo icm-board reads this checkout's own .icm/runs/ (it is the Apps root, not under projects/).
# Exit:  0 report delivered · 2 bad invocation
# Last line on stdout: RESULT: WRITTEN <n> deal file(s) · SKIP <n> | PRINTED
set -uo pipefail

APPS_ROOT=""; DEAL=""; REPO=""; SINCE=""; PRINT=0
while [ $# -gt 0 ]; do
  case "$1" in
    --deal)  DEAL="${2:-}"; shift 2 ;;
    --repo)  REPO="${2:-}"; shift 2 ;;
    --since) SINCE="${2:-}"; [[ "$SINCE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || { echo "--since wants YYYY-MM-DD" >&2; exit 2; }; shift 2 ;;
    --print) PRINT=1; shift ;;
    -h|--help) sed -n '2,30p' "${BASH_SOURCE[0]}"; exit 0 ;;
    -*) echo "Unknown flag: $1" >&2; exit 2 ;;
    *)  APPS_ROOT="$1"; shift ;;
  esac
done
[[ -n "$APPS_ROOT" ]] || APPS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
[[ -d "$APPS_ROOT/workspaces/deals" ]] || { echo "not the icm-board root: $APPS_ROOT" >&2; exit 2; }
command -v jq >/dev/null 2>&1 || { echo "jq not found" >&2; exit 2; }
PRICES="$APPS_ROOT/_system/template/icm-pipeline/scripts/lib/model-prices.json"
AS_OF="$(jq -r '.as_of // "unknown"' "$PRICES" 2>/dev/null || echo unknown)"
TODAY="$(date -u +%F)"

# --- which repos, and where their runs are --------------------------------------------------------------------

repo_dirs=()
if [[ -n "$REPO" ]]; then
  if [[ "$REPO" == "icm-board" ]]; then repo_dirs+=("$APPS_ROOT"); else [[ -d "$APPS_ROOT/projects/$REPO" ]] || { echo "no projects/$REPO on disk" >&2; exit 2; }; repo_dirs+=("$APPS_ROOT/projects/$REPO"); fi
else
  for d in "$APPS_ROOT"/projects/*/; do [[ -d "$d/.icm" ]] && repo_dirs+=("${d%/}"); done
  [[ -d "$APPS_ROOT/.icm/runs" ]] && repo_dirs+=("$APPS_ROOT")
fi

# usage files for one repo: live runs + the archive its manifest names
usage_files() { # <repo-dir>
  local r="$1" arch=".icm/runs/_done"
  [[ -f "$r/.icm/project.json" ]] && arch="$(jq -r '.runs_archive // ".icm/runs/_done"' "$r/.icm/project.json" 2>/dev/null)"
  find "$r/.icm/runs" -mindepth 2 -maxdepth 2 -name usage.md -not -path "*/_done/*" 2>/dev/null
  [[ -d "$r/${arch%/}" ]] && find "$r/${arch%/}" -mindepth 2 -maxdepth 2 -name usage.md 2>/dev/null
}

# one row per run: repo \t run \t in \t out \t cache_read \t cache_write \t cost(or unknown) \t stages \t open-pairs
roll_repo() { # <repo-dir> <repo-label>
  local r="$1" label="$2" f
  while IFS= read -r f; do
    [[ -n "$f" ]] || continue
    local run; run="$(basename "$(dirname "$f")")"
    awk -v repo="$label" -v run="$run" -v since="$SINCE" '
      /^- usage: / {
        stage=$3; kind=$4; ts=$5; for (i=6;i<=NF;i++) { split($i, kv, "="); v[kv[1]]=kv[2] }
        if (since != "" && substr(ts,1,10) < since) next
        key=stage "|" v["session"]
        if (kind=="start") { s_in[key]=v["in"]; s_out[key]=v["out"]; s_cr[key]=v["cache_read"]; s_cw[key]=v["cache_write"]; s_cost[key]=v["cost_usd"]; seen[key]=1 }
        if (kind=="end")   { e_in[key]=v["in"]; e_out[key]=v["out"]; e_cr[key]=v["cache_read"]; e_cw[key]=v["cache_write"]; e_cost[key]=v["cost_usd"]; seen[key]=1 }
        if (v["cost_usd"]=="unknown" && v["model"]!="") unpriced[v["model"]]=1
      }
      END {
        for (k in seen) {
          if ((k in s_in) && (k in e_in)) { n++; t_in+=e_in[k]-s_in[k]; t_out+=e_out[k]-s_out[k]; t_cr+=e_cr[k]-s_cr[k]; t_cw+=e_cw[k]-s_cw[k];
            if (s_cost[k]=="unknown" || e_cost[k]=="unknown") unk=1; else t_cost+=e_cost[k]-s_cost[k] }
          else open++
        }
        why=""; for (m in unpriced) why=(why=="" ? m : why ", " m)
        if (n+open > 0) printf "%s\t%s\t%d\t%d\t%d\t%d\t%s\t%d\t%d\n", repo, run, t_in, t_out, t_cr, t_cw, (unk ? "unknown (" (why=="" ? "no cost line" : "no price row for " why) ")" : sprintf("%.4f", t_cost)), n, open
      }' "$f"
  done < <(usage_files "$r")
}

render() { # <rows on stdin> → markdown table
  awk -F'\t' '
    BEGIN { printf "| repo | run | in | out | cache read | cache write | list-price USD | stage pairs | open |\n|---|---|---:|---:|---:|---:|---:|---:|---:|\n" }
    { printf "| %s | %s | %d | %d | %d | %d | %s | %d | %d |\n", $1, $2, $3, $4, $5, $6, $7, $8, $9
      in_+=$3; out+=$4; cr+=$5; cw+=$6; if ($7 ~ /^unknown/) unk=1; else cost+=$7; pairs+=$8; open+=$9; rows++ }
    END { if (rows==0) print "| — | no run carries a usage line yet | | | | | unavailable | | |";
          else printf "| **total** | %d run(s) | %d | %d | %d | %d | **%s** | %d | %d |\n", rows, in_, out, cr, cw, (unk ? sprintf("%.4f + unknown", cost) : sprintf("%.4f", cost)), pairs, open }'
}

# --- --repo: print one repo --------------------------------------------------------------------------------

if [[ -n "$REPO" ]]; then
  echo "# Economics — $REPO (prices as of $AS_OF, list price, not a bill; generated $TODAY)"
  echo
  roll_repo "${repo_dirs[0]}" "$REPO" | render
  echo "RESULT: PRINTED"; exit 0
fi

# --- every deal folder that names a repo ---------------------------------------------------------------------

dash() { grep -m1 -E "^- *$2:" "$1" 2>/dev/null | sed -E "s/^- *$2:[[:space:]]*//; s/[[:space:]]+#.*$//; s/[[:space:]]*$//"; }
written=0; skipped=0
declare -A named=()
for deal in "$APPS_ROOT"/workspaces/deals/*/DEAL.md; do
  [[ -f "$deal" ]] || continue
  client="$(basename "$(dirname "$deal")")"
  [[ -z "$DEAL" || "$DEAL" == "$client" ]] || continue
  repo_full="$(dash "$deal" repo)"; engagement="$(dash "$deal" engagement)"
  case "$repo_full" in ""|none*|"—"*|-*) continue ;; esac
  repo_name="${repo_full##*/}"; named["$repo_name"]=1
  [[ -d "$APPS_ROOT/projects/$repo_name" ]] || { echo "SKIP $client: repo $repo_full is not on disk under projects/"; skipped=$((skipped+1)); continue; }
  rows="$(roll_repo "$APPS_ROOT/projects/$repo_name" "$repo_name")"
  if [[ -z "$engagement" || "$engagement" == "none" ]]; then echo "SKIP $client: - engagement: none — no live engagement to write into"; skipped=$((skipped+1)); continue; fi
  target="$APPS_ROOT/workspaces/deals/$client/$engagement/private/economics.md"
  body="$(
    echo "# Economics — $client / $engagement"
    echo
    echo "*Generated $TODAY by \`_system/scripts/run-economics.sh\` from the repo's \`usage.md\` lines (repo \`$repo_full\`).*"
    echo "*Tokens are what the sessions spent; USD is the list price as of $AS_OF from the synced price table — a margin input against the agreed value in \`05-agreement.md\`, never an invoice line. Private: this file never leaves icm-board.*"
    echo
    printf '%s\n' "$rows" | render
    echo
    echo "A stage with a \`start\` and no \`end\` (the *open* column) is still running or was resumed in another session; its cost is not counted until the pair closes."
  )"
  if (( PRINT )); then printf '%s\n' "$body"; echo "(would write ${target#"$APPS_ROOT"/})"
  else mkdir -p "$(dirname "$target")"; printf '%s\n' "$body" > "$target"; echo "wrote ${target#"$APPS_ROOT"/}"; fi
  written=$((written+1))
done
for d in "${repo_dirs[@]}"; do
  n="$(basename "$d")"; [[ "$d" == "$APPS_ROOT" ]] && n="icm-board"
  [[ -n "${named[$n]:-}" ]] || { rows="$(roll_repo "$d" "$n")"; [[ -z "$rows" ]] || echo "SKIP $n: no deal folder names it (its runs carry usage lines — print them with --repo $n)"; skipped=$((skipped+1)); }
done
echo "RESULT: $( (( PRINT )) && echo PRINTED || echo "WRITTEN $written deal file(s)") · SKIP $skipped"
exit 0
