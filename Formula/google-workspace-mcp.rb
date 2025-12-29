class GoogleWorkspaceMcp < Formula
  desc "MCP server for Google Workspace services"
  homepage "https://github.com/jingkaihe/google-workspace-mcp"
  version "0.1.1-beta"
  
  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/jingkaihe/google-workspace-mcp/releases/download/v0.1.1-beta/google-workspace-mcp-darwin-arm64"
      sha256 "06269a11740ef5e198a2aa3697bd7edd3abe79855fd7b6bce76f34ef7f4473b6"
    else
      url "https://github.com/jingkaihe/google-workspace-mcp/releases/download/v0.1.1-beta/google-workspace-mcp-darwin-amd64"
      sha256 "d713d552166ed0f6a62e090a84eabc3b5f4153f9eb3eb0d2f6242ebbf4efe54e"
    end
  end
  
  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/jingkaihe/google-workspace-mcp/releases/download/v0.1.1-beta/google-workspace-mcp-linux-arm64"
      sha256 "124a0f8ed118637ea69b406ecb06fdc1a8134411691083642d6394a866d7df55"
    else
      url "https://github.com/jingkaihe/google-workspace-mcp/releases/download/v0.1.1-beta/google-workspace-mcp-linux-amd64"
      sha256 "64d9d10eb68d0aa49a03ea5b1265c573f4018414c0836288c8bc4bb0721bc970"
    end
  end

  def install
    bin.install Dir["google-workspace-mcp*"].first => "google-workspace-mcp"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/google-workspace-mcp version")
  end
end
