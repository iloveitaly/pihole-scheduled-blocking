#!/bin/bash

set -euo pipefail

cd "$(dirname "$0")"

echo "Running enable-blocking.sh to ensure Pi-hole blocking is enabled"

# Pi-hole's API endpoint for enabling blocking
# When blocking is disabled manually (e.g., for testing), this will re-enable it
# Note: Authentication may be required depending on Pi-hole configuration

# Get the API URL from Pi-hole
API_URL="http://localhost/admin/api.php"

# Enable blocking using the Pi-hole API
# The 'enable' action re-enables blocking if it was disabled
# Capture both response and HTTP status code
http_code=$(curl -s -o /tmp/pihole_response.json -w "%{http_code}" "${API_URL}?enable" || echo "000")

if [ "$http_code" = "200" ]; then
  # Check if the response indicates success using jq for proper JSON parsing
  if command -v jq >/dev/null 2>&1; then
    status=$(jq -r '.status // empty' /tmp/pihole_response.json 2>/dev/null || echo "")
    if [ "$status" = "enabled" ]; then
      echo "✓ Pi-hole blocking is now enabled"
    else
      echo "! Warning: Could not confirm blocking was enabled. Status: $status"
    fi
  else
    # Fallback to grep if jq is not available
    if grep -q '"status":"enabled"' /tmp/pihole_response.json 2>/dev/null; then
      echo "✓ Pi-hole blocking is now enabled"
    else
      response=$(cat /tmp/pihole_response.json 2>/dev/null || echo "")
      echo "! Warning: Could not confirm blocking was enabled. Response: $response"
    fi
  fi
elif [ "$http_code" = "401" ]; then
  echo "! Error: Authentication required. Please configure API authentication in Pi-hole."
  exit 1
elif [ "$http_code" = "000" ]; then
  echo "! Error: Failed to connect to Pi-hole API. Is Pi-hole running?"
  exit 1
else
  echo "! Error: Unexpected HTTP status code: $http_code"
  exit 1
fi

# Clean up temporary file
rm -f /tmp/pihole_response.json
