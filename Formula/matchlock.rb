class Matchlock < Formula
  desc "Lightweight micro-VM sandbox for running AI agents securely"
  homepage "https://github.com/jingkaihe/matchlock"
  version "0.2.7"
  license "MIT"

  depends_on "e2fsprogs"
  depends_on "erofs-utils"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.7/matchlock-darwin-arm64"
      sha256 "094355d162af3d99e06b35d21eb750cde9a53db346901ab444082a35e2a02ebe"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.7/guest-init-linux-arm64"
        sha256 "cddfe03aa6ea5cf641b8f8a5c4549b7b013387e3eb68f861048e01b8e33d9b9c"
      end
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.7/matchlock-linux-arm64"
      sha256 "b7f8996d9c5a86a6fc1c6494f9d8c6c1f8d94c563325f4d7caa48fe7bb4eb70e"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.7/guest-init-linux-arm64"
        sha256 "cddfe03aa6ea5cf641b8f8a5c4549b7b013387e3eb68f861048e01b8e33d9b9c"
      end
    else
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.7/matchlock-linux-amd64"
      sha256 "4202d857c12478fe1598bfa10fca04d8c03952e80cdc1c3f6fcac2976ce5b890"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.7/guest-init-linux-amd64"
        sha256 "143629bd79e5a67374efe5bda3d1e09f7c046ad740d3efce337a00ffb77896a7"
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
