#!/usr/bin/env bash
# render-deal.sh — a deal artefact, markdown → DOCX, under the client's out/ (icm-board).
#
# `04_proposal` and `05_agreement` render their markdown to the DOCX the client receives
# (decision D9, DOCX only since 2026-09-22). pandoc does the conversion; the house look comes
# from `_system/knowledge/house.docx` as pandoc's --reference-doc when Jamie has provided one
# (Q24 in the questionnaire), pandoc's default otherwise. The DOCX lands in
# `workspaces/deals/<client>/out/<artefact>.docx` — gitignored — and goes nowhere from here:
# this script NEVER uploads (the Drive step is the stage's, through the connector, D25) and
# NEVER commits. pandoc is never installed by a script: absent, it reports SKIP with the hint.
#
# Usage: _system/scripts/render-deal.sh <client>/<engagement> <NN-artefact>   (e.g. berceo/berceo-platform 04-proposal)
# Verdict (stdout, last line):
#   RESULT: RENDERED <path>   exit 0
#   RESULT: SKIP (pandoc not found — install it: brew install pandoc | apt install pandoc)   exit 0
#   exit 2 — usage, or the artefact does not exist
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
spec="${1:-}"; art="${2:-}"
[ -n "$spec" ] && [ -n "$art" ] || { echo "usage: render-deal.sh <client>/<engagement> <NN-artefact>" >&2; exit 2; }
client="${spec%%/*}"; eng="${spec#*/}"
[ "$client" != "$eng" ] || { echo "name the engagement too: <client>/<engagement>" >&2; exit 2; }
art="${art%.md}"
src="$ROOT/workspaces/deals/$client/$eng/$art.md"
[ -f "$src" ] || { echo "no such artefact: workspaces/deals/$client/$eng/$art.md" >&2; exit 2; }

if ! command -v pandoc >/dev/null 2>&1; then
  echo "pandoc is not installed — the markdown at workspaces/deals/$client/$eng/$art.md is the deliverable to edit until it is"
  echo "RESULT: SKIP (pandoc not found — install it: brew install pandoc | apt install pandoc)"
  exit 0
fi

out_dir="$ROOT/workspaces/deals/$client/out"; mkdir -p "$out_dir"
out="$out_dir/$art.docx"
args=(--from gfm --to docx --output "$out")
ref="$ROOT/_system/knowledge/house.docx"
if [ -f "$ref" ]; then args+=(--reference-doc "$ref"); echo "reference document: _system/knowledge/house.docx"; else echo "no _system/knowledge/house.docx — pandoc's default look (Q24)"; fi
# The dash-field header is a working header, not part of the document the client reads.
tmp="$(mktemp --suffix=.md)"; trap 'rm -f "$tmp"' EXIT
awk 'NR==1 {print; next} /^- (language|tiers|quote|date|tier|shape|agreed|recurring|signed|drive|proposal|deviation):/ && !body {next} /^## / {body=1} {print}' "$src" > "$tmp"
if pandoc "${args[@]}" "$tmp"; then
  echo "rendered ${out#"$ROOT"/} (gitignored; place it in the client's Drive folder from the stage — never sent from here)"
  echo "RESULT: RENDERED ${out#"$ROOT"/}"
else
  echo "pandoc failed on $art.md — see above" >&2; exit 1
fi
