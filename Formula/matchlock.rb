class Matchlock < Formula
  desc "Lightweight micro-VM sandbox for running AI agents securely"
  homepage "https://github.com/jingkaihe/matchlock"
  version "0.1.4"
  license "MIT"

  depends_on "e2fsprogs"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.4/matchlock-darwin-arm64"
      sha256 "a0f0b0b2f464fe129f60c8910b39f57c2ec13f998971d72a4a3b5e991cec8d24"

      resource "guest-agent" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.4/guest-agent-linux-arm64"
        sha256 "cf7105668f664d978c6729228266bb4d9745d8a1e8e00dbc92b3b8b08c43fe8c"
      end

      resource "guest-fused" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.4/guest-fused-linux-arm64"
        sha256 "3fb16be178b96e47d142a5a28613514ca88d86dfcc56c82076fef5db8cbc1119"
      end
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.4/matchlock-linux-arm64"
      sha256 "6d493b2a32b5161f0df089cad38326b2a3b882e3339ea1a61c0621408b8a5bf2"

      resource "guest-agent" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.4/guest-agent-linux-arm64"
        sha256 "cf7105668f664d978c6729228266bb4d9745d8a1e8e00dbc92b3b8b08c43fe8c"
      end

      resource "guest-fused" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.4/guest-fused-linux-arm64"
        sha256 "3fb16be178b96e47d142a5a28613514ca88d86dfcc56c82076fef5db8cbc1119"
      end
    else
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.4/matchlock-linux-amd64"
      sha256 "3859f4d58e3ef441007b521724ac84511e26d3d11b62ebc422c23507de991d0a"

      resource "guest-agent" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.4/guest-agent-linux-amd64"
        sha256 "d385366f8b7672f3ffb66200e1cb68b9d218e78c7c55daa291c95b20c6c23193"
      end

      resource "guest-fused" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.4/guest-fused-linux-amd64"
        sha256 "ce3b81e93a35e6e770c3806454c76fd917569d56e957d3a25e76589e49393d58"
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
