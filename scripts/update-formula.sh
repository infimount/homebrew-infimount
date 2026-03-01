#!/usr/bin/env bash
set -euo pipefail

RELEASE_REPO="${RELEASE_REPO:-infimount/infimount}"
INPUT_VERSION="${1:-}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FORMULA_PATH="$ROOT_DIR/Formula/infimount.rb"

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
APPIMAGE_SHA="$(curl -fsSL "$SUMS_URL" | awk '/Infimount-x86_64\.AppImage$/ { print $1; exit }')"

if [[ -z "$APPIMAGE_SHA" ]]; then
  echo "Could not find checksum for Infimount-x86_64.AppImage in $SUMS_URL" >&2
  exit 1
fi

cat > "$FORMULA_PATH" <<FORMULA
class Infimount < Formula
  desc "Desktop file and object storage explorer"
  homepage "https://github.com/infimount/infimount"
  license "MIT"
  version "${VERSION}"

  depends_on :linux

  url "${BASE_URL}/Infimount-x86_64.AppImage"
  sha256 "${APPIMAGE_SHA}"

  def install
    libexec.install "Infimount-x86_64.AppImage" => "infimount.AppImage"
    chmod 0o755, libexec/"infimount.AppImage"

    (bin/"infimount").write <<~SH
      #!/usr/bin/env bash
      export APPIMAGE_EXTRACT_AND_RUN=1
      exec "#{libexec}/infimount.AppImage" "$@"
    SH
  end

  def caveats
    <<~EOS
      Infimount is a GUI desktop app packaged as AppImage.
      Launch from terminal with:
        infimount
    EOS
  end

  test do
    assert_match "Version", shell_output("#{bin}/infimount --appimage-version")
  end
end
FORMULA

echo "Updated $FORMULA_PATH to v${VERSION}"
if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  echo "version=${VERSION}" >> "$GITHUB_OUTPUT"
fi
