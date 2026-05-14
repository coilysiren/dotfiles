#!/usr/bin/env bash
# Run a command and emit chat-safe output:
# - wrapped in a fenced code block
# - max 20 lines, with ... appended if clipped
# - max 100 chars per line (char-correct via awk substr)
# Used by the `$$ <cmd>` chat convention so mobile sees output without
# blowing the context window on huge dumps.
set -o pipefail
echo '```'
"$@" 2>&1 | awk '
  NR<=20 { print substr($0,1,100) }
  NR==21 { print "..."; exit }
'
echo '```'
