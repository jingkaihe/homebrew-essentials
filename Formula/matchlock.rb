class Matchlock < Formula
  desc "Lightweight micro-VM sandbox for running AI agents securely"
  homepage "https://github.com/jingkaihe/matchlock"
  version "0.2.16"
  license "MIT"

  depends_on "e2fsprogs"
  depends_on "erofs-utils"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.16/matchlock-darwin-arm64"
      sha256 "95b8c3897eaee53816d30f58f182a7d4e2e7cfc57eb7d5ef8674d57e130504fb"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.16/guest-init-linux-arm64"
        sha256 "cc06fd4d34adb667cc954e70f77fe9800d122223e9a4702170d49ba31b167282"
      end
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.16/matchlock-linux-arm64"
      sha256 "0761b072725ab57ce785c22ab1a63ad5a68a7951f3e4e05686c7a9c416afd843"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.16/guest-init-linux-arm64"
        sha256 "cc06fd4d34adb667cc954e70f77fe9800d122223e9a4702170d49ba31b167282"
      end
    else
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.16/matchlock-linux-amd64"
      sha256 "d355431e70d4c148921556b657d8cd633cf9782d48be26d855e01ac92a59ad2d"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.16/guest-init-linux-amd64"
        sha256 "40f6d951f444cd835229fa81ad2d45c9d3571d3e70b02283797de44d5afcda4e"
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
