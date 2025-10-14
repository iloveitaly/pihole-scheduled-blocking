#!/usr/bin/env bash

set -euo pipefail

echo "Installing gronx..."

# Detect architecture
ARCH=$(uname -m)
case "$ARCH" in
  x86_64)
    GRONX_ARCH="amd64"
    ;;
  aarch64|arm64)
    GRONX_ARCH="arm64"
    ;;
  armv7l)
    GRONX_ARCH="armv6"
    ;;
  armv6l)
    GRONX_ARCH="armv6"
    ;;
  i386|i686)
    GRONX_ARCH="386"
    ;;
  *)
    echo "Unsupported architecture: $ARCH"
    exit 1
    ;;
esac

echo "Detected architecture: $ARCH (using linux_${GRONX_ARCH})"

# Ensure we have necessary tools for tar and JSON parsing
apk add --no-cache tar gzip jq curl

# Get the correct download URL from GitHub API
# Note: The binary is called 'tasker', not 'gronx'
DOWNLOAD_URL=$(curl -sL https://api.github.com/repos/adhocore/gronx/releases/latest | jq -r ".assets[] | select(.name | contains(\"linux_${GRONX_ARCH}\") and contains(\"tar.gz\")) | .browser_download_url")

if [ -z "$DOWNLOAD_URL" ] || [ "$DOWNLOAD_URL" = "null" ]; then
  echo "Failed to find download URL for architecture: linux_${GRONX_ARCH}"
  exit 1
fi

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
# Verify the binary works
/usr/local/bin/gronx -v
