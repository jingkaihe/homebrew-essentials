class Matchlock < Formula
  desc "Lightweight micro-VM sandbox for running AI agents securely"
  homepage "https://github.com/jingkaihe/matchlock"
  version "0.2.15"
  license "MIT"

  depends_on "e2fsprogs"
  depends_on "erofs-utils"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.15/matchlock-darwin-arm64"
      sha256 "ab7e3cf66d59ffb976da69f8643599a7c6f621162a07f7f681810dbf77ebc9fb"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.15/guest-init-linux-arm64"
        sha256 "e649757bd70a6dabceda97f30baa1c99169f84dc8a74b86fd520b7b74e57201b"
      end
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.15/matchlock-linux-arm64"
      sha256 "29ca834615b052e69b85d2209fb9343e8cb63f75fea6cb7aaa3dbbc6303cfb67"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.15/guest-init-linux-arm64"
        sha256 "e649757bd70a6dabceda97f30baa1c99169f84dc8a74b86fd520b7b74e57201b"
      end
    else
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.15/matchlock-linux-amd64"
      sha256 "3c3e3fe5ee43046241afed8632960b9af5b0f76d7a281c526beaed1b25ecc65f"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.15/guest-init-linux-amd64"
        sha256 "00f08228f55e9db2708fe929509751a1f5e398436210c2c9cf222ced88c2f562"
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
    erofs_utils = Formula["erofs-utils"]
    (bin/"matchlock").write <<~SH
      #!/bin/bash
      export PATH="#{e2fsprogs.opt_bin}:#{e2fsprogs.opt_sbin}:#{erofs_utils.opt_bin}:$PATH"
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
