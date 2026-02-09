class Matchlock < Formula
  desc "Lightweight micro-VM sandbox for running AI agents securely"
  homepage "https://github.com/jingkaihe/matchlock"
  version "0.1.9"
  license "MIT"

  depends_on "e2fsprogs"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.9/matchlock-darwin-arm64"
      sha256 "e6e49f2ffeda836fabfb3c50577bf6b0814ea445ba4b7c4295efbecb1ee7485c"

      resource "guest-agent" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.9/guest-agent-linux-arm64"
        sha256 "cc2481cadb671882cab8bfc1953896c889865019e34b6302241ad4b17b1a7369"
      end

      resource "guest-fused" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.9/guest-fused-linux-arm64"
        sha256 "5b7dd8526bcbc8d9df96e49f5475060dbd0c468b299cab3a9fec48305b53719b"
      end
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.9/matchlock-linux-arm64"
      sha256 "3c458230f5ab2cace86bdd6529c092bdee7e34000c6847de7892f2b5251647dd"

      resource "guest-agent" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.9/guest-agent-linux-arm64"
        sha256 "cc2481cadb671882cab8bfc1953896c889865019e34b6302241ad4b17b1a7369"
      end

      resource "guest-fused" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.9/guest-fused-linux-arm64"
        sha256 "5b7dd8526bcbc8d9df96e49f5475060dbd0c468b299cab3a9fec48305b53719b"
      end
    else
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.9/matchlock-linux-amd64"
      sha256 "95eea05ad4709755c4b13e7267803c2df1f07cc90ffa0ce2b34754bb3c4e4bb6"

      resource "guest-agent" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.9/guest-agent-linux-amd64"
        sha256 "2213f180258b9cb38cd2fcf2e772c780158304434c241d1397c96aa977ed1123"
      end

      resource "guest-fused" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.9/guest-fused-linux-amd64"
        sha256 "2b0c3ff74fbf61546770a141f0acc56c591d4da48d961e772a3f8cb65d359dee"
      end
    end
  end

  def install
    libexec.install Dir["matchlock*"].first => "matchlock"
    resource("guest-agent").stage { libexec.install Dir["guest-agent*"].first => "guest-agent" }
    resource("guest-fused").stage { libexec.install Dir["guest-fused*"].first => "guest-fused" }
    chmod 0755, libexec/"matchlock"
    chmod 0755, libexec/"guest-agent"
    chmod 0755, libexec/"guest-fused"

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
      export MATCHLOCK_GUEST_AGENT="#{libexec}/guest-agent"
      export MATCHLOCK_GUEST_FUSED="#{libexec}/guest-fused"
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
