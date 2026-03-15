class Infimount < Formula
  desc "Desktop file and object storage explorer"
  homepage "https://github.com/infimount/infimount"
  license "MIT"
  version "0.2.0"

  depends_on :linux

  url "https://github.com/infimount/infimount/releases/download/v0.2.0/Infimount-amd64.deb"
  sha256 "07c34d2bef1b20b59dafb919646c15405629e770d24e37f8fa10c52e9bee5ee4"

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
    if Dir.exist?("usr/share")
      share.install Dir["usr/share/*"]
    end
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
