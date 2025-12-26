class Icloud < Formula
  desc "CLI for interacting with iCloud services"
  homepage "https://github.com/jingkaihe/icloud-cli"
  version "{{VERSION}}"
  
  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/jingkaihe/icloud-cli/releases/download/v{{VERSION}}/icloud-darwin-arm64"
      sha256 "{{SHA256_DARWIN_ARM64}}"
    else
      url "https://github.com/jingkaihe/icloud-cli/releases/download/v{{VERSION}}/icloud-darwin-amd64"
      sha256 "{{SHA256_DARWIN_AMD64}}"
    end
  end
  
  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/jingkaihe/icloud-cli/releases/download/v{{VERSION}}/icloud-linux-arm64"
      sha256 "{{SHA256_LINUX_ARM64}}"
    else
      url "https://github.com/jingkaihe/icloud-cli/releases/download/v{{VERSION}}/icloud-linux-amd64"
      sha256 "{{SHA256_LINUX_AMD64}}"
    end
  end

  def install
    bin.install Dir["icloud*"].first => "icloud"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/icloud version")
  end
end
