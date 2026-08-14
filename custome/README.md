# Scripts

## extract-image.sh

Extract container image filesystem for any platform.

```bash
./extract-image.sh <platform> <image>
```

### Examples

```bash
./extract-image.sh linux/amd64 quay.io/redhat-user-workloads/devspaces-tenant/devspaces/code-rhel9:3.30
./extract-image.sh linux/arm64 quay.io/redhat-user-workloads/devspaces-tenant/devspaces/code-rhel9:3.30
./extract-image.sh linux/s390x quay.io/redhat-user-workloads/devspaces-tenant/devspaces/code-rhel9:3.30
./extract-image.sh linux/ppc64le quay.io/redhat-user-workloads/devspaces-tenant/devspaces/code-rhel9:3.30
```

Results will be in `./amd64-image`, `./arm64-image`, `./s390x-image`, `./ppc64le-image` respectively.

## scan-image.sh

Build check-payload from source, download image via skopeo (amd64), unpack layers, and run FIPS scan with release-specific config.

```bash
./scan-image.sh <version> <image>
```

### Examples

```bash
./scan-image.sh 4.18 quay.io/redhat-user-workloads/devspaces-tenant/devspaces/code-rhel9:3.30
./scan-image.sh 5.1 quay.io/redhat-user-workloads/devspaces-tenant/devspaces/code-rhel9:latest
```

Results will be in `./bundle/rootfs`. Requires `skopeo`, `python3`, and `go`.
