# vim:set ft=dockerfile:
FROM node:7.10.0

RUN apt-get update -y && \
  apt-get install -y zip && \
  rm -rf /var/lib/apt/lists/*

# Use npm v5
RUN npm install -g npm@5

# Install yarn
RUN curl -o- -L https://yarnpkg.com/install.sh | bash

# Installs terraform, helm, kops and kubectl
RUN curl "https://raw.githubusercontent.com/binded/scripts/master/install-cli-tools.sh" \
  | bash

