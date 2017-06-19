FROM binded/ci:1.0.0

# Install nvm
RUN	wget -qO- https://raw.github.com/creationix/nvm/master/install.sh | sh
ADD rootfs/ /
RUN /scripts/setup.sh
