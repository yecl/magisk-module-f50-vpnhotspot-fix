#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="dist"
OUT_ZIP="$OUT_DIR/vpn-tun0-rule-fix.zip"

rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR"

zip -r "$OUT_ZIP" \
  module.prop \
  service.sh \
  customize.sh \
  META-INF \
  README.md \
  -x '*.DS_Store'

echo "Built $OUT_ZIP"
