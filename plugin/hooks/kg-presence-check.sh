#!/usr/bin/env sh
# Missing-CLI nudge (SessionStart). Fail-safe: never blocks/fails a session — always exits 0.
#
# Stays SILENT unless this is a kg project (a kg.config.json at/above the session cwd) AND the
# `kg` CLI is NOT on PATH. In that case it tells the AGENT every session (additionalContext) that
# auto-ingestion is off, and shows the USER a banner (systemMessage) throttled to once per 7 days
# via a home-dir sentinel. POSIX-sh only (no bashisms, no jq — static heredocs).
#
# Spec: docs/superpowers/specs/2026-06-16-publish-cli-and-missing-cli-nudge-design.md §3.

# --- 1. Scope guard: only inside a kg project (kg.config.json at/above start dir) ----------------
# Start dir = $CLAUDE_PROJECT_DIR if set, else $PWD. Walk up to / looking for kg.config.json.
dir=${CLAUDE_PROJECT_DIR:-$PWD}
found=0
while :; do
  if [ -e "$dir/kg.config.json" ]; then
    found=1
    break
  fi
  parent=$(dirname "$dir" 2>/dev/null) || break
  [ "$parent" = "$dir" ] && break   # reached filesystem root
  dir=$parent
done
[ "$found" = 1 ] || exit 0          # not a kg project -> silent

# --- 2. If kg is on PATH, auto-ingestion works -> nothing to nudge ------------------------------
command -v kg >/dev/null 2>&1 && exit 0

# --- 3. kg project + kg absent: emit the agent context always; the user banner is throttled ------
sentinel="${HOME}/.knowledge-graph/state/.cli-nudge-shown"

# Throttle is OPEN iff the sentinel is ABSENT (first run — tested first so a naive `find` can't
# suppress the first-run nudge) OR older than ≈7–8 days (find rounds -mtime to whole days). find
# -mtime +7 is POSIX (no GNU stat).
if [ ! -e "$sentinel" ] || [ -n "$(find "$sentinel" -mtime +7 2>/dev/null)" ]; then
  # Best-effort record that we showed the banner. Failure (e.g. HOME unset, dir unwritable, or a
  # stale read-only sentinel) must NOT escape and must NOT suppress the banner — fail toward
  # informing. Use an EXTERNAL `touch` (not the special builtin `:` with a `>` redirect, whose
  # open-failure aborts non-interactive sh/dash); `2>/dev/null || true` makes this line always 0.
  mkdir -p "$(dirname "$sentinel")" 2>/dev/null
  touch "$sentinel" 2>/dev/null || true
  cat <<'JSON'
{
  "systemMessage": "knowledge-graph: the kg CLI isn't on your PATH, so auto-ingestion is OFF and the graph won't update as you work. The CLI is a private package — set up access once (a read:packages token + .npmrc), then install. Setup: docs/runbooks/publish-mcp.md §7.3. Once authed: npm i -g @http-danny/kg-cli",
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "The knowledge-graph kg CLI is not installed on PATH, so its auto-ingestion hooks are no-ops and the graph is not being refreshed this session. kg_search / kg_code_* results may be stale relative to disk. The CLI is a private GitHub Packages package: installing it requires a one-time .npmrc + read:packages token (see docs/runbooks/publish-mcp.md §7.3), then npm i -g @http-danny/kg-cli and kg ingest. If retrieval looks out of date, point the user to that access setup rather than a bare install command."
  }
}
JSON
else
  # Throttle closed: inform the agent only, no user-facing banner, sentinel untouched.
  cat <<'JSON'
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "The knowledge-graph kg CLI is not installed on PATH, so its auto-ingestion hooks are no-ops and the graph is not being refreshed this session. kg_search / kg_code_* results may be stale relative to disk. The CLI is a private GitHub Packages package: installing it requires a one-time .npmrc + read:packages token (see docs/runbooks/publish-mcp.md §7.3), then npm i -g @http-danny/kg-cli and kg ingest. If retrieval looks out of date, point the user to that access setup rather than a bare install command."
  }
}
JSON
fi

exit 0
