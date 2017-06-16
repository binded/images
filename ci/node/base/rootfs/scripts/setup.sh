#!/usr/bin/env bash
source /root/.nvm/nvm.sh
nvm install 7
nvm install 8
nvm alias default 8
npm install -g npm
echo "Available node version:"
nvm list
echo "Default node version:"
node --version
echo "Default npm version:"
npm --version
