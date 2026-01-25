class Waitrose < Formula
  desc "Go client library and CLI for the Waitrose & Partners grocery API"
  homepage "https://github.com/jingkaihe/waitrose"
  version "0.1.2-beta"
  
  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/jingkaihe/waitrose/releases/download/v0.1.2-beta/waitrose-darwin-arm64"
      sha256 "733422536dc1c4ab68bce74a8d174ece8efee0df78530a45ffe5e78b360f877e"
    else
      url "https://github.com/jingkaihe/waitrose/releases/download/v0.1.2-beta/waitrose-darwin-amd64"
      sha256 "d0d863da02595c6c92597911570ef418118cfc583d7fffc15721422b490382a0"
    end
  end
  
  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/jingkaihe/waitrose/releases/download/v0.1.2-beta/waitrose-linux-arm64"
      sha256 "a9641c3d277081c49b955cafb79932c1c74054d599c3b25e79af58f8de103f29"
    else
      url "https://github.com/jingkaihe/waitrose/releases/download/v0.1.2-beta/waitrose-linux-amd64"
      sha256 "92b6e8bf2c235eb960acc8e04b3f3e6a86a91bfec0c4d5a56cc3f62de6967ea1"
    end
  end

  def install
    bin.install Dir["waitrose*"].first => "waitrose"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/waitrose version")
  end
end
