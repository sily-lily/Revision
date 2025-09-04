#!/bin/bash

set -euxo pipefail
isWin() {
    case "$OSTYPE" in
        msys*|cygwin*|win32*) return 0 ;;
        *) return 1 ;;
    esac
}

cd ScramJet

if isWin; then
    # powershell -NoProfile -Command "
    #     Set-StrictMode -Version Latest
    #     \$ErrorActionPreference = 'Stop'
    #     \$cargoRoot = Join-Path \$env:USERPROFILE '.cargo'
    #     \$cargoBin = Join-Path \$cargoRoot 'bin'
    #     \$localLib = Join-Path \$cargoRoot 'lib'
    #     Invoke-WebRequest -Uri 'https://win.rustup.rs/x86_64' -OutFile 'rustup-init.exe'
    #     Start-Process -FilePath '.\\rustup-init.exe' -ArgumentList '-y' -NoNewWindow -Wait
    #     Remove-Item '.\\rustup-init.exe' -Force
    #     if (-not (Test-Path \$cargoBin)) { New-Item -ItemType Directory -Path \$cargoBin -Force | Out-Null }
    #     if (-not (Test-Path \$localLib)) { New-Item -ItemType Directory -Path \$localLib -Force | Out-Null }
    #     \$env:Path += ';' + \$cargoBin
    #     pnpm i
    #     rustup install stable
    #     rustup default stable
    #     & rustup run stable cargo install wasm-bindgen-cli --force
    #     \$releaseUrl = 'https://github.com/WebAssembly/binaryen/releases/latest'
    #     \$response = Invoke-WebRequest -Uri \$releaseUrl -MaximumRedirection 0 -ErrorAction SilentlyContinue
    #     \$version = (\$response.Headers.Location -split '/')[-1]
    #     \$archiveName = \"binaryen-\$version-x86_64-windows.tar.gz\"
    #     \$downloadUrl = \"https://github.com/WebAssembly/binaryen/releases/download/\$version/\$archiveName\"
    #     Invoke-WebRequest -Uri \$downloadUrl -OutFile \$archiveName
    #     tar -xvf \$archiveName
    #     Remove-Item \$archiveName -Force
    #     Get-ChildItem \"binaryen-\$version\\bin\" | ForEach-Object {
    #         Copy-Item \$_.FullName \$cargoBin -Force
    #     }
    #     \$libFile = \"binaryen-\$version\\lib\"
    #     if ((Test-Path \$libFile) -and ((Get-Item \$libFile).PSIsContainer -eq \$false)) {
    #         Copy-Item \$libFile \$localLib -Force
    #     }
    #     Remove-Item \"binaryen-\$version\" -Recurse -Force
    #     cargo install --git https://github.com/r58playz/wasm-snip --force
    # "
    echo "Unfortunately, Windows is not yet supported.. To use Revision, use a Linux environment."
else
    curl --proto "=https" --tlsv1.2 --sSf https://sh.rustup.rs | sh
    source "$HOME/.cargo/env"
    pnpm i
    cargo install wasm-bindgen-cli --force
    Version=$(curl --silent -qI https://github.com/WebAssembly/binaryen/releases/latest | awk -F '/' '/^location/ {print substr($NF, 1, length($NF)-1)}')
    curl -LO https://github.com/WebAssembly/binaryen/releases/download/$Version/binaryen-${Version}-x86_64-linux.tar.gz
    tar xvf binaryen-${Version}-x86_64-linux.tar.gz
    rm -rf binaryen-${Version}-x86_64-linux.tar.gz
    mv binaryen-${Version}/bin/* ~/.local/bin
    mv binaryen-${Version}/lib/* ~/.local/lib
    rm -rf binaryen-${Version}
    cargo install --git https://github.com/r58playz/wasm-snip
fi

pnpm rewriter:build
pnpm build
