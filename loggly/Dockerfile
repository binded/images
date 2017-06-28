FROM fluent/fluentd-kubernetes-daemonset:v0.12-debian-loggly
COPY ./fluent.conf /fluentd/etc/
ENV LOGGLY_TAGS="fluentd"
