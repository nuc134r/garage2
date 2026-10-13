#!/usr/bin/env bash
# Prints the app version for CI builds (needs full git history: checkout with fetch-depth: 0):
#   on a release tag v1.2.0       -> 1.2.0
#   5 commits after it            -> 1.2.0-5-g1a2b3c4   (git describe style; sorts after 1.2.0)
#   no release tagged yet         -> <pubspec version>-<commit count>-g<sha>
set -euo pipefail
if tag=$(git describe --tags --match 'v[0-9]*' 2>/dev/null); then
  echo "${tag#v}"
else
  base=$(grep '^version:' pubspec.yaml | sed -E 's/version: *([^+]+).*/\1/')
  echo "$base-$(git rev-list --count HEAD)-g$(git rev-parse --short=7 HEAD)"
fi
