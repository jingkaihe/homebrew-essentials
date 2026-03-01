class Matchlock < Formula
  desc "Lightweight micro-VM sandbox for running AI agents securely"
  homepage "https://github.com/jingkaihe/matchlock"
  version "0.1.29"
  license "MIT"

  depends_on "e2fsprogs"
  depends_on "erofs-utils"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.29/matchlock-darwin-arm64"
      sha256 "560c3969a86113b96698ba71734775d207db543ba37c55e7c6520f8d9754a9fd"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.29/guest-init-linux-arm64"
        sha256 "bbe9af35793c5dc48861acd769a7907f49a60bcfae6f16295fd63dbdd3f5aee8"
      end
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.29/matchlock-linux-arm64"
      sha256 "357f50f8f4ba204fe8cb66e2552126869c4840a912c78466122949a1a9376136"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.29/guest-init-linux-arm64"
        sha256 "bbe9af35793c5dc48861acd769a7907f49a60bcfae6f16295fd63dbdd3f5aee8"
      end
    else
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.29/matchlock-linux-amd64"
      sha256 "8af6f95f3a1e76ba1a7f9e81f95a1cd2f1dbb5559df922f704b8e50238ef014f"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.29/guest-init-linux-amd64"
        sha256 "84c182a6a31237fb34a89dc888a28570a4d67262286ec1b2b1c3a7b300b0ea86"
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
