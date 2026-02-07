class Matchlock < Formula
  desc "Lightweight micro-VM sandbox for running AI agents securely"
  homepage "https://github.com/jingkaihe/matchlock"
  version "0.1.1"
  license "MIT"

  depends_on "e2fsprogs"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.1/matchlock-darwin-arm64"
      sha256 "58dfc375a1d8955c6f764864a09b06381578f923b42122e9ac53c579bd6bbbf7"

      resource "guest-agent" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.1/guest-agent-linux-arm64"
        sha256 "29dd0e06813648cc9afb2e2d90456e6b6f522a67ee8d2b7f5209226e157f7196"
      end

      resource "guest-fused" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.1/guest-fused-linux-arm64"
        sha256 "1be614da35133a5fe5c22c7afabd001a91f2ea76a4dfbd94af23d5eeb50f01ec"
      end
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.1/matchlock-linux-arm64"
      sha256 "e8793a5cfb0443f0baf11a697ed590ce2d39889bc50cddc62eed52ee05cfc3e9"

      resource "guest-agent" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.1/guest-agent-linux-arm64"
        sha256 "29dd0e06813648cc9afb2e2d90456e6b6f522a67ee8d2b7f5209226e157f7196"
      end

      resource "guest-fused" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.1/guest-fused-linux-arm64"
        sha256 "1be614da35133a5fe5c22c7afabd001a91f2ea76a4dfbd94af23d5eeb50f01ec"
      end
    else
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.1/matchlock-linux-amd64"
      sha256 "deeb9cd94d498deb7cd90da4324b1a27a5903fca2c7422139b5ebf830b81a9fb"

      resource "guest-agent" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.1/guest-agent-linux-amd64"
        sha256 "fb5072e498ad6ec69b55bc1400afccad75ad6edaa62e4ef4ca5cb9ec0813d101"
      end

      resource "guest-fused" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.1/guest-fused-linux-amd64"
        sha256 "e50acb7d0338f420de34e3941c879f04f61a32e34b331436b24af54d6e95bf2d"
      end
    end
  end

  def install
    libexec.install Dir["matchlock*"].first => "matchlock"
    resource("guest-agent").stage { libexec.install Dir["guest-agent*"].first => "guest-agent" }
    resource("guest-fused").stage { libexec.install Dir["guest-fused*"].first => "guest-fused" }
    chmod 0755, libexec/"matchlock"
    chmod 0755, libexec/"guest-agent"
    chmod 0755, libexec/"guest-fused"

    if OS.mac?
      entitlements = buildpath/"matchlock.entitlements"
      entitlements.write <<~XML
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>com.apple.security.virtualization</key>
            <true/>
        </dict>
        </plist>
      XML
      system "codesign", "--entitlements", entitlements, "-f", "-s", "-", libexec/"matchlock"
    end

    (bin/"matchlock").write <<~SH
      #!/bin/bash
      export MATCHLOCK_GUEST_AGENT="#{libexec}/guest-agent"
      export MATCHLOCK_GUEST_FUSED="#{libexec}/guest-fused"
      exec "#{libexec}/matchlock" "$@"
    SH
  end

  def post_install
    if OS.linux?
      system "sudo", bin/"matchlock", "setup", "linux"
    end
  end

  def caveats
    s = ""
    if OS.linux?
      s += <<~EOS
        If the post-install setup did not complete, run manually:
          sudo #{bin}/matchlock setup linux
      EOS
    end
    s
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/matchlock version")
  end
end
