#!/usr/bin/env bash
# Install the kit binary into $GITHUB_ACTION_PATH/bin and prepend it to PATH.
# Source of truth: GitHub releases on hop-top/kit. Falls back to `go install`
# when a prebuilt asset is unavailable for the runner triple.
set -euo pipefail

VERSION="${INPUT_KIT_VERSION:-latest}"
REPO="hop-top/kit"
ACTION_BIN_DIR="${GITHUB_ACTION_PATH:-$(pwd)}/bin"
mkdir -p "$ACTION_BIN_DIR"

uname_s=$(uname -s)
uname_m=$(uname -m)

case "$uname_s" in
  Linux)   os=linux ;;
  Darwin)  os=darwin ;;
  MINGW*|MSYS*|CYGWIN*) os=windows ;;
  *) echo "::error::unsupported OS: $uname_s"; exit 3 ;;
esac

case "$uname_m" in
  x86_64|amd64) arch=amd64 ;;
  arm64|aarch64) arch=arm64 ;;
  *) echo "::error::unsupported arch: $uname_m"; exit 3 ;;
esac

ext=tar.gz
[ "$os" = "windows" ] && ext=zip

# Resolve "latest" to a concrete tag so subsequent runs are reproducible
# in the run log.
if [ "$VERSION" = "latest" ]; then
  VERSION=$(gh release view --repo "$REPO" --json tagName --jq .tagName)
fi

asset="kit_${VERSION#v}_${os}_${arch}.${ext}"
echo "::group::Installing kit ${VERSION} (${os}/${arch})"
echo "asset=${asset}"

tmp=$(mktemp -d)
if gh release download "$VERSION" --repo "$REPO" --pattern "$asset" --dir "$tmp" 2>/dev/null; then
  case "$ext" in
    tar.gz) tar -xzf "$tmp/$asset" -C "$tmp" ;;
    zip)    unzip -q "$tmp/$asset" -d "$tmp" ;;
  esac
  install -m 0755 "$tmp/kit" "$ACTION_BIN_DIR/kit" 2>/dev/null \
    || install -m 0755 "$tmp/kit.exe" "$ACTION_BIN_DIR/kit.exe"
else
  echo "::warning::no prebuilt asset $asset; falling back to 'go install'"
  if ! command -v go >/dev/null 2>&1; then
    echo "::error::go toolchain not available and no prebuilt asset found"
    exit 4
  fi
  GOBIN="$ACTION_BIN_DIR" go install "hop.top/kit/cmd/kit@${VERSION}"
fi

echo "${ACTION_BIN_DIR}" >> "$GITHUB_PATH"
"$ACTION_BIN_DIR/kit" --version || true
echo "::endgroup::"
