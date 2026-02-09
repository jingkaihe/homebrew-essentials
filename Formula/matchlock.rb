class Matchlock < Formula
  desc "Lightweight micro-VM sandbox for running AI agents securely"
  homepage "https://github.com/jingkaihe/matchlock"
  version "0.1.8"
  license "MIT"

  depends_on "e2fsprogs"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.8/matchlock-darwin-arm64"
      sha256 "82ec3d62831174139871ff32a1de7747b3fa40d1e82c793150913c6fa1423b11"

      resource "guest-agent" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.8/guest-agent-linux-arm64"
        sha256 "6d597de8cb314993cfe4d729933d0357efda2d1c441d1464bca547f8ffc69043"
      end

      resource "guest-fused" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.8/guest-fused-linux-arm64"
        sha256 "29acf38fe47be67f77023969c9260a4be84e0f73621761b445643cfe090e623a"
      end
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.8/matchlock-linux-arm64"
      sha256 "43a84bd055677cd81a4fb90b146e134012d06c42bbf32a7a4e44fa51681532ef"

      resource "guest-agent" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.8/guest-agent-linux-arm64"
        sha256 "6d597de8cb314993cfe4d729933d0357efda2d1c441d1464bca547f8ffc69043"
      end

      resource "guest-fused" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.8/guest-fused-linux-arm64"
        sha256 "29acf38fe47be67f77023969c9260a4be84e0f73621761b445643cfe090e623a"
      end
    else
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.8/matchlock-linux-amd64"
      sha256 "1249f95cb88734c4ffa5c1d91ec2d8062f030c0e3ef3cf3c6b011cd5c5f94237"

      resource "guest-agent" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.8/guest-agent-linux-amd64"
        sha256 "354040aa2b144aed421dc6b1a7ef3fd50f575ab34ef598bb39bd89f7295bb226"
      end

      resource "guest-fused" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.8/guest-fused-linux-amd64"
        sha256 "48b4ce6771a46b964e5d7113450041266fab64f51b025be8b0f708e70d53d55d"
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
