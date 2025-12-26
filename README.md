# Homebrew Essentials

This is the official Homebrew tap for essential CLI tools by [@jingkaihe](https://github.com/jingkaihe).

## Installation

```bash
# Add the tap
brew tap jingkaihe/essentials

# Install tools
brew install waitrose
brew install icloud
```

Or install directly:

```bash
brew install jingkaihe/essentials/waitrose
brew install jingkaihe/essentials/icloud
```

## Available Formulas

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
brew upgrade waitrose icloud
```

## About

This tap is automatically maintained. Formulas are updated whenever new releases are published to their respective repositories.
