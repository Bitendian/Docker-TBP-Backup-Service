FROM debian:stable-slim AS base

RUN \
apt-get -y --fix-missing update && \
apt-get -y --fix-missing upgrade && \
apt-get -y --fix-missing --no-install-recommends install \
mariadb-client \
bzip2



FROM base AS development



FROM base AS release
RUN mkdir -p /root/bin/
COPY create.sh /root/bin/
COPY restore.sh /root/bin/
