class Infimount < Formula
  desc "Desktop file and object storage explorer"
  homepage "https://github.com/infimount/infimount"
  license "MIT"
  version "0.1.0-alpha.12"

  depends_on :linux

  url "https://github.com/infimount/infimount/releases/download/v0.1.0-alpha.12/Infimount-x86_64.AppImage"
  sha256 "8b1e659cd563eb549b742f1cb6e55f770bacdc7e78c1ab5227f1f44568a73648"

  def install
    libexec.install "Infimount-x86_64.AppImage" => "infimount.AppImage"
    chmod 0o755, libexec/"infimount.AppImage"

    (bin/"infimount").write <<~SH
      #!/usr/bin/env bash
      export APPIMAGE_EXTRACT_AND_RUN=1
      exec "#{libexec}/infimount.AppImage" ""
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
