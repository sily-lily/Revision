#!/bin/bash
set -euxo pipefail
cd ScramJet
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"
pnpm i
cargo install wasm-bindgen-cli --version 0.2.100 --force
Version=$(curl --silent -qI https://github.com/WebAssembly/binaryen/releases/latest | awk -F '/' '/^location/ {print substr($NF, 1, length($NF)-1)}')
curl -LO https://github.com/WebAssembly/binaryen/releases/download/$Version/binaryen-${Version}-x86_64-linux.tar.gz
tar xvf binaryen-${Version}-x86_64-linux.tar.gz
rm -rf binaryen-${Version}-x86_64-linux.tar.gz
mv binaryen-${Version}/bin/* ~/.local/bin
mv binaryen-${Version}/lib/* ~/.local/lib
rm -rf binaryen-${Version}
cargo install --git https://github.com/r58playz/wasm-snip --force
pnpm rewriter:build
pnpm build
