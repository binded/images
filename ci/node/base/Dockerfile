FROM binded/ci:1.0.0

# used by binded-ui build
RUN apt-get update -y && \
  apt-get install -y \
    libpng-dev \
  && rm -rf /var/lib/apt/lists/*

# Install nvm
RUN	wget -qO- https://raw.github.com/creationix/nvm/master/install.sh | sh
ADD rootfs/ /
RUN /scripts/setup.sh
