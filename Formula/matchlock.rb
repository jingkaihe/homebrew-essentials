class Matchlock < Formula
  desc "Lightweight micro-VM sandbox for running AI agents securely"
  homepage "https://github.com/jingkaihe/matchlock"
  version "0.1.12"
  license "MIT"

  depends_on "e2fsprogs"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.12/matchlock-darwin-arm64"
      sha256 "8db2d8474e6f61e9d8037e3ad6bc09aed2ae026f30e412fb9749d6c89989c277"

      resource "guest-agent" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.12/guest-agent-linux-arm64"
        sha256 "76963f0b2af44d0cee028404b3c11f60aae207e5e3891bccb4f63b5c7dcb9f83"
      end

      resource "guest-fused" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.12/guest-fused-linux-arm64"
        sha256 "58cf561ce22f2515e023385def4c2b007e9aaa8661754a57d4012004b92515e5"
      end
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.12/matchlock-linux-arm64"
      sha256 "f6c11f1342b11da9901dcd2f2815f57725df8065ba2ff677f265c88c95410d82"

      resource "guest-agent" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.12/guest-agent-linux-arm64"
        sha256 "76963f0b2af44d0cee028404b3c11f60aae207e5e3891bccb4f63b5c7dcb9f83"
      end

      resource "guest-fused" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.12/guest-fused-linux-arm64"
        sha256 "58cf561ce22f2515e023385def4c2b007e9aaa8661754a57d4012004b92515e5"
      end
    else
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.12/matchlock-linux-amd64"
      sha256 "e365258c2ae117f25dccf02364031d9ad1a514b964b8f1a66bad1fa8126988b5"

      resource "guest-agent" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.12/guest-agent-linux-amd64"
        sha256 "7ac7cb705ca671c1eff2e3157f7bc58a89ec4697e182e9d33a9664df10e55df9"
      end

      resource "guest-fused" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.12/guest-fused-linux-amd64"
        sha256 "e6173b62085060215afc9ba4b7c6f3d2ef26f043ce44d644f56852fe8ba4fb79"
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
