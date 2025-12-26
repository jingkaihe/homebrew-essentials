class Waitrose < Formula
  desc "Go client library and CLI for the Waitrose & Partners grocery API"
  homepage "https://github.com/jingkaihe/waitrose"
  version "0.1.1-beta"
  
  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/jingkaihe/waitrose/releases/download/v0.1.1-beta/waitrose-darwin-arm64"
      sha256 "ce1c5516165e9bc685fa7c6ef349686da410644b544c4230d8c4b53f0de29c8c"
    else
      url "https://github.com/jingkaihe/waitrose/releases/download/v0.1.1-beta/waitrose-darwin-amd64"
      sha256 "368aab026663df256a5ace14738afd1effa74060d26367c5689e42301e377b2c"
    end
  end
  
  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/jingkaihe/waitrose/releases/download/v0.1.1-beta/waitrose-linux-arm64"
      sha256 "7c5b19053808e5072c86fb60025b30f9ec9ddb17975524400e83369eeadb1be1"
    else
      url "https://github.com/jingkaihe/waitrose/releases/download/v0.1.1-beta/waitrose-linux-amd64"
      sha256 "7c8c60675beafbb805ba28957292093fbe2158ee0ee342a91014d481b933de1c"
    end
  end

  def install
    bin.install Dir["waitrose*"].first => "waitrose"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/waitrose version")
  end
end
