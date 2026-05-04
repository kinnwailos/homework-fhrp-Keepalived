#!/usr/bin/env bash
set -u

# Keepalived health-check script:
# - verifies that TCP port on localhost is reachable
# - verifies that index.html exists in web root
#
# Usage:
#   ./check_web.sh [PORT] [DOCROOT]
#
# Exit codes:
#   0  - OK (port reachable and index.html exists)
#   1  - index.html missing
#   2  - port unreachable

PORT="${1:-80}"
DOCROOT="${2:-/var/www/html}"
INDEX_FILE="${DOCROOT%/}/index.html"
HOST="127.0.0.1"

if [[ ! -f "$INDEX_FILE" ]]; then
  echo "index.html not found: $INDEX_FILE" >&2
  exit 1
fi

# Check TCP connectivity using bash /dev/tcp (works without curl/nc).
# timeout ensures the script returns quickly for Keepalived.
if timeout 1 bash -c "cat < /dev/null > /dev/tcp/${HOST}/${PORT}" >/dev/null 2>&1; then
  exit 0
fi

echo "port ${HOST}:${PORT} is unreachable" >&2
exit 2
