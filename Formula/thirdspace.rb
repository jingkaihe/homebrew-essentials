class Thirdspace < Formula
  desc "Browse and book Third Space gym classes"
  homepage "https://github.com/jingkaihe/thirdspace"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/jingkaihe/thirdspace/releases/download/v0.1.1/thirdspace_0.1.1_darwin_arm64.tar.gz"
      sha256 "14c68aeded899daf66dd9a50441e2a451fabbf84816b9641bbc72323d1d879a1"
    else
      url "https://github.com/jingkaihe/thirdspace/releases/download/v0.1.1/thirdspace_0.1.1_darwin_amd64.tar.gz"
      sha256 "0b3cde69c6a749b823c669c5e2b236aa539c529807d561320604f21d9e84b7c1"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/jingkaihe/thirdspace/releases/download/v0.1.1/thirdspace_0.1.1_linux_arm64.tar.gz"
      sha256 "c067a09999a8a04ca55da86a48b22a712c4e32749306ff16c7fa4f131fc61fbb"
    else
      url "https://github.com/jingkaihe/thirdspace/releases/download/v0.1.1/thirdspace_0.1.1_linux_amd64.tar.gz"
      sha256 "a502a26a931a7ca48b807a0086f1822279591c01e0f8d7787e40956e8dd24216"
    end
  end

  def install
    bin.install "thirdspace"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/thirdspace --version")
  end
end
