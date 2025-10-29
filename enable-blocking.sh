#!/bin/bash

set -euo pipefail

cd "$(dirname "$0")"

echo "Running enable-blocking.sh to ensure Pi-hole blocking is enabled"

# Use the pihole command line tool to enable blocking
# When blocking is disabled manually (e.g., for testing), this will re-enable it
pihole enable
