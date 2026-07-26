class Matchlock < Formula
  desc "Lightweight micro-VM sandbox for running AI agents securely"
  homepage "https://github.com/jingkaihe/matchlock"
  version "0.2.17"
  license "MIT"

  depends_on "e2fsprogs"
  depends_on "erofs-utils"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.17/matchlock-darwin-arm64"
      sha256 "344556da6d5ad341d966fb4e0c72ab9fd26ad2bddf42b2615942ac498771caab"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.17/guest-init-linux-arm64"
        sha256 "0223aa74bee8f1f0196a3b4eb0d997e3fea42646b6b069bc6853000f46270ce2"
      end
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.17/matchlock-linux-arm64"
      sha256 "0f117f98d4b5e06e6546f2ccc020ea1c09483ce717b9e514208e4ab734817d73"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.17/guest-init-linux-arm64"
        sha256 "0223aa74bee8f1f0196a3b4eb0d997e3fea42646b6b069bc6853000f46270ce2"
      end
    else
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.17/matchlock-linux-amd64"
      sha256 "f3633d1a9e93ad9ad2467bd590369c21e7e4358b1c195d69584e4583e0161d22"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.17/guest-init-linux-amd64"
        sha256 "35a13def98b37e7402a905f8d33c3d3df7a20dbf55789372ac4894074e78ed61"
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
