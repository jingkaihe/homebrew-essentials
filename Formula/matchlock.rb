class Matchlock < Formula
  desc "Lightweight micro-VM sandbox for running AI agents securely"
  homepage "https://github.com/jingkaihe/matchlock"
  version "0.1.7"
  license "MIT"

  depends_on "e2fsprogs"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.7/matchlock-darwin-arm64"
      sha256 "ecbf0ac1d34ec4ec21db50a392e5aa19331fc903ea58eb376d5b4688349372f4"

      resource "guest-agent" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.7/guest-agent-linux-arm64"
        sha256 "9628dceb62bde69f65f9ccc72b4b0df825936f3a4f893c7e149d4cc784941ef9"
      end

      resource "guest-fused" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.7/guest-fused-linux-arm64"
        sha256 "1daf4ddd7e4f1565cd4a1391e32e27cbfbd9c24e6e001062b1d828f9c86f15d9"
      end
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.7/matchlock-linux-arm64"
      sha256 "ec4e1288057d4501aefb3785e6f36828a6253df78dcf8b255650b4c3ba417557"

      resource "guest-agent" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.7/guest-agent-linux-arm64"
        sha256 "9628dceb62bde69f65f9ccc72b4b0df825936f3a4f893c7e149d4cc784941ef9"
      end

      resource "guest-fused" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.7/guest-fused-linux-arm64"
        sha256 "1daf4ddd7e4f1565cd4a1391e32e27cbfbd9c24e6e001062b1d828f9c86f15d9"
      end
    else
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.7/matchlock-linux-amd64"
      sha256 "6ceb985b2457ff82b967e2ac93ac018aa7bbcbc9a343f9abc82bf8dba09c22ce"

      resource "guest-agent" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.7/guest-agent-linux-amd64"
        sha256 "38ae32b80455f0b8137cc2ce672f8169ba844ebf884a391abe8436e9e529e981"
      end

      resource "guest-fused" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.7/guest-fused-linux-amd64"
        sha256 "fe14329146de7e6b7b46b40bd3f650c63fff97d994ec004d43e1c400083ce8df"
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
