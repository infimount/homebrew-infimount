class Infimount < Formula
  desc "Desktop file and object storage explorer"
  homepage "https://github.com/infimount/infimount"
  url "https://github.com/infimount/infimount/releases/download/v0.8.0/Infimount-x86_64.AppImage"
  version "0.8.0"
  sha256 "d962572c57b65ba3a1c5668a57934663b4895576eb6cdf713147a095944c2e28"
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
