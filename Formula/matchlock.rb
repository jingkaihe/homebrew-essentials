class Matchlock < Formula
  desc "Lightweight micro-VM sandbox for running AI agents securely"
  homepage "https://github.com/jingkaihe/matchlock"
  version "0.1.19"
  license "MIT"

  depends_on "e2fsprogs"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.19/matchlock-darwin-arm64"
      sha256 "db20217c63632ba351453ccc3e53370e5e562adcaf9015ebabe52abe9305988f"

      resource "guest-agent" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.19/guest-agent-linux-arm64"
        sha256 "4f216b0b060ee6be3bf4d6b405a63b820de5a83ef273cee84488b9d7fa925fab"
      end

      resource "guest-fused" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.19/guest-fused-linux-arm64"
        sha256 "8cd9b2c9aa6702b40bea5e265d965f07734ecbfda9c9358d4e0818838df45cdf"
      end
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.19/matchlock-linux-arm64"
      sha256 "789a8e5661c916951f00314454aedad6ffb2119eacf806e54e94c1a1917d8075"

      resource "guest-agent" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.19/guest-agent-linux-arm64"
        sha256 "4f216b0b060ee6be3bf4d6b405a63b820de5a83ef273cee84488b9d7fa925fab"
      end

      resource "guest-fused" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.19/guest-fused-linux-arm64"
        sha256 "8cd9b2c9aa6702b40bea5e265d965f07734ecbfda9c9358d4e0818838df45cdf"
      end
    else
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.19/matchlock-linux-amd64"
      sha256 "caa7a319b7722925f55a928a1656b4181dc6b3d210df707e35e701b58fdbd802"

      resource "guest-agent" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.19/guest-agent-linux-amd64"
        sha256 "f22fea9918f018ee48805fec1a1b5f1114986918c3798233e994186a201bcc98"
      end

      resource "guest-fused" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.19/guest-fused-linux-amd64"
        sha256 "dbe2fb4976161ef20134bd7cbfa737130f9cf17d8ea68288b21b5799f212aee6"
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

    e2fsprogs = Formula["e2fsprogs"]
    (bin/"matchlock").write <<~SH
      #!/bin/bash
      export PATH="#{e2fsprogs.opt_bin}:#{e2fsprogs.opt_sbin}:$PATH"
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
