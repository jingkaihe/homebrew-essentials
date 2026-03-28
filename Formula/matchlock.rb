class Matchlock < Formula
  desc "Lightweight micro-VM sandbox for running AI agents securely"
  homepage "https://github.com/jingkaihe/matchlock"
  version "0.2.8"
  license "MIT"

  depends_on "e2fsprogs"
  depends_on "erofs-utils"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.8/matchlock-darwin-arm64"
      sha256 "cdb184be476793ab195c5aedc4e250f86a1b61ec858eddac8ce8001061ac5c6a"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.8/guest-init-linux-arm64"
        sha256 "5ab25ba20ca8dbbb47fe076f4536d1ffd156c393f0985409ce997bccbd277234"
      end
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.8/matchlock-linux-arm64"
      sha256 "a81557a83ecad2ef52735eb2817ff2d41100eaf00d8ff46525cbdcfbf5fac910"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.8/guest-init-linux-arm64"
        sha256 "5ab25ba20ca8dbbb47fe076f4536d1ffd156c393f0985409ce997bccbd277234"
      end
    else
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.8/matchlock-linux-amd64"
      sha256 "5e54cddb1d1ea421c9ff9ebe0785bf169d3cc1e1299bd951b50e7ef611085fdc"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.8/guest-init-linux-amd64"
        sha256 "2b79a6303e98e4b45b6a1501a585ceed586c0cc04395bdc6fbc416c854b0e1d7"
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
