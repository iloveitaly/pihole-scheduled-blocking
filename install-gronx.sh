#!/usr/bin/env bash

set -euo pipefail

echo "Installing tasker (gronx) via official install script..."

# The official installer needs curl and tar; jq is no longer required
apk add --no-cache curl tar gzip

# --yes is required since this runs non-interactively at container start
curl -sS https://raw.githubusercontent.com/adhocore/gronx/refs/heads/main/install.sh | sh -s -- --yes --bin-dir /usr/local/bin

echo "Tasker installed successfully"
# Verify the binary works
/usr/local/bin/tasker -v
