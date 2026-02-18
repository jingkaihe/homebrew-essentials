class Matchlock < Formula
  desc "Lightweight micro-VM sandbox for running AI agents securely"
  homepage "https://github.com/jingkaihe/matchlock"
  version "0.1.20"
  license "MIT"

  depends_on "e2fsprogs"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.20/matchlock-darwin-arm64"
      sha256 "81e4341bba83976bea1d7db6a3487dd541ca9d6b018a5bed9c37406af0db7990"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.20/guest-init-linux-arm64"
        sha256 "550c41ef5c523f22e8a37e29e5b4d5d485a3cfdfce894802c7d831e3bf7a9731"
      end
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.20/matchlock-linux-arm64"
      sha256 "1ebcc6fa13f837507cdaa9a7485d4dd881cec056deccda2ddc3f5613ef4ae401"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.20/guest-init-linux-arm64"
        sha256 "550c41ef5c523f22e8a37e29e5b4d5d485a3cfdfce894802c7d831e3bf7a9731"
      end
    else
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.20/matchlock-linux-amd64"
      sha256 "a988c12b08e22e9a255e684ed72255ab20e979cab792772795812f32e77f9870"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.20/guest-init-linux-amd64"
        sha256 "8024dfcdeb84753198955994a8e0dcd6bbf8b4bc465be057924ea460e0853af3"
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
