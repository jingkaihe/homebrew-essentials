class Matchlock < Formula
  desc "Lightweight micro-VM sandbox for running AI agents securely"
  homepage "https://github.com/jingkaihe/matchlock"
  version "0.2.9"
  license "MIT"

  depends_on "e2fsprogs"
  depends_on "erofs-utils"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.9/matchlock-darwin-arm64"
      sha256 "70068cdfdeb3edeff8e48c5cc55a51170f82e3730eedb2206a5012c578da29ce"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.9/guest-init-linux-arm64"
        sha256 "d1a16bbb85b005b2df6e0780e2b4d23fe95a707cbc53fca9f9aee04dcbd586cb"
      end
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.9/matchlock-linux-arm64"
      sha256 "e47a3888addf50b562138372f93390e724addbb60b78798a6ed76ca69d9cc10f"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.9/guest-init-linux-arm64"
        sha256 "d1a16bbb85b005b2df6e0780e2b4d23fe95a707cbc53fca9f9aee04dcbd586cb"
      end
    else
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.9/matchlock-linux-amd64"
      sha256 "7037057c4e3a62ecfdcab2acf89cfd660a88f0c1a97c5a7ecfed8480dd6974e2"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.9/guest-init-linux-amd64"
        sha256 "4d2e6f62805e13c0ffe98068a4b2e8ccf7ed254f131196b39e93bc9c70bece01"
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
