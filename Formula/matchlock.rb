class Matchlock < Formula
  desc "Lightweight micro-VM sandbox for running AI agents securely"
  homepage "https://github.com/jingkaihe/matchlock"
  version "0.1.27"
  license "MIT"

  depends_on "e2fsprogs"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.27/matchlock-darwin-arm64"
      sha256 "a3f2121ddffafdc215f8a785940dc064599b7ac041a688df7268d12df848eb84"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.27/guest-init-linux-arm64"
        sha256 "582005d126d764b8cdad26d619385944796a39fadfd340b38f128b073ed36abb"
      end
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.27/matchlock-linux-arm64"
      sha256 "a79c11b721e38fa49661ffa0783dc4a85247efe2232c6b896059005fbbad6def"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.27/guest-init-linux-arm64"
        sha256 "582005d126d764b8cdad26d619385944796a39fadfd340b38f128b073ed36abb"
      end
    else
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.27/matchlock-linux-amd64"
      sha256 "d4078ac5e0531e46f658144cc3300d8e2d2bd33671c0f8ebb01bbd1face21f6f"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.27/guest-init-linux-amd64"
        sha256 "e47d6b11816158619412d55f46303fc45d27665433b71db1b6a9204929c06733"
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
