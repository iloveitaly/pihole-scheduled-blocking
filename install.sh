#!/bin/bash

set -euo pipefail

# install nano so we can edit stuff in the container to debug
apt-get update
apt-get install -y --no-install-recommends nano
apt-get clean;

# it's hard to tell how many uniques are across these lists, but it doesn't hurt to include them all
echo "https://blocklistproject.github.io/Lists/porn.txt
https://blocklistproject.github.io/Lists/ads.txt
https://blocklistproject.github.io/Lists/malware.txt
http://sbc.io/hosts/alternates/gambling-porn/hosts" >> /etc/pihole/adlists.list

pihole -b regex '.;querytype=HTTPS' --comment "Block DNS over HTTP"

# required for alexa to work when amazon is blocked
alexa_domains=(
bob-dispatch-prod-na.amazon.com
avs-alexa-14-na.amazon.com
api.amazon.com
api.amazonalexa.com
latinum.amazon.com
)

for domain in ${alexa_domains[@]}; do
  echo $domain
  pihole whitelist $domain --comment "blocked by cron"
  sleep 1
done

# the /proc redirect ensures that cron job output goes right to stdout
cat << EOF > /etc/cron.d/scheduled-block
$BLOCK_TIME root PATH="$PATH:/usr/sbin:/usr/local/bin/" /bin/bash /block.sh > /proc/1/fd/1 2>&1
$ALLOW_TIME root PATH="$PATH:/usr/sbin:/usr/local/bin/" /bin/bash /allow.sh > /proc/1/fd/1 2>&1
EOF