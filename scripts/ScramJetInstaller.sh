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
    powershell -NoProfile -Command "
        \$ErrorActionPreference = 'Stop'
        if (-not (Get-Command rustup -ErrorAction SilentlyContinue)) {
            Invoke-WebRequest -Uri 'https://win.rustup.rs/x86_64' -OutFile 'rustup-init.exe'
            Start-Process -FilePath '.\\rustup-init.exe' -ArgumentList '-y' -NoNewWindow -Wait
            Remove-Item '.\\rustup-init.exe' -Force
        }
        rustup toolchain install nightly-x86_64-pc-windows-gnu
        rustup target add wasm32-unknown-unknown --toolchain nightly-x86_64-pc-windows-gnu
        & rustup run nightly-x86_64-pc-windows-gnu cargo install wasm-bindgen-cli --force
        \$releaseUrl = 'https://github.com/WebAssembly/binaryen/releases/latest'
        \$response = Invoke-WebRequest -Uri \$releaseUrl -MaximumRedirection 0 -ErrorAction SilentlyContinue
        \$version = (\$response.Headers.Location -split '/')[-1]
        \$archiveName = \"binaryen-\$version-x86_64-windows.tar.gz\"
        \$downloadUrl = \"https://github.com/WebAssembly/binaryen/releases/download/\$version/\$archiveName\"
        Invoke-WebRequest -Uri \$downloadUrl -OutFile \$archiveName
        tar -xvf \$archiveName
        Remove-Item \$archiveName -Force
        Copy-Item \"binaryen-\$version\\bin\\*\" \$env:USERPROFILE\\.cargo\\bin -Force
        Remove-Item \"binaryen-\$version\" -Recurse -Force
        & rustup run nightly-x86_64-pc-windows-gnu cargo install --git https://github.com/r58playz/wasm-snip --force
    "
    pnpm i
    rustup run nightly-x86_64-pc-windows-gnu bash ./rewriter/wasm/build.sh
    pnpm build
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
    pnpm rewriter:build
    pnpm build
fi
