#!/bin/bash
set -euo pipefail
maxRetries=3
count=0
until [ $count -ge $maxRetries ]; do
    echo "Attempt $((count+1))..."
    if bash -c '
        bash scripts/node.sh &&
        bash scripts/downloader.sh &&
        node source/override.js &&
        cd ScramJet &&
        pnpm install &&
        pnpm run dev
    '; then
        echo "All commands completed successfully."
        exit 0
    else
        echo "Something failed. Retrying..."
        count=$((count+1))
        sleep 2
    fi
done
echo "Failed after $maxRetries attempts."
exit 1
