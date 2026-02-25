class Matchlock < Formula
  desc "Lightweight micro-VM sandbox for running AI agents securely"
  homepage "https://github.com/jingkaihe/matchlock"
  version "0.1.24"
  license "MIT"

  depends_on "e2fsprogs"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.24/matchlock-darwin-arm64"
      sha256 "3ae4f652c16d18a646ee19c8ec57377d56a85e3934670a246031e52dadc9baf8"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.24/guest-init-linux-arm64"
        sha256 "519c0124db2dc4115b1ef3e95b34b7d6be122a896b9760ce16a5597e9db66819"
      end
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.24/matchlock-linux-arm64"
      sha256 "99761925d47e42dc16b7ac0a383a207d58d91ffb0a99641fe659cf4e9f1be018"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.24/guest-init-linux-arm64"
        sha256 "519c0124db2dc4115b1ef3e95b34b7d6be122a896b9760ce16a5597e9db66819"
      end
    else
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.24/matchlock-linux-amd64"
      sha256 "e7693ada07d20c6edad92ddfa836993c6c9f6057d8400a0ab44f6682193eceaa"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.24/guest-init-linux-amd64"
        sha256 "b2268180b3da7d5e45a9dfb6e3b94631958b530d6acf618d985e37be9be89447"
      end
    end
  end

  def install
    libexec.install Dir["matchlock*"].first => "matchlock"
    resource("guest-init").stage { libexec.install Dir["guest-init*"].first => "guest-init" }
    chmod 0755, libexec/"matchlock"
    chmod 0755, libexec/"guest-init"

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
      export MATCHLOCK_GUEST_INIT="#{libexec}/guest-init"
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
