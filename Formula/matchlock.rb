class Matchlock < Formula
  desc "Lightweight micro-VM sandbox for running AI agents securely"
  homepage "https://github.com/jingkaihe/matchlock"
  version "0.1.25"
  license "MIT"

  depends_on "e2fsprogs"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.25/matchlock-darwin-arm64"
      sha256 "717de09e2b6c69564ddb244e252414ac179065c4de045b8d3a5ea9f6f2d67fc3"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.25/guest-init-linux-arm64"
        sha256 "bd7e465d511355b85240d64be27a3f846dd1e3a2d9b275e6d5c088bd35206333"
      end
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.25/matchlock-linux-arm64"
      sha256 "12819ce17e92e7a6af42a690eb1f635db49d5b1359866ee06df3a1a9dd377d41"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.25/guest-init-linux-arm64"
        sha256 "bd7e465d511355b85240d64be27a3f846dd1e3a2d9b275e6d5c088bd35206333"
      end
    else
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.25/matchlock-linux-amd64"
      sha256 "6cf91551b85f8762fa087783c2d292456161d8a647f82830f1ef392a56428537"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.25/guest-init-linux-amd64"
        sha256 "5c417eefa4c27a1ec417ba2cf97aa1d5aa92cc2bc6759afdfc4eeb01b6a1645b"
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
