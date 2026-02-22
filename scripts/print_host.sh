#!/usr/bin/env bash
# Print a recommended mDNS hostname for the dev machine (macOS)
# Usage: ./scripts/print_host.sh

set -euo pipefail

if command -v scutil >/dev/null 2>&1; then
  host=$(scutil --get LocalHostName 2>/dev/null || true)
  if [ -n "$host" ]; then
    echo "${host}.local"
    exit 0
  fi
fi

# Fallback to hostname
host=$(hostname 2>/dev/null || true)
if [ -n "$host" ]; then
  echo "${host}.local"
  exit 0
fi

echo "localhost"
exit 0
