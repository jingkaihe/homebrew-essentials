class Matchlock < Formula
  desc "Lightweight micro-VM sandbox for running AI agents securely"
  homepage "https://github.com/jingkaihe/matchlock"
  version "{{VERSION}}"
  license "MIT"

  depends_on "e2fsprogs"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/jingkaihe/matchlock/releases/download/v{{VERSION}}/matchlock-darwin-arm64"
      sha256 "{{SHA256_MATCHLOCK_DARWIN_ARM64}}"

      resource "guest-agent" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v{{VERSION}}/guest-agent-linux-arm64"
        sha256 "{{SHA256_GUEST_AGENT_LINUX_ARM64}}"
      end

      resource "guest-fused" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v{{VERSION}}/guest-fused-linux-arm64"
        sha256 "{{SHA256_GUEST_FUSED_LINUX_ARM64}}"
      end
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/jingkaihe/matchlock/releases/download/v{{VERSION}}/matchlock-linux-arm64"
      sha256 "{{SHA256_MATCHLOCK_LINUX_ARM64}}"

      resource "guest-agent" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v{{VERSION}}/guest-agent-linux-arm64"
        sha256 "{{SHA256_GUEST_AGENT_LINUX_ARM64}}"
      end

      resource "guest-fused" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v{{VERSION}}/guest-fused-linux-arm64"
        sha256 "{{SHA256_GUEST_FUSED_LINUX_ARM64}}"
      end
    else
      url "https://github.com/jingkaihe/matchlock/releases/download/v{{VERSION}}/matchlock-linux-amd64"
      sha256 "{{SHA256_MATCHLOCK_LINUX_AMD64}}"

      resource "guest-agent" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v{{VERSION}}/guest-agent-linux-amd64"
        sha256 "{{SHA256_GUEST_AGENT_LINUX_AMD64}}"
      end

      resource "guest-fused" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v{{VERSION}}/guest-fused-linux-amd64"
        sha256 "{{SHA256_GUEST_FUSED_LINUX_AMD64}}"
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
