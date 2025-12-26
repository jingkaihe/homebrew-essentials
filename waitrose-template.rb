class Waitrose < Formula
  desc "Go client library and CLI for the Waitrose & Partners grocery API"
  homepage "https://github.com/jingkaihe/waitrose"
  version "{{VERSION}}"
  
  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/jingkaihe/waitrose/releases/download/v{{VERSION}}/waitrose-darwin-arm64"
      sha256 "{{SHA256_DARWIN_ARM64}}"
    else
      url "https://github.com/jingkaihe/waitrose/releases/download/v{{VERSION}}/waitrose-darwin-amd64"
      sha256 "{{SHA256_DARWIN_AMD64}}"
    end
  end
  
  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/jingkaihe/waitrose/releases/download/v{{VERSION}}/waitrose-linux-arm64"
      sha256 "{{SHA256_LINUX_ARM64}}"
    else
      url "https://github.com/jingkaihe/waitrose/releases/download/v{{VERSION}}/waitrose-linux-amd64"
      sha256 "{{SHA256_LINUX_AMD64}}"
    end
  end

  def install
    bin.install Dir["waitrose*"].first => "waitrose"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/waitrose version")
  end
end
