class Thirdspace < Formula
  desc "Browse and book Third Space gym classes"
  homepage "https://github.com/jingkaihe/thirdspace"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/jingkaihe/thirdspace/releases/download/v0.1.0/thirdspace_0.1.0_darwin_arm64.tar.gz"
      sha256 "bfae03c213528b9a7882853d1848426e74e1c8cc3f1c86f41daf210b99c2a5e5"
    else
      url "https://github.com/jingkaihe/thirdspace/releases/download/v0.1.0/thirdspace_0.1.0_darwin_amd64.tar.gz"
      sha256 "e2a6c1d8b4a2f4ebba0c89497c32b049b44a4e2993385b0a94fbbaa9a38a2775"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/jingkaihe/thirdspace/releases/download/v0.1.0/thirdspace_0.1.0_linux_arm64.tar.gz"
      sha256 "446834f56d618a5c60119e989b38389c2923a44c2fbfb1ad146a0a3624079fa6"
    else
      url "https://github.com/jingkaihe/thirdspace/releases/download/v0.1.0/thirdspace_0.1.0_linux_amd64.tar.gz"
      sha256 "cf9a92f46ab89ad457193e0856a3d8f158ace80d07694a47be620fad921f6471"
    end
  end

  def install
    bin.install "thirdspace"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/thirdspace --version")
  end
end
