class Matchlock < Formula
  desc "Lightweight micro-VM sandbox for running AI agents securely"
  homepage "https://github.com/jingkaihe/matchlock"
  version "0.2.1"
  license "MIT"

  depends_on "e2fsprogs"
  depends_on "erofs-utils"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.1/matchlock-darwin-arm64"
      sha256 "8dce726791663d3307224d9b772bca4f700fb012ab74a3d67c638ae83369c2f1"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.1/guest-init-linux-arm64"
        sha256 "50bb4f6bbd8975be260914accac9a9c4a25cdbcce287ed80add77652f0254267"
      end
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.1/matchlock-linux-arm64"
      sha256 "c0cd9cb2dbc11bafeb32c4cd67d8513d48a4e58e479d0ca6c9f6072ccf6cb782"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.1/guest-init-linux-arm64"
        sha256 "50bb4f6bbd8975be260914accac9a9c4a25cdbcce287ed80add77652f0254267"
      end
    else
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.1/matchlock-linux-amd64"
      sha256 "f04e870f5cd44bafd3c476cd841b84abb6e6f2c624214cdb78674e620e635fc4"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.1/guest-init-linux-amd64"
        sha256 "c541512ce9ceb126699c014de9f366d79183d9a35df3f25358d1c1dcd5fcbaa9"
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
