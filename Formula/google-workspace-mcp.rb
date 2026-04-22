class GoogleWorkspaceMcp < Formula
  desc "MCP server for Google Workspace services"
  homepage "https://github.com/jingkaihe/google-workspace-mcp"
  version "0.1.4-beta"
  
  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/jingkaihe/google-workspace-mcp/releases/download/v0.1.4-beta/google-workspace-mcp-darwin-arm64"
      sha256 "dda78d93d172cac4fc448ac62a63e5874201e693ae8691adffe8148b72c2d99a"
    else
      url "https://github.com/jingkaihe/google-workspace-mcp/releases/download/v0.1.4-beta/google-workspace-mcp-darwin-amd64"
      sha256 "0dc5986373ab2ababf54dbacebb5809972739f492ab4b946310a553052e3a8e6"
    end
  end
  
  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/jingkaihe/google-workspace-mcp/releases/download/v0.1.4-beta/google-workspace-mcp-linux-arm64"
      sha256 "b818ced200a7634b50743b833d14476fccf2fea926e19c297f941f9f55a47ad7"
    else
      url "https://github.com/jingkaihe/google-workspace-mcp/releases/download/v0.1.4-beta/google-workspace-mcp-linux-amd64"
      sha256 "da05d5539dbb201e2a4243ffeeaa0eb42d7472b9360485076c546b8271a3c178"
    end
  end

  def install
    bin.install Dir["google-workspace-mcp*"].first => "google-workspace-mcp"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/google-workspace-mcp version")
  end
end
