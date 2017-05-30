FROM ubuntu:17.10

RUN apt-get update -y && \
  apt-get install -y \
    zip \
    curl \
    wget \
    python-pip && \
  rm -rf /var/lib/apt/lists/*

# Install aws cli
RUN pip install -U pip && \
  pip install awscli

# Installs terraform, helm, kops and kubectl
RUN curl "https://raw.githubusercontent.com/binded/scripts/master/install-cli-tools.sh" \
  | bash
