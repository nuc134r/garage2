#!/usr/bin/env bash
# Renders the README screenshots into docs/screenshots (see test/screenshots_test.dart).
set -euo pipefail
cd "$(dirname "$0")/.."
flutter=$(command -v fvm >/dev/null && echo "fvm flutter" || echo flutter)
$flutter test --dart-define=SCREENSHOTS=true test/screenshots_test.dart
