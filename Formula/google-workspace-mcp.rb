class GoogleWorkspaceMcp < Formula
  desc "MCP server for Google Workspace services"
  homepage "https://github.com/jingkaihe/google-workspace-mcp"
  version "0.1.2-beta"
  
  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/jingkaihe/google-workspace-mcp/releases/download/v0.1.2-beta/google-workspace-mcp-darwin-arm64"
      sha256 "2ea943ba37f580c0971dd1c1e38913d0ce542fce99ac3e8f28f8998157bbf066"
    else
      url "https://github.com/jingkaihe/google-workspace-mcp/releases/download/v0.1.2-beta/google-workspace-mcp-darwin-amd64"
      sha256 "4e0a2c270e679cf647f39726e3c077bc6669771dad1c89cf3ed3b42f54d916d6"
    end
  end
  
  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/jingkaihe/google-workspace-mcp/releases/download/v0.1.2-beta/google-workspace-mcp-linux-arm64"
      sha256 "b6208347912a24da85c7f1a7c0971210d3c7fdca9f302eb3e393279a76fcbb40"
    else
      url "https://github.com/jingkaihe/google-workspace-mcp/releases/download/v0.1.2-beta/google-workspace-mcp-linux-amd64"
      sha256 "7de1a5c286e42723814e3ce714d80ab32815eb7a05158a2b4a0425b2291ef887"
    end
  end

  def install
    bin.install Dir["google-workspace-mcp*"].first => "google-workspace-mcp"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/google-workspace-mcp version")
  end
end
