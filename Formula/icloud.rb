class Icloud < Formula
  desc "CLI for interacting with iCloud services"
  homepage "https://github.com/jingkaihe/icloud-cli"
  version "0.1.0-beta"
  
  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/jingkaihe/icloud-cli/releases/download/v0.1.0-beta/icloud-darwin-arm64"
      sha256 "8d4f3da9be14b623197490a745d806f611258ce25ee2fa41b89c7ab92c48632b"
    else
      url "https://github.com/jingkaihe/icloud-cli/releases/download/v0.1.0-beta/icloud-darwin-amd64"
      sha256 "3b74797aa2e5769575403ac89f17035bb1b6558d1b1c28a482da3dc73c19dc38"
    end
  end
  
  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/jingkaihe/icloud-cli/releases/download/v0.1.0-beta/icloud-linux-arm64"
      sha256 "1b26d242ceefa0f7eda5662c7138d0da019da097cd48ad5a679a9958b6137a26"
    else
      url "https://github.com/jingkaihe/icloud-cli/releases/download/v0.1.0-beta/icloud-linux-amd64"
      sha256 "39b99b4b3da4ae6d58fb1c3fd16b1b4f7e9ff87f465ad56b11ebff4b03dce049"
    end
  end

  def install
    bin.install Dir["icloud*"].first => "icloud"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/icloud version")
  end
end
