#!/bin/bash

# My goal here is to install the latest version of ScramJet
# and save it in the "ScramJet" folder.

ScramJet="./ScramJet"
Cache="$ScramJet/RevisionCache.json"

mkdir -p "$ScramJet"
if [[ ! -s "$Cache" ]]; then
    echo '{ "installed": -1 }' | jq '.' > "$Cache"
fi
if [[ -f "$Cache" ]]; then
    installedVersion=$(jq -r '.installed // -1' "$Cache" 2>/dev/null)
    if [[ $installedVersion -eq -1 ]]; then
        echo "ScramJet installed, but marked as uninitialized (-1)."
    else
        echo "ScramJet already installed! Version: $installedVersion"
    fi
else
    echo "ScramJet not installed, downloading ..."
    installedVersion=-1
fi
if [[ $installedVersion -eq -1 ]]; then
    echo "Proceeding with fresh install..."
else
    echo "No need to install, already at version $installedVersion."
fi