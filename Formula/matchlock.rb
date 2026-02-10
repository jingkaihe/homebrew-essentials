class Matchlock < Formula
  desc "Lightweight micro-VM sandbox for running AI agents securely"
  homepage "https://github.com/jingkaihe/matchlock"
  version "0.1.11"
  license "MIT"

  depends_on "e2fsprogs"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.11/matchlock-darwin-arm64"
      sha256 "01290ebc53fc0425674a8b992b29a0558da64badbc9f031c3e1c2ef204db69b1"

      resource "guest-agent" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.11/guest-agent-linux-arm64"
        sha256 "0c96358464c85d65eb0c06382c66a6f8e96ab26f8acd0a54472d1f09f5178fed"
      end

      resource "guest-fused" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.11/guest-fused-linux-arm64"
        sha256 "3d8b6df5ab7a943a59f7acc496471a823b57cdcfad936254f6099e08262cda68"
      end
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.11/matchlock-linux-arm64"
      sha256 "7f941815fe71c7dc72ba14c29d4f06a9329c48a15e23db866f8b685adc2b442e"

      resource "guest-agent" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.11/guest-agent-linux-arm64"
        sha256 "0c96358464c85d65eb0c06382c66a6f8e96ab26f8acd0a54472d1f09f5178fed"
      end

      resource "guest-fused" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.11/guest-fused-linux-arm64"
        sha256 "3d8b6df5ab7a943a59f7acc496471a823b57cdcfad936254f6099e08262cda68"
      end
    else
      url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.11/matchlock-linux-amd64"
      sha256 "1140cba63902426f683f724437cdb5dfce3be466dde3ba0c118aa40e72e70950"

      resource "guest-agent" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.11/guest-agent-linux-amd64"
        sha256 "3eb33ca8a5d1ede5530843720b867803e869ba5dbe61315bb445544cac06efb6"
      end

      resource "guest-fused" do
        url "https://github.com/jingkaihe/matchlock/releases/download/v0.1.11/guest-fused-linux-amd64"
        sha256 "50814be047dab16914e6a72c139c89777b62dfdf9ecfe375618d12ac89ddc74e"
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
