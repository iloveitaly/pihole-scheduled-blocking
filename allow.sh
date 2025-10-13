#!/bin/bash

set -euo pipefail

cd "$(dirname "$0")"

echo "Running allow.sh"

blockDomains=$(<./blocklist)

for domain in ${blockDomains[@]}; do
  pihole --wild -d $domain
  sleep 1
done
