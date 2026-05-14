cask "infimount" do
  version "0.2.3"
  sha256 "731923b533f9ab34d57ec6dd2426b1c9f6c69622a6dad16c283ad1e3330c155c"

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
