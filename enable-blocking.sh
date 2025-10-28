#!/bin/bash

set -euo pipefail

cd "$(dirname "$0")"

echo "Running enable-blocking.sh to ensure Pi-hole blocking is enabled"

# Pi-hole's API endpoint for enabling blocking
# When blocking is disabled manually (e.g., for testing), this will re-enable it
# The enable endpoint doesn't require authentication when called locally

# Get the API URL from Pi-hole
API_URL="http://localhost/admin/api.php"

# Enable blocking using the Pi-hole API
# The 'enable' action re-enables blocking if it was disabled
response=$(curl -s "${API_URL}?enable" || echo "error")

# Check if the response indicates success
if echo "$response" | grep -q '"status":"enabled"'; then
  echo "✓ Pi-hole blocking is now enabled"
else
  echo "! Warning: Could not confirm blocking was enabled. Response: $response"
fi
