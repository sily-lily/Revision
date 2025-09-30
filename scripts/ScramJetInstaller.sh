#!/bin/bash
set -euo pipefail
cd ScramJet
if ! command -v rustc &> /dev/null; then
  echo "Rust not installed. Installing Rust..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env"
fi
rustup install nightly
rustup update nightly
rustup default nightly
rustup override set nightly
rustc --version
unset RUSTFLAGS
cargo install wasm-bindgen-cli --version 0.2.100 --force
cargo install --git https://github.com/r58playz/wasm-snip --force
Version=$(curl -sI https://github.com/WebAssembly/binaryen/releases/latest \
  | awk -F '/' 'tolower($1) ~ /^location/ {print substr($NF, 1, length($NF)-1)}')
curl -LO "https://github.com/WebAssembly/binaryen/releases/download/$Version/binaryen-${Version}-x86_64-linux.tar.gz"
tar xvf "binaryen-${Version}-x86_64-linux.tar.gz"
rm -f "binaryen-${Version}-x86_64-linux.tar.gz"
mkdir -p ~/.local/bin ~/.local/lib
mv "binaryen-${Version}/bin/"* ~/.local/bin/
mv "binaryen-${Version}/lib/"* ~/.local/lib/
rm -rf "binaryen-${Version}"
pnpm i
export RUSTFLAGS='-Zlocation-detail=none -Zfmt-debug=none'
STD_FEATURES="panic_immediate_abort"
cargo build --release --target wasm32-unknown-unknown \
  -Z build-std=panic_abort,std -Z build-std-features=${STD_FEATURES} \
  --no-default-features --features "debug"
pnpm rewriter:build
pnpm build:all
echo "ScramJet Installer complete!"
