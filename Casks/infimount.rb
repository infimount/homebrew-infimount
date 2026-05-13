cask "infimount" do
  version "0.2.2"
  sha256 "fd6ca8d72f5d16f0ce455b13cb56b10a9162d6ecad45656d9e4f379b67a1c2a4"

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
