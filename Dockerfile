# Usage:
#   docker pull pihole/pihole
#   docker build -t pihole-scheduled-blocker .
#   docker run -it pihole-scheduled-blocker bash
#   docker exec -it pihole bash

FROM pihole/pihole:latest

LABEL maintainer="Michael Bianco <mike@mikebian.co>"
LABEL org.opencontainers.image.source=https://github.com/iloveitaly/pihole-scheduled-blocking

# install nano so we can edit stuff in the container to debug
# patch so we can inject patches to the install and other scripts causing us issues
RUN apk update && \
  apk add --no-cache nano patch

RUN mkdir -p /home/pihole/scheduled-blocking
COPY . /home/pihole/scheduled-blocking/


ENV BLOCK_TIME="0 21 * * *"
ENV ALLOW_TIME="0 8 * * *"

# https://github.com/pi-hole/pi-hole/issues/6357
# Apply patches to modify pihole scripts
RUN patch /usr/bin/start.sh < /home/pihole/scheduled-blocking/patches/start.patch
RUN patch /opt/pihole/list.sh < /home/pihole/scheduled-blocking/patches/list.patch
