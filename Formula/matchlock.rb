class Matchlock < Formula
  desc "Lightweight micro-VM sandbox for running AI agents securely"
  homepage "https://github.com/jingkaihe/matchlock"
  version "0.2.10"
  license "MIT"

  depends_on "e2fsprogs"
  depends_on "erofs-utils"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.10/matchlock-darwin-arm64"
      sha256 "a2ac453aaa4c0fa66e14e4e12854bae660e3e767e30cdd74f8ca6aed1905c9bc"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.10/guest-init-linux-arm64"
        sha256 "5c650f827e052f809a94776b317b5056806a6e0dec48a71232928f06de945e09"
      end
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.10/matchlock-linux-arm64"
      sha256 "8d4a5bd8aef935d8fd27dad08c4136dfdb4656e0c0eea26ea003fe2098747671"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.10/guest-init-linux-arm64"
        sha256 "5c650f827e052f809a94776b317b5056806a6e0dec48a71232928f06de945e09"
      end
    else
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.10/matchlock-linux-amd64"
      sha256 "960fa6ced21249a64587975f0395b68d8c7ef1f64e5b230fd489c639516f4c51"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.10/guest-init-linux-amd64"
        sha256 "dcdf9d7f0f3af5525b77e2f517ded0e01db94a76f721a65f1b557a0f3ca5791a"
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
