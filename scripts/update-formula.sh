#!/usr/bin/env bash
set -euo pipefail

RELEASE_REPO="${RELEASE_REPO:-infimount/infimount}"
INPUT_VERSION="${1:-}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FORMULA_PATH="$ROOT_DIR/Formula/infimount.rb"
CASK_PATH="$ROOT_DIR/Casks/infimount.rb"

if [[ -n "$INPUT_VERSION" ]]; then
  VERSION="${INPUT_VERSION#v}"
else
  TAG="$(
    curl -fsSL "https://api.github.com/repos/${RELEASE_REPO}/releases?per_page=20" \
      | jq -r '[.[] | select(.draft == false)][0].tag_name'
  )"

  if [[ -z "$TAG" || "$TAG" == "null" ]]; then
    echo "Could not resolve latest release tag from ${RELEASE_REPO}" >&2
    exit 1
  fi

  VERSION="${TAG#v}"
fi

BASE_URL="https://github.com/${RELEASE_REPO}/releases/download/v${VERSION}"
SUMS_URL="${BASE_URL}/SHA256SUMS.txt"
SUMS="$(curl -fsSL "$SUMS_URL")"
DEB_SHA="$(awk '/Infimount-amd64\.deb$/ { print $1; exit }' <<< "$SUMS")"
DMG_SHA="$(awk '/Infimount\.dmg$/ { print $1; exit }' <<< "$SUMS")"

if [[ -z "$DEB_SHA" ]]; then
  echo "Could not find checksum for Infimount-amd64.deb in $SUMS_URL" >&2
  exit 1
fi

if [[ -z "$DMG_SHA" ]]; then
  echo "Could not find checksum for Infimount.dmg in $SUMS_URL" >&2
  exit 1
fi

cat > "$FORMULA_PATH" <<FORMULA
class Infimount < Formula
  desc "Desktop file and object storage explorer"
  homepage "https://github.com/infimount/infimount"
  url "${BASE_URL}/Infimount-amd64.deb"
  version "${VERSION}"
  sha256 "${DEB_SHA}"
  license "MIT"

  depends_on :linux

  def install
    system "ar", "x", "Infimount-amd64.deb"

    if File.exist?("data.tar.gz")
      system "tar", "xf", "data.tar.gz"
    elsif File.exist?("data.tar.xz")
      system "tar", "xf", "data.tar.xz"
    elsif File.exist?("data.tar.zst")
      system "tar", "--use-compress-program=zstd", "-xf", "data.tar.zst"
    end

    bin.install "usr/bin/infimount"
    share.install Dir["usr/share/*"] if Dir.exist?("usr/share")
  end

  def caveats
    <<~EOS
      Infimount is a GUI desktop app.
      Launch from terminal with:
        infimount
    EOS
  end

  test do
    assert_match "Usage:", shell_output("#{bin}/infimount --help", 1) || true
  end
end
FORMULA

cat > "$CASK_PATH" <<CASK
cask "infimount" do
  version "${VERSION}"
  sha256 "${DMG_SHA}"

  url "https://github.com/infimount/infimount/releases/download/v#{version}/Infimount.dmg"
  name "Infimount"
  desc "Browse local and cloud storage through a single interface"
  homepage "https://infimount.github.io/infimount/"

  livecheck do
    url :url
    strategy :github_latest
  end

  auto_updates true

  app "Infimount.app"

  zap trash: [
    "~/.infimount",
    "~/Library/Application Support/com.infimount.desktop",
    "~/Library/Preferences/com.infimount.desktop.plist",
    "~/Library/Saved Application State/com.infimount.desktop.savedState",
  ]
end
CASK

echo "Updated $FORMULA_PATH and $CASK_PATH to v${VERSION}"
if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  echo "version=${VERSION}" >> "$GITHUB_OUTPUT"
fi
