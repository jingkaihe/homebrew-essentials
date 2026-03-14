class Matchlock < Formula
  desc "Lightweight micro-VM sandbox for running AI agents securely"
  homepage "https://github.com/jingkaihe/matchlock"
  version "0.2.5"
  license "MIT"

  depends_on "e2fsprogs"
  depends_on "erofs-utils"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.5/matchlock-darwin-arm64"
      sha256 "b91f7717d3df7a31df340dba361cb39d1042bd63daf0c18d7207fd2d2f08aeb7"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.5/guest-init-linux-arm64"
        sha256 "0fac653af5dcddd83f2684f5071229496f47e3a777baccd88c0208b65bde4eb0"
      end
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.5/matchlock-linux-arm64"
      sha256 "3c7204252586d02664a75b205080b4159bf8d4da47b245edf01861eee15069a3"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.5/guest-init-linux-arm64"
        sha256 "0fac653af5dcddd83f2684f5071229496f47e3a777baccd88c0208b65bde4eb0"
      end
    else
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.5/matchlock-linux-amd64"
      sha256 "9371969be04d36a0c3f78b794064b1eb5681db8ce7353b979457bd24c0e73e6f"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.5/guest-init-linux-amd64"
        sha256 "342008595d406cb7a04ea56a50399222361e0d7c8c6def7c69eb88f1a308f740"
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
