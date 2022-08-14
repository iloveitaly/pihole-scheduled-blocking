# Usage:
#   docker pull pihole/pihole
#   docker build -t pihole-scheduled-blocker .
#   docker run -it pihole-scheduled-blocker bash
#   docker exec -it pihole bash

FROM pihole/pihole:latest

LABEL maintainer="Michael Bianco <mike@mikebian.co>"

COPY . ./

ENV BLOCK_TIME "0 21 * * *"
ENV ALLOW_TIME "0 7 * * *"

RUN ./install.sh
