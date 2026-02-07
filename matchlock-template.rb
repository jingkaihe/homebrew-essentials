class Matchlock < Formula
  desc "Lightweight micro-VM sandbox for running AI agents securely"
  homepage "https://github.com/jingkaihe/matchlock"
  version "{{VERSION}}"
  license "MIT"

  depends_on "e2fsprogs"

  on_macos do
    if Hardware::CPU.arm?
      resource "matchlock-bin" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v{{VERSION}}/matchlock-darwin-arm64"
        sha256 "{{SHA256_MATCHLOCK_DARWIN_ARM64}}"
      end

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
      resource "matchlock-bin" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v{{VERSION}}/matchlock-linux-arm64"
        sha256 "{{SHA256_MATCHLOCK_LINUX_ARM64}}"
      end

      resource "guest-agent" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v{{VERSION}}/guest-agent-linux-arm64"
        sha256 "{{SHA256_GUEST_AGENT_LINUX_ARM64}}"
      end

      resource "guest-fused" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v{{VERSION}}/guest-fused-linux-arm64"
        sha256 "{{SHA256_GUEST_FUSED_LINUX_ARM64}}"
      end
    else
      resource "matchlock-bin" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v{{VERSION}}/matchlock-linux-amd64"
        sha256 "{{SHA256_MATCHLOCK_LINUX_AMD64}}"
      end

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
    resource("matchlock-bin").stage { bin.install Dir["matchlock*"].first => "matchlock" }
    resource("guest-agent").stage { bin.install Dir["guest-agent*"].first => "guest-agent" }
    resource("guest-fused").stage { bin.install Dir["guest-fused*"].first => "guest-fused" }

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
      system "codesign", "--entitlements", entitlements, "-f", "-s", "-", bin/"matchlock"
    end
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/matchlock version")
  end
end
