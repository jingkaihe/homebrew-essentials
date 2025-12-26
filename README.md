# Homebrew Waitrose

This is the official Homebrew tap for [Waitrose CLI](https://github.com/jingkaihe/waitrose), a Go client library and CLI for the Waitrose & Partners grocery API.

## Installation

```bash
# Add the tap
brew tap jingkaihe/waitrose

# Install waitrose
brew install waitrose
```

Or install directly:

```bash
brew install jingkaihe/waitrose/waitrose
```

## Updating

To update to the latest version:

```bash
brew update
brew upgrade waitrose
```

## Usage

After installation, you can use waitrose:

```bash
waitrose --help
waitrose login -u email@example.com -p password
waitrose trolley
waitrose search "organic eggs"
```

## About

This tap is automatically maintained. The formula is updated whenever a new release is published to the main [waitrose repository](https://github.com/jingkaihe/waitrose).

For more information about waitrose, visit: https://github.com/jingkaihe/waitrose
