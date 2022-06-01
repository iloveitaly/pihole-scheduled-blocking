#!/bin/bash

set -euo pipefail

cd "$(dirname "$0")"

blockDomains=$(<./blocklist)

for domain in ${blockDomains[@]}; do
  pihole --wild -d $domain
  sleep 1
done
