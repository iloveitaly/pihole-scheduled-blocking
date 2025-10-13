#!/usr/bin/env bash

set -euo pipefail

echo "Installing gronx..."

# Ensure we have necessary tools for tar and JSON parsing
apk add --no-cache tar gzip jq

# Get the correct download URL from GitHub API
# Note: The binary is called 'tasker', not 'gronx'
DOWNLOAD_URL=$(curl -sL https://api.github.com/repos/adhocore/gronx/releases/latest | jq -r '.assets[] | select(.name | contains("linux_amd64") and contains("tar.gz")) | .browser_download_url')
echo "Downloading from: $DOWNLOAD_URL"

# Download and extract
cd /tmp
curl -sL -o tasker.tar.gz "$DOWNLOAD_URL"
tar -xzf tasker.tar.gz
# The tarball contains a directory with the binary
mv tasker_*/tasker /usr/local/bin/gronx
chmod +x /usr/local/bin/gronx
rm -rf tasker.tar.gz tasker_*
cd -

echo "Gronx installed successfully"
