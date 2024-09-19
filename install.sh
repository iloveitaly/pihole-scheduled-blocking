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

# filter out all comments and blank lines in the whitelist file
whitelistDomains=$(cat ./allowlist | grep -v '^#' | grep -v '^$')

for domain in ${whitelistDomains[@]}; do
  pihole whitelist $domain --comment "in explicit allowlist"
  sleep 1
done

pihole --wild "*.aws.amazon.com" --comment "allow all aws"

# the /proc redirect ensures that cron job output goes right to stdout
cat <<EOF >/etc/cron.d/scheduled-block
$BLOCK_TIME root PATH="$PATH:/usr/sbin:/usr/local/bin/" /bin/bash /block.sh > /proc/1/fd/1 2>&1
$ALLOW_TIME root PATH="$PATH:/usr/sbin:/usr/local/bin/" /bin/bash /allow.sh > /proc/1/fd/1 2>&1
EOF

# set upstream DNS servers to Quad9 and CF as secondary
# do NOT set ECS since that can expose your IP address to DNS servers (can impact scraping)

# why not use? `pihole -a setdns 9.9.9.9,149.112.112.112,2620:fe::fe,2620:fe::9`
# without this, which DNS server is used is effectively random!
# https://discourse.pi-hole.net/t/fallback-secondary-upstream-dns/33753/3

cat <<EOF >/etc/dnsmasq.d/02-strict.conf
strict-order
server=1.0.0.1
server=2606:4700:4700::1001
server=9.9.9.9
server=2620:fe::fe
EOF
