class Matchlock < Formula
  desc "Lightweight micro-VM sandbox for running AI agents securely"
  homepage "https://github.com/jingkaihe/matchlock"
  version "0.3.1"
  license "MIT"

  depends_on "e2fsprogs"
  depends_on "erofs-utils"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.3.1/matchlock-darwin-arm64"
      sha256 "0b3e7d21dc6aa9f9c5980ebf3b1e9414aae9cae51ae6b003615e18aa596855cc"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.3.1/guest-init-linux-arm64"
        sha256 "e451f349d92b23dc1a46277fc116437783e01e88325d896ea0f8ea3102028adf"
      end
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.3.1/matchlock-linux-arm64"
      sha256 "553481c34fab2bcaf74a0b15ab87df980eabf2d35b74e71f6bbd53b124521daf"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.3.1/guest-init-linux-arm64"
        sha256 "e451f349d92b23dc1a46277fc116437783e01e88325d896ea0f8ea3102028adf"
      end
    else
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.3.1/matchlock-linux-amd64"
      sha256 "b0633982e1e86d1096631690a199d10808062fc74aa45d5ed60754ae8fd2b499"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.3.1/guest-init-linux-amd64"
        sha256 "02c48940bce7012c2f364ea413d62aa5719cdb9c47fc0b444fbc5ae0aeefc419"
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
