class Matchlock < Formula
  desc "Lightweight micro-VM sandbox for running AI agents securely"
  homepage "https://github.com/jingkaihe/matchlock"
  version "0.1.5"
  license "MIT"

  depends_on "e2fsprogs"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.5/matchlock-darwin-arm64"
      sha256 "e111a4ca6f6111eecaf70d987a92173fff69631d79676e2f32c6798802c685cc"

      resource "guest-agent" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.5/guest-agent-linux-arm64"
        sha256 "f1515295e55bccae7751cdfa1fd76559a4ab6cc70fea1575582e11618dc3a9ef"
      end

      resource "guest-fused" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.5/guest-fused-linux-arm64"
        sha256 "aa7fe7d14fb321e2458b84456d021e85018e60c971bacdd85d83bef063e783a0"
      end
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.5/matchlock-linux-arm64"
      sha256 "d10a3c9bc18ae8c8df80cbecf7f4ada87117a5cdfa0afa203e815f11450fb354"

      resource "guest-agent" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.5/guest-agent-linux-arm64"
        sha256 "f1515295e55bccae7751cdfa1fd76559a4ab6cc70fea1575582e11618dc3a9ef"
      end

      resource "guest-fused" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.5/guest-fused-linux-arm64"
        sha256 "aa7fe7d14fb321e2458b84456d021e85018e60c971bacdd85d83bef063e783a0"
      end
    else
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.5/matchlock-linux-amd64"
      sha256 "e1fcc94115a8452f3f4cb8ffd790aae662dd52e140f44630e004e86843db10e6"

      resource "guest-agent" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.5/guest-agent-linux-amd64"
        sha256 "fb923aaf4bc1e5a2179b102e91a1ed0c7923bdea0d206739fd9886262b10e5b5"
      end

      resource "guest-fused" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.5/guest-fused-linux-amd64"
        sha256 "7cc5d15d20e00cfd20de682e76d3193cea94d82deb5c9cc935361ba09bfb842c"
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

    (bin/"matchlock").write <<~SH
      #!/bin/bash
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
