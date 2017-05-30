FROM ubuntu:17.10

ENV DOCKER_VERSION 17.05.0-ce

RUN apt-get update -y && \
  apt-get install -y \
    zip \
    curl \
    wget \
    git \
    python-pip && \
  rm -rf /var/lib/apt/lists/*

# Install docker
RUN mkdir -p /tmp/docker && \
  cd /tmp/docker && \
  wget https://get.docker.com/builds/Linux/x86_64/docker-${DOCKER_VERSION}.tgz && \
  tar -xzf *.tgz && \
  mv docker/* /usr/local/bin/

# Install aws cli
RUN pip install -U pip && \
  pip install awscli

# Installs terraform, helm, kops and kubectl
RUN curl "https://raw.githubusercontent.com/binded/scripts/master/install-cli-tools.sh" \
  | bash

# Install sentry CLI
RUN curl -sL https://sentry.io/get-cli/ | bash

WORKDIR /ci

COPY ./rootfs /

ENTRYPOINT ["/bin/bash", "-c"]
