class Matchlock < Formula
  desc "Lightweight micro-VM sandbox for running AI agents securely"
  homepage "https://github.com/jingkaihe/matchlock"
  version "0.1.10"
  license "MIT"

  depends_on "e2fsprogs"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.10/matchlock-darwin-arm64"
      sha256 "46bb1d5f195b7aef4b7c344ff1e325f615c293606bd10601405fbff6ed26c603"

      resource "guest-agent" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.10/guest-agent-linux-arm64"
        sha256 "3f65f872d01a52549138895b734fcffcdf32aca241cb510bdb5a7da52b6d9b45"
      end

      resource "guest-fused" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.10/guest-fused-linux-arm64"
        sha256 "76a64602930f7266e17c852b3bad21b54082854fec83202f3b4b2417cbb6e385"
      end
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.10/matchlock-linux-arm64"
      sha256 "ec118965f3125e2c39dc77e763e0dca2b89c410468a73a326d5bd3aea2fbee51"

      resource "guest-agent" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.10/guest-agent-linux-arm64"
        sha256 "3f65f872d01a52549138895b734fcffcdf32aca241cb510bdb5a7da52b6d9b45"
      end

      resource "guest-fused" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.10/guest-fused-linux-arm64"
        sha256 "76a64602930f7266e17c852b3bad21b54082854fec83202f3b4b2417cbb6e385"
      end
    else
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.10/matchlock-linux-amd64"
      sha256 "04f4aa7cb68b2d8f3478713e878cd31f9b41bf551fbcb6a7755b419a113b5ac8"

      resource "guest-agent" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.10/guest-agent-linux-amd64"
        sha256 "68c4f996c9505df5c884c06e7014647edb57ce190c3d12fc4572669a6c4364d9"
      end

      resource "guest-fused" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.10/guest-fused-linux-amd64"
        sha256 "03cce7617e0e6c48030ac47c981c02fde20da437ee7edb2df9ae50f46c1baab6"
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
