class Matchlock < Formula
  desc "Lightweight micro-VM sandbox for running AI agents securely"
  homepage "https://github.com/jingkaihe/matchlock"
  version "0.1.23"
  license "MIT"

  depends_on "e2fsprogs"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.23/matchlock-darwin-arm64"
      sha256 "798ef387ea4cf6de04b59a66d7ad268c9e5b782533be27e214ed45343cfccae9"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.23/guest-init-linux-arm64"
        sha256 "85aa3d499dccd5874d27e38adacca348d651e59c1d1e7a3ab6c39ba99009ca9a"
      end
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.23/matchlock-linux-arm64"
      sha256 "f2513033ed64578a9f5761dbbe21740b0b77209f932d1f43bb378f0126ca46bb"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.23/guest-init-linux-arm64"
        sha256 "85aa3d499dccd5874d27e38adacca348d651e59c1d1e7a3ab6c39ba99009ca9a"
      end
    else
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.23/matchlock-linux-amd64"
      sha256 "3f78c6b2db1bbc4a410d974033f4a3e6170332d460f148eb20d93deaa38e7fdc"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.23/guest-init-linux-amd64"
        sha256 "1793273562fba03fff108dd922860a4ac7867ecaa6c21262a4001e4f033c627b"
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
