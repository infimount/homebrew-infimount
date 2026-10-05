class Infimount < Formula
  desc "Desktop file and object storage explorer"
  homepage "https://github.com/infimount/infimount"
  url "https://github.com/infimount/infimount/releases/download/v0.8.1/Infimount-x86_64.AppImage"
  version "0.8.1"
  sha256 "fbbc3fb049416a8e8aa66d602ccd5c57404ddbdc570aa1cc02f66588808ce288"
  license "MIT"

  depends_on :linux

  def install
    libexec.install "Infimount-x86_64.AppImage" => "infimount.AppImage"
    chmod 0755, libexec/"infimount.AppImage"

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
