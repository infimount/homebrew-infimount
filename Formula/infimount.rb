class Infimount < Formula
  desc "Desktop file and object storage explorer"
  homepage "https://github.com/infimount/infimount"
  url "https://github.com/infimount/infimount/releases/download/v0.2.2/Infimount-amd64.deb"
  version "0.2.2"
  sha256 "5f880392afe45f1b0e784c68ae0e5a989dd44b3a776729c4a2e43d0d05c788b1"
  license "MIT"

  depends_on :linux

  def install
    system "ar", "x", "Infimount-amd64.deb"

    if File.exist?("data.tar.gz")
      system "tar", "xf", "data.tar.gz"
    elsif File.exist?("data.tar.xz")
      system "tar", "xf", "data.tar.xz"
    elsif File.exist?("data.tar.zst")
      system "tar", "--use-compress-program=zstd", "-xf", "data.tar.zst"
    end

    bin.install "usr/bin/infimount"
    share.install Dir["usr/share/*"] if Dir.exist?("usr/share")
  end

  def caveats
    <<~EOS
      Infimount is a GUI desktop app.
      Launch from terminal with:
        infimount
    EOS
  end

  test do
    assert_match "Usage:", shell_output("#{bin}/infimount --help", 1) || true
  end
end
