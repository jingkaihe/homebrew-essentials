# Homebrew Essentials

This is the official Homebrew tap for essential CLI tools by [@jingkaihe](https://github.com/jingkaihe).

## Installation

```bash
# Add the tap
brew tap jingkaihe/essentials

# Install tools
brew install waitrose
brew install icloud
brew install google-workspace-mcp
```

Or install directly:

```bash
brew install jingkaihe/essentials/waitrose
brew install jingkaihe/essentials/icloud
brew install jingkaihe/essentials/google-workspace-mcp
```

## Available Formulas

### google-workspace-mcp

MCP server for Google Workspace services.

- **Repository**: https://github.com/jingkaihe/google-workspace-mcp
- **Usage**:
  ```bash
  google-workspace-mcp --help
  google-workspace-mcp version
  ```

### waitrose

Go client library and CLI for the Waitrose & Partners grocery API.

- **Repository**: https://github.com/jingkaihe/waitrose
- **Usage**:
  ```bash
  waitrose --help
  waitrose login -u email@example.com -p password
  waitrose trolley
  waitrose search "organic eggs"
  ```

### icloud

CLI for interacting with iCloud services.

- **Repository**: https://github.com/jingkaihe/icloud-cli
- **Usage**:
  ```bash
  icloud --help
  icloud login
  icloud calendar list
  icloud mail list
  ```

## Updating

To update to the latest versions:

```bash
brew update
brew upgrade waitrose icloud google-workspace-mcp
```

## About

This tap is automatically maintained. Formulas are updated whenever new releases are published to their respective repositories.
