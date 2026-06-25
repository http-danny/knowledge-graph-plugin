#!/usr/bin/env sh
# Fire a kg trigger for a Claude Code lifecycle event. Fail-safe: never block or fail the session.
command -v kg >/dev/null 2>&1 || exit 0          # kg CLI not installed -> silent no-op
kg triggers fire --event "$1" >/dev/null 2>&1 &  # backgrounded, output swallowed
exit 0
