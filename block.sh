#!/bin/bash

set -euo pipefail

cd "$(dirname "$0")"

blockDomains=$(<./blocklist)

for domain in ${blockDomains[@]}; do
  pihole --wild $domain --comment "blocked by cron"
  sleep 1
done
