#!/bin/bash
set -euo pipefail

if [ $# -lt 2 ]; then
  echo "Usage: $0 <version> <image>"
  echo "Example: $0 4.18 quay.io/redhat-user-workloads/devspaces-tenant/devspaces/code-rhel9:3.30"
  exit 1
fi

VERSION="$1"
IMAGE="$2"
COMPONENT="devspaces-code-rhel9-container"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
WORK_DIR="$SCRIPT_DIR"

echo "=== Building check-payload from source ==="
CGO_ENABLED=0 go build -ldflags="-X main.Commit=$(git -C "$REPO_DIR" describe --tags --abbrev=8 --dirty --always --long)" -o "$WORK_DIR/check-payload" "$REPO_DIR"

echo "=== Scanning image: $IMAGE (version=$VERSION, component=$COMPONENT) ==="

echo "--- Cleaning up previous run..."
chmod -R u+rwX "$WORK_DIR/bundle" 2>/dev/null || true
rm -rf "$WORK_DIR/local-image" "$WORK_DIR/bundle"

echo "--- Downloading image..."
skopeo copy --override-arch amd64 --override-os linux "docker://$IMAGE" "dir:$WORK_DIR/local-image"

echo "--- Unpacking layers..."
mkdir -p "$WORK_DIR/bundle/rootfs"
for layer in $(python3 -c "import sys,json; [print(l['digest'].split(':')[1]) for l in json.load(open('$WORK_DIR/local-image/manifest.json'))['layers']]"); do
  tar -xzf "$WORK_DIR/local-image/$layer" -C "$WORK_DIR/bundle/rootfs" 2>/dev/null || true
done

echo "--- Running FIPS check..."
"$WORK_DIR/check-payload" scan local --path "$WORK_DIR/bundle/rootfs" -V "$VERSION" --components "$COMPONENT"
