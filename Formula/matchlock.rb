class Matchlock < Formula
  desc "Lightweight micro-VM sandbox for running AI agents securely"
  homepage "https://github.com/jingkaihe/matchlock"
  version "0.1.22"
  license "MIT"

  depends_on "e2fsprogs"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.22/matchlock-darwin-arm64"
      sha256 "775449b7102b2a4b400a2a83ff712a848fa41f9b8b712a4f0d50966c9498aa98"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.22/guest-init-linux-arm64"
        sha256 "3afc9ca793afe72198f2b7760f63a22d813e93794724b091b2f6075b3e6d8b1f"
      end
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.22/matchlock-linux-arm64"
      sha256 "51d1f1bc1ec9702a3f246846b6e178082269c2ece991cfdb8b600ebda09827ac"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.22/guest-init-linux-arm64"
        sha256 "3afc9ca793afe72198f2b7760f63a22d813e93794724b091b2f6075b3e6d8b1f"
      end
    else
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.22/matchlock-linux-amd64"
      sha256 "1d759453181ea61667f2443c24c919896dd03a0c2569545fa1055ca69683e3e8"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.22/guest-init-linux-amd64"
        sha256 "5321d16f837683a6b4dc0414aa5cce3a25675bafe54baa5590455ffaf37fed65"
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
