class Matchlock < Formula
  desc "Lightweight micro-VM sandbox for running AI agents securely"
  homepage "https://github.com/jingkaihe/matchlock"
  version "{{VERSION}}"
  license "MIT"

  depends_on "e2fsprogs"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/jingkaihe/matchlock/releases/download/v{{VERSION}}/matchlock-darwin-arm64"
      sha256 "{{SHA256_MATCHLOCK_DARWIN_ARM64}}"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v{{VERSION}}/guest-init-linux-arm64"
        sha256 "{{SHA256_GUEST_INIT_LINUX_ARM64}}"
      end
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/jingkaihe/matchlock/releases/download/v{{VERSION}}/matchlock-linux-arm64"
      sha256 "{{SHA256_MATCHLOCK_LINUX_ARM64}}"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v{{VERSION}}/guest-init-linux-arm64"
        sha256 "{{SHA256_GUEST_INIT_LINUX_ARM64}}"
      end
    else
      url "https://github.com/jingkaihe/matchlock/releases/download/v{{VERSION}}/matchlock-linux-amd64"
      sha256 "{{SHA256_MATCHLOCK_LINUX_AMD64}}"

      resource "guest-init" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v{{VERSION}}/guest-init-linux-amd64"
        sha256 "{{SHA256_GUEST_INIT_LINUX_AMD64}}"
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
