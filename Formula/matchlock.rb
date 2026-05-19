class Matchlock < Formula
  desc "Lightweight micro-VM sandbox for running AI agents securely"
  homepage "https://github.com/jingkaihe/matchlock"
  version "0.2.13"
  license "MIT"

  depends_on "e2fsprogs"
  depends_on "erofs-utils"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.13/matchlock-darwin-arm64"
      sha256 "ac119787afb9bdf303599cf233a0c062cc02d9db2c251cbdb5a0d9ae0b1b21db"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.13/guest-init-linux-arm64"
        sha256 "5d0482c4912513a34dafaf804b3684b3500ffa8a1dfb33d950363d6f0b7593a2"
      end
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.13/matchlock-linux-arm64"
      sha256 "38c318aa348dbc0207d105315bd828b12c85891595a995944dca812ade13d54d"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.13/guest-init-linux-arm64"
        sha256 "5d0482c4912513a34dafaf804b3684b3500ffa8a1dfb33d950363d6f0b7593a2"
      end
    else
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.13/matchlock-linux-amd64"
      sha256 "035b64d6e810c9d965549d5d0e346269e829bb2f239a6f692e3b6af5fda99081"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.13/guest-init-linux-amd64"
        sha256 "5f8637f12fa0c9bd80d19e3be1c4f5560d1c42673615ab44974857a93ce6e3b5"
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
