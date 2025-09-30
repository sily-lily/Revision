#!/bin/bash
set -euo pipefail
bash scripts/node.sh
bash scripts/downloader.sh
node source/override.js
cd ScramJet
pnpm install
pnpm run dev
