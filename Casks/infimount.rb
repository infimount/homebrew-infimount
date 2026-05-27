cask "infimount" do
  version "0.6.0"
  sha256 "4cb8aaa680adfa2d440dd40bdea61c09fe7c3b273395c81a8405981ed9a97018"

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
