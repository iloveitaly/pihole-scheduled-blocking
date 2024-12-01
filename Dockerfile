# Usage:
#   docker pull pihole/pihole
#   docker build -t pihole-scheduled-blocker .
#   docker run -it pihole-scheduled-blocker bash
#   docker exec -it pihole bash
#   docker builder prune --all

FROM pihole/pihole:latest

LABEL maintainer="Michael Bianco <mike@mikebian.co>"
LABEL org.opencontainers.image.source=https://github.com/iloveitaly/pihole-scheduled-blocking

COPY . ./

ENV BLOCK_TIME="0 21 * * *"
ENV ALLOW_TIME="0 7 * * *"

RUN ./install.sh
