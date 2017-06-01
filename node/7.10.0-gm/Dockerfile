FROM binded/node:7.10.0

RUN cat /etc/apk/repositories
RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.6/main" \
  >> "/etc/apk/repositories"
RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.6/community" \
  >> "/etc/apk/repositories"

# version = 1.3.25-r1
RUN apk add graphicsmagick \
  --update-cache \
  --allow-untrusted
