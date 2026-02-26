class Matchlock < Formula
  desc "Lightweight micro-VM sandbox for running AI agents securely"
  homepage "https://github.com/jingkaihe/matchlock"
  version "0.1.26"
  license "MIT"

  depends_on "e2fsprogs"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.26/matchlock-darwin-arm64"
      sha256 "5aa33cf636907130268ea1d933ed63fe3c923a7fb260af51601ea579068ec156"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.26/guest-init-linux-arm64"
        sha256 "b7bec4221c4682a8fd68b343a5149a1094de8b1700ef367ffb6d189d51f70176"
      end
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.26/matchlock-linux-arm64"
      sha256 "0b3ec8bc12013cc69ca4906f864fb8fe3337a424f0cee41747373ea53da4dd27"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.26/guest-init-linux-arm64"
        sha256 "b7bec4221c4682a8fd68b343a5149a1094de8b1700ef367ffb6d189d51f70176"
      end
    else
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.26/matchlock-linux-amd64"
      sha256 "005854979abf4638539f94e81bb31b06dd5f8ad3976a49b3062c066b04a9d017"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.26/guest-init-linux-amd64"
        sha256 "75d483e55e123778a70a58dd991b377b73dbf9b302e49deaa4502298d58fb7ab"
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
