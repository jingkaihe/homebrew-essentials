class Matchlock < Formula
  desc "Lightweight micro-VM sandbox for running AI agents securely"
  homepage "https://github.com/jingkaihe/matchlock"
  version "0.1.28"
  license "MIT"

  depends_on "e2fsprogs"
  depends_on "erofs-utils"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.28/matchlock-darwin-arm64"
      sha256 "fd60e518087deba5276d0277b7721494f5499884b7f6e27c85a573e99ea9aa16"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.28/guest-init-linux-arm64"
        sha256 "5180c4cd4f47c413d5cb83f31ba9c7ae7691ad10b0a818af3e708dcaee74055d"
      end
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.28/matchlock-linux-arm64"
      sha256 "ab6d4eeeffedead45c8316046f6bd47ebda52c152d35524a2bb96d9aa9fc94ae"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.28/guest-init-linux-arm64"
        sha256 "5180c4cd4f47c413d5cb83f31ba9c7ae7691ad10b0a818af3e708dcaee74055d"
      end
    else
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.28/matchlock-linux-amd64"
      sha256 "3148cd23825f612adce4c5ed9a0e2a92ce2693113d6760d426872f85aa64b10e"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.28/guest-init-linux-amd64"
        sha256 "b3c6a4b7d9e6d7506fc53e64fb09f02d034fe8108a881f06207d7d0a9ba33754"
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
