#!/bin/bash

set -euo pipefail

cd "$(dirname "$0")"

echo "Running block.sh"

blockDomains=$(<./blocklist)

for domain in ${blockDomains[@]}; do
  pihole --wild $domain --comment "blocked by cron"
  sleep 3
done
