#!/bin/bash
ScramJet="./ScramJet"
Cache="$ScramJet/RevisionCache.json"
URL="https://raw.githubusercontent.com/MercuryWorkshop/scramjet/refs/heads/main/package.json"
ZipURL="https://github.com/MercuryWorkshop/ScramJet/archive/refs/heads/main.zip"
ZipPath="$ScramJet/Source.zip"
Extracted="$ScramJet/scramjet-main"
mkdir -p "$ScramJet"
if [[ -f "$Cache" ]]; then
    localVersion=$(jq -r '.installed // "-1"' "$Cache" 2>/dev/null)
else
    localVersion="-1"
fi
remoteVersion=$(curl -s "$URL" | jq -r '.version')
cd "$ScramJet"
if [ "$localVersion" != "-1" ] && [ ! -d "node_modules" ]; then
    pnpm i
fi
cd ..
if [[ "$localVersion" != "$remoteVersion" ]]; then
    echo "Version mismatch or uninitialized, reinstalling ScramJet..."
    echo '{ "precheck": { "usingAny": false, "PORT": -1 }, "PORTInfo": {} }' | jq '.' > cache.json
    if [ -d "$ScramJet/.git" ]; then
        cd "$ScramJet"
        git reset --hard
        git pull
    else
        rm -rf "$ScramJet"
        git clone https://github.com/MercuryWorkshop/ScramJet.git "$ScramJet"
    fi
    echo "{ \"installed\": \"$remoteVersion\" }" | jq '.' > "$Cache"
    echo "Cloned ScramJet version $remoteVersion"
    bash scripts/ScramJetInstaller.sh
else
    echo "ScramJet is on the latest version ($localVersion)."
fi
