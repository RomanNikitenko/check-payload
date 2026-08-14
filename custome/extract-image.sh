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

rm -rf "$DEST"
mkdir -p "$DEST"

CID=$(podman create --platform "$PLATFORM" "$IMAGE" /bin/true)
trap 'podman rm "$CID" >/dev/null 2>&1' EXIT

podman export "$CID" | tar -xf - -C "$DEST"

echo "=== Done: $DEST ==="
