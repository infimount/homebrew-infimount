class Infimount < Formula
  desc "Desktop file and object storage explorer"
  homepage "https://github.com/infimount/infimount"
  license "MIT"
  version "0.1.0"

  depends_on :linux

  url "https://github.com/infimount/infimount/releases/download/v0.1.0/Infimount-x86_64.AppImage"
  sha256 "757e4ce1e4430a92e252aba90f0126ddb87f2e4f5e9a81dddbf094fe4baff7ce"

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
