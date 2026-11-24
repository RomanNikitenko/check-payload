#!/bin/bash
set -euo pipefail

if [ $# -lt 2 ]; then
  echo "Usage: $0 <platform> <image>"
  echo "Example: $0 linux/s390x quay.io/redhat-user-workloads/devspaces-tenant/devspaces/code-rhel9:3.30"
  exit 1
fi

PLATFORM="$1"
IMAGE="$2"
DEST="${PLATFORM##*/}-image"

echo "=== Extracting $IMAGE ($PLATFORM) to $DEST ==="

# chmod first: an extraction from before this fix may carry read-only RHEL
# dir modes that make plain rm -rf fail with Permission denied.
chmod -R u+rwX "$DEST" 2>/dev/null || true
rm -rf "$DEST"
mkdir -p "$DEST"

CID=$(podman create --platform "$PLATFORM" "$IMAGE" /bin/true)
trap 'podman rm "$CID" >/dev/null 2>&1' EXIT

podman export "$CID" | tar -xf - -C "$DEST"

# tar preserves image dir modes without the write bit (RHEL ships /root as
# 0550 and /usr/* as 0555); restore owner write access so the output stays
# deletable without sudo.
chmod -R u+rwX "$DEST"

echo "=== Done: $DEST ==="
