#!/bin/bash
set -euo pipefail
cd ScramJet/rewriter/wasm
if ! command -v rustc &> /dev/null; then
    echo "Rust not installed. Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi
source "$HOME/.cargo/env"
export PATH="$HOME/.cargo/bin:$PATH"
rustup install nightly
rustup update nightly
rustup default nightly
rustup override set nightly
rustup component add rust-src --toolchain nightly-x86_64-unknown-linux-gnu
Panic="$HOME/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/lib/rustlib/src/rust/library/core/src/panicking.rs"
if [ -f "$Panic" ]; then
    sed -i '/#\[cfg(feature = "panic_immediate_abort")\]/, /);/ s/^/\/\//' "$Panic"
    echo "Patched $Panic"
fi
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
export PATH="$HOME/.local/bin:$PATH"
pnpm install
export RUSTFLAGS='-Zlocation-detail=none -Zfmt-debug=none'
STD_FEATURES="panic_immediate_abort"
cargo build --release --target wasm32-unknown-unknown \
  -Z build-std=panic_abort,std -Z build-std-features=${STD_FEATURES} \
  --no-default-features --features "debug"
bash build.sh
cd ../../
pnpm run build:all
echo "ScramJet Installer complete!"
