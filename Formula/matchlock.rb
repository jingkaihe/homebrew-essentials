class Matchlock < Formula
  desc "Lightweight micro-VM sandbox for running AI agents securely"
  homepage "https://github.com/jingkaihe/matchlock"
  version "0.1.2"
  license "MIT"

  depends_on "e2fsprogs"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.2/matchlock-darwin-arm64"
      sha256 "8189bc666395208fa81aaa5dae7c04d7069056fb0dc94a941c5e88d696b52491"

      resource "guest-agent" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.2/guest-agent-linux-arm64"
        sha256 "46bc9cfb250b05e8e52d06b1c01f6d9564b91a03b651781755100be9c1a892a4"
      end

      resource "guest-fused" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.2/guest-fused-linux-arm64"
        sha256 "61cc84cccf4e123dcc0ad34d58a2672568940eaf4e2d83a3c6553b533af0eef9"
      end
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.2/matchlock-linux-arm64"
      sha256 "f5c706482cc687bab726bfc1d61ea5aa191f2ba0d984e5295714baac017a6a4b"

      resource "guest-agent" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.2/guest-agent-linux-arm64"
        sha256 "46bc9cfb250b05e8e52d06b1c01f6d9564b91a03b651781755100be9c1a892a4"
      end

      resource "guest-fused" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.2/guest-fused-linux-arm64"
        sha256 "61cc84cccf4e123dcc0ad34d58a2672568940eaf4e2d83a3c6553b533af0eef9"
      end
    else
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.2/matchlock-linux-amd64"
      sha256 "e7e9f68d068ca31229d4b53a3870cec6bf3c86ba78b637541fdbe76cd88946aa"

      resource "guest-agent" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.2/guest-agent-linux-amd64"
        sha256 "9fcb38974930d0ea31c1452d54b5e733033fdcbf74b2242dad03c8d6aec1b96e"
      end

      resource "guest-fused" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.2/guest-fused-linux-amd64"
        sha256 "637d391ad460f50e69e7c78c1e52ae371ade3a634bce9d8b0ce3c93a610b1796"
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
