class GoogleWorkspaceMcp < Formula
  desc "MCP server for Google Workspace services"
  homepage "https://github.com/jingkaihe/google-workspace-mcp"
  version "{{VERSION}}"
  
  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/jingkaihe/google-workspace-mcp/releases/download/v{{VERSION}}/google-workspace-mcp-darwin-arm64"
      sha256 "{{SHA256_DARWIN_ARM64}}"
    else
      url "https://github.com/jingkaihe/google-workspace-mcp/releases/download/v{{VERSION}}/google-workspace-mcp-darwin-amd64"
      sha256 "{{SHA256_DARWIN_AMD64}}"
    end
  end
  
  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/jingkaihe/google-workspace-mcp/releases/download/v{{VERSION}}/google-workspace-mcp-linux-arm64"
      sha256 "{{SHA256_LINUX_ARM64}}"
    else
      url "https://github.com/jingkaihe/google-workspace-mcp/releases/download/v{{VERSION}}/google-workspace-mcp-linux-amd64"
      sha256 "{{SHA256_LINUX_AMD64}}"
    end
  end

  def install
    bin.install Dir["google-workspace-mcp*"].first => "google-workspace-mcp"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/google-workspace-mcp version")
  end
end
