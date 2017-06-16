FROM binded/ci:1.0.0

# Install nvm
RUN	wget -qO- https://raw.github.com/creationix/nvm/master/install.sh | sh
ADD rootfs/ /
RUN ["/bin/bash", "-c", "/scripts/setup.sh"]
