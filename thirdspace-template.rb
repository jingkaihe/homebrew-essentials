class Thirdspace < Formula
  desc "Browse and book Third Space gym classes"
  homepage "https://github.com/jingkaihe/thirdspace"
  version "{{VERSION}}"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/jingkaihe/thirdspace/releases/download/v{{VERSION}}/thirdspace_{{VERSION}}_darwin_arm64.tar.gz"
      sha256 "{{SHA256_DARWIN_ARM64}}"
    else
      url "https://github.com/jingkaihe/thirdspace/releases/download/v{{VERSION}}/thirdspace_{{VERSION}}_darwin_amd64.tar.gz"
      sha256 "{{SHA256_DARWIN_AMD64}}"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/jingkaihe/thirdspace/releases/download/v{{VERSION}}/thirdspace_{{VERSION}}_linux_arm64.tar.gz"
      sha256 "{{SHA256_LINUX_ARM64}}"
    else
      url "https://github.com/jingkaihe/thirdspace/releases/download/v{{VERSION}}/thirdspace_{{VERSION}}_linux_amd64.tar.gz"
      sha256 "{{SHA256_LINUX_AMD64}}"
    end
  end

  def install
    bin.install "thirdspace"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/thirdspace --version")
  end
end
