#!/bin/bash

ScramJet="./ScramJet"
Cache="$ScramJet/RevisionCache.json"
URL="https://raw.githubusercontent.com/MercuryWorkshop/scramjet/refs/heads/main/package.json"
ZipURL="https://github.com/MercuryWorkshop/ScramJet/archive/refs/heads/main.zip"
ZipPath="$ScramJet/Source.zip"
Extracted="$ScramJet/scramjet-main"

isWin() {
    case "$OSTYPE" in
        msys*|cygwin*|win32*) return 0 ;;
        *) return 1 ;;
    esac
}

mkdir -p "$ScramJet"
if [[ -f "$Cache" ]]; then
    if isWin; then
        localVersion=$(powershell -NoProfile -Command "(Get-Content '$Cache' | ConvertFrom-Json).installed")
    else
        localVersion=$(jq -r '.installed // "-1"' "$Cache" 2>/dev/null)
    fi
else
    localVersion="-1"
fi
if isWin; then
    remoteVersion=$(powershell -NoProfile -Command "(Invoke-WebRequest -Uri '$URL' -UseBasicParsing).Content | ConvertFrom-Json | Select-Object -ExpandProperty version")
else
    remoteVersion=$(curl -s "$URL" | jq -r '.version')
fi
if [[ "$localVersion" != "$remoteVersion" ]]; then
    echo "Version mismatch or uninitialized, reinstalling ScramJet..."
    if isWin; then
        powershell -NoProfile -Command "
            Set-StrictMode -Version Latest
            \$ScramJet = '$ScramJet'
            if (Test-Path $ScramJet) {
                if (Test-Path (Join-Path $ScramJet '.git')) {
                    cd $ScramJet
                    git reset --hard
                    git pull
                } else {
                    Remove-Item $ScramJet -Recurse -Force
                    git clone https://github.com/MercuryWorkshop/ScramJet.git $ScramJet
                }
            } else {
                git clone https://github.com/MercuryWorkshop/ScramJet.git $ScramJet
            }
            [PSCustomObject]@{ installed = '$remoteVersion' } | ConvertTo-Json | Set-Content -LiteralPath (Join-Path \$ScramJet 'RevisionCache.json') -Force
        "
        echo "Cloned ScramJet version $remoteVersion"
    else
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
    fi
else
    echo "ScramJet is on the latest version ($localVersion)."
fi
