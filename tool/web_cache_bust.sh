#!/usr/bin/env bash
# Makes a refresh load a new web deploy: GitHub Pages lets browsers cache files for ~10 minutes and
# main.dart.js keeps its name, so the scripts get a ?v=<build> query that changes with every deploy.
# Usage: tool/web_cache_bust.sh build/web <build number>
set -euo pipefail
dir=$1 build=$2
sed -i "s#src=\"flutter_bootstrap.js\"#src=\"flutter_bootstrap.js?v=$build\"#" "$dir/index.html"
sed -i "s#\"mainJsPath\":\"main.dart.js\"#\"mainJsPath\":\"main.dart.js?v=$build\"#g" "$dir/flutter_bootstrap.js"
grep -q "flutter_bootstrap.js?v=$build" "$dir/index.html"
grep -q "main.dart.js?v=$build" "$dir/flutter_bootstrap.js"
