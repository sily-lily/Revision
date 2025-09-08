#!/bin/bash
# This script is intended to fix the version issue with Node.js.
# Apparently, GitHub Codespaces (from what I can tell) comes installed with an older
# version of Node.js, so let's just reinstall it!
#
# Requirements:
# ~ NVM (Node Version Manager, installed with Node.js)

set -e
if [ ! -d "$HOME/.nvm" ] && [ ! -d "/usr/local/share/nvm" ]; then
  echo "NVM not found. Installing..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
fi
if [ -d "$HOME/.nvm" ]; then
  export NVM_DIR="$HOME/.nvm"
elif [ -d "/usr/local/share/nvm" ]; then
  export NVM_DIR="/usr/local/share/nvm"
fi
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
nvm install node
nvm use node
echo "Installed the latest version of Node.js (Non-LTS)"
npm install -g pnpm
echo "Installed PNPM globally"