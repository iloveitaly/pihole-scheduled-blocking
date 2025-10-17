#!/usr/bin/env bash

set -euo pipefail

echo "######### Starting Scheduled Blocking Install #########"

# Install gronx for cron management
cd /home/pihole/scheduled-blocking
bash ./install-gronx.sh

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
for blocklist in "${blocklists[@]}"; do
  pihole-FTL sqlite3 /etc/pihole/gravity.db \
    "INSERT OR IGNORE INTO adlist (address, enabled) VALUES ('$blocklist', 1);"
done

cd /home/pihole/scheduled-blocking

# filter out all comments and blank lines in the whitelist file
whitelistDomains=$(cat ./allowlist | grep -v '^#' | grep -v '^$')

for domain in ${whitelistDomains}; do
  pihole allow $domain --comment "from explicit allowlist"
  sleep 1
done

pihole allow --wild "*.aws.amazon.com" --comment "allow all aws"

# Pi-hole's cron daemon supports reading from /etc/cron.d
# the /proc redirect ensures that cron job output goes right to stdout
mkdir -p /etc/cron.d
cat <<EOF >/etc/cron.d/scheduled-block
$BLOCK_TIME /home/pihole/scheduled-blocking/block.sh
$ALLOW_TIME /home/pihole/scheduled-blocking/allow.sh
EOF

# set upstream DNS servers to Quad9 and CF as secondary
# do NOT set ECS since that can expose your IP address to DNS servers (can impact scraping and reduce privacy)

# first, we need to remove DNS settings completely from pi-hole config
pihole -a setdns "" ""

# why not use? `pihole -a setdns 9.9.9.9,149.112.112.112,2620:fe::fe,2620:fe::9`
# without this, which DNS server is used is effectively random!
# https://discourse.pi-hole.net/t/fallback-secondary-upstream-dns/33753/3

# the order of the file below used to be reversed, but it looks like it properly respects the top-to-bottom ordering now

mkdir -p /etc/dnsmasq.d
cat <<EOF >/etc/dnsmasq.d/02-strict.conf
strict-order
server=2620:fe::fe
server=9.9.9.9
server=2606:4700:4700::1001
server=1.0.0.1
EOF

# update all lists
pihole -g

nohup /usr/local/bin/gronx -file /etc/cron.d/scheduled-block &

echo "######### Scheduled Blocking Install Complete #########"