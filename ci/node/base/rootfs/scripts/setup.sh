#!/usr/bin/env bash
source /root/.nvm/nvm.sh

nvm install 7
npm install -g yarn

nvm install 8
npm install -g yarn

nvm alias default 8

# Use npm v5
# Workaround: https://github.com/npm/npm/issues/15611#issuecomment-289133810
# mkdir -p /tmp/npm
# cd /tmp/npm
# npm install npm
# rm -rf /usr/local/lib/node_modules
# mv node_modules /usr/local/lib/

echo "Available node version:"
nvm list
echo "Default node version:"
node --version
echo "Default npm version:"
npm --version
echo "Default yarn version:"
yarn --version
