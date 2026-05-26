#!/usr/bin/env bash
set -euo pipefail

RELEASE_REPO="${RELEASE_REPO:-infimount/infimount}"
INPUT_VERSION="${1:-}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FORMULA_PATH="${ROOT_DIR}/Formula/infimount.rb"
CASK_PATH="${ROOT_DIR}/Casks/infimount.rb"

if [[ -n "${INPUT_VERSION}" ]]
then
  VERSION="${INPUT_VERSION#v}"
else
  TAG="$(
    curl -fsSL "https://api.github.com/repos/${RELEASE_REPO}/releases?per_page=20" |
      jq -r '[.[] | select(.draft == false)][0].tag_name'
  )"

  if [[ -z "${TAG}" || "${TAG}" == "null" ]]
  then
    echo "Could not resolve latest release tag from ${RELEASE_REPO}" >&2
    exit 1
  fi

  VERSION="${TAG#v}"
fi

BASE_URL="https://github.com/${RELEASE_REPO}/releases/download/v${VERSION}"
SUMS_URL="${BASE_URL}/SHA256SUMS.txt"
SUMS="$(curl -fsSL "${SUMS_URL}")"
APPIMAGE_SHA="$(awk '/Infimount-x86_64\.AppImage$/ { print $1; exit }' <<<"${SUMS}")"
DMG_SHA="$(awk '/Infimount\.dmg$/ { print $1; exit }' <<<"${SUMS}")"

if [[ -z "${APPIMAGE_SHA}" ]]
then
  echo "Could not find checksum for Infimount-x86_64.AppImage in ${SUMS_URL}" >&2
  exit 1
fi

if [[ -z "${DMG_SHA}" ]]
then
  echo "Could not find checksum for Infimount.dmg in ${SUMS_URL}" >&2
  exit 1
fi

cat >"${FORMULA_PATH}" <<FORMULA
class Infimount < Formula
  desc "Desktop file and object storage explorer"
  homepage "https://github.com/infimount/infimount"
  url "${BASE_URL}/Infimount-x86_64.AppImage"
  version "${VERSION}"
  sha256 "${APPIMAGE_SHA}"
  license "MIT"

  depends_on :linux

  def install
    libexec.install "Infimount-x86_64.AppImage" => "infimount.AppImage"
    chmod 0755, libexec/"infimount.AppImage"

    (bin/"infimount").write <<~SH
      #!/usr/bin/env bash
      export APPIMAGE_EXTRACT_AND_RUN=1
      exec "#{libexec}/infimount.AppImage" "\$@"
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

cat >"${CASK_PATH}" <<CASK
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
  depends_on :macos

  app "Infimount.app"

  zap trash: [
    "~/.infimount",
    "~/Library/Application Support/com.infimount.desktop",
    "~/Library/Preferences/com.infimount.desktop.plist",
    "~/Library/Saved Application State/com.infimount.desktop.savedState",
  ]
end
CASK

echo "Updated ${FORMULA_PATH} and ${CASK_PATH} to v${VERSION}"
if [[ -n "${GITHUB_OUTPUT:-}" ]]
then
  echo "version=${VERSION}" >>"${GITHUB_OUTPUT}"
fi
