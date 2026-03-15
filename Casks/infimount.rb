cask "infimount" do
  version "0.2.1"
  sha256 "a50654007c2daab2439391aed92029fd020d4bf04701c8531236794416c18933"

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
