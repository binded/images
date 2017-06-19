FROM binded/ci:1.0.0

# used by binded-ui build for image-webpack-loader
RUN wget -q -O /tmp/libpng12.deb http://mirrors.kernel.org/ubuntu/pool/main/libp/libpng/libpng12-0_1.2.54-1ubuntu1_amd64.deb \
  && dpkg -i /tmp/libpng12.deb \
  && rm /tmp/libpng12.deb

# Install nvm
RUN	wget -qO- https://raw.github.com/creationix/nvm/master/install.sh | sh
ADD rootfs/ /
RUN /scripts/setup.sh
