#!/usr/bin/env bash
# Prints the CHANGELOG.md section for a version (without its heading), for release notes.
# Usage: tool/changelog.sh 2.3.3   — prints nothing if the version has no section.
set -euo pipefail
awk -v v="$1" '
  /^## / { on = ($2 == v); next }
  on
' "$(dirname "$0")/../CHANGELOG.md" | sed -e '/./,$!d' | sed -e ':a' -e '/^\n*$/{$d;N;ba' -e '}'
