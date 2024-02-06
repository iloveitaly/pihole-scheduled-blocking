#!/bin/bash

set -euo pipefail

# install nano so we can edit stuff in the container to debug
apt-get update
apt-get install -y --no-install-recommends nano
apt-get clean

# https://github.com/blocklistproject/Lists
# it's hard to tell how many uniques are across these lists, but it doesn't hurt to include them all
blocklists=(
https://blocklistproject.github.io/Lists/porn.txt
https://blocklistproject.github.io/Lists/ads.txt
https://blocklistproject.github.io/Lists/malware.txt
https://blocklistproject.github.io/Lists/tiktok.txt
https://blocklistproject.github.io/Lists/tracking.txt
http://sbc.io/hosts/alternates/gambling-porn/hosts
)

# /etc/pihole/adlists.list isn't used anymore: https://discourse.pi-hole.net/t/adding-blocklist-urls-to-the-gravity-db-from-the-command-line/49694
# we need to insert additional blocklists directly into the DB
for blocklist in ${blocklists[@]}; do
  sudo sqlite3 /etc/pihole/gravity.db \
    "INSERT INTO adlist (address, enabled) VALUES ('$blocklist', 1);"
done

# blocking DNS over HTTP allows DNS-based blocking to be effective on the network
pihole -b regex '.;querytype=HTTPS' --comment "Block DNS over HTTP"

# filter out all comments and blank lines in the whitelist file
whitelistDomains=$(cat ./allowlist | grep -v '^#' | grep -v '^$')

for domain in ${whitelistDomains[@]}; do
  pihole whitelist $domain --comment "in explicit allowlist"
  sleep 1
done

pihole --wild "*.aws.amazon.com" --comment "allow all aws"

# the /proc redirect ensures that cron job output goes right to stdout
cat << EOF > /etc/cron.d/scheduled-block
$BLOCK_TIME root PATH="$PATH:/usr/sbin:/usr/local/bin/" /bin/bash /block.sh > /proc/1/fd/1 2>&1
$ALLOW_TIME root PATH="$PATH:/usr/sbin:/usr/local/bin/" /bin/bash /allow.sh > /proc/1/fd/1 2>&1
EOF