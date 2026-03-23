class Matchlock < Formula
  desc "Lightweight micro-VM sandbox for running AI agents securely"
  homepage "https://github.com/jingkaihe/matchlock"
  version "0.2.6"
  license "MIT"

  depends_on "e2fsprogs"
  depends_on "erofs-utils"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.6/matchlock-darwin-arm64"
      sha256 "b105594a207943feab552bdb2c953b551f1e9cb533a293e1029188fe1778c8aa"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.6/guest-init-linux-arm64"
        sha256 "f2aa27648a75ddeef513105440d101141fa2d86dff71dbe10c324c5573c0c152"
      end
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.6/matchlock-linux-arm64"
      sha256 "6c287f30625ac7c54759117334a650179a01f464e37c75c4438bb873d3f90fd4"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.6/guest-init-linux-arm64"
        sha256 "f2aa27648a75ddeef513105440d101141fa2d86dff71dbe10c324c5573c0c152"
      end
    else
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.6/matchlock-linux-amd64"
      sha256 "22dfa191e0da4e99f01d029f9b0326361aee44317524530ad0f78ab7487c9480"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.2.6/guest-init-linux-amd64"
        sha256 "ff8ca3f7ff69f0a05c23c0c35c5068a9043a5c213de9c158eb49816d827362a3"
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
