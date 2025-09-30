#!/bin/bash
set -euo pipefail
Panic="/home/codespace/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/lib/rustlib/src/rust/library/core/src/panicking.rs"
if [ -f "$Panic" ]; then
    sed -i '/#\[cfg(feature = "panic_immediate_abort")\]/, /);/ s/^/\/\//' "$Panic"
    echo "Patched $Panic"
else
    echo "$Panic does not exist, skipping patch"
fi
bash scripts/node.sh
bash scripts/downloader.sh
node source/override.js
cd ScramJet
pnpm install
pnpm run dev
