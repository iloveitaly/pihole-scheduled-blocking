#!/bin/bash
#
# Re-enables Pi-hole blocking using the pihole CLI command.
# This script is useful if blocking is manually disabled for testing
# and you forget to re-enable it. Run via cron to automatically restore
# blocking at a scheduled time (default: midnight).

set -euo pipefail

echo "Running enable-blocking.sh to ensure Pi-hole blocking is enabled"

pihole enable
