# Usage:
#   docker pull pihole/pihole
#   docker build -t pihole-scheduled-blocker .
#   docker run -it pihole-scheduled-blocker bash
#   docker exec -it pihole bash

FROM pihole/pihole:latest

LABEL maintainer="Michael Bianco <mike@mikebian.co>"
LABEL org.opencontainers.image.source=https://github.com/iloveitaly/pihole-scheduled-blocking

# install nano so we can edit stuff in the container to debug
RUN apk update && \
  apk add --no-cache nano

COPY . ./

RUN ./inject.sh "./install.sh"
RUN rm inject.sh

ENV BLOCK_TIME="0 21 * * *"
ENV ALLOW_TIME="0 8 * * *"