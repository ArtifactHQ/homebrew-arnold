# homebrew-arnold

Homebrew tap for [Arnold Pipeline](https://github.com/ArtifactHQ/Arnold-Prime) — AI-orchestrated software development.

## Installation

```bash
brew tap ArtifactHQ/arnold
brew install arnold
```

Or as a one-liner:

```bash
brew install ArtifactHQ/arnold/arnold
```

## Upgrade

```bash
brew upgrade arnold
```

## MCP Server (for Claude Code plugin)

```bash
brew services start arnold    # starts the MCP stdio server
brew services stop arnold     # stops the service
brew services info arnold     # check service status
```

## Data Locations

| Path | Purpose |
|------|---------|
| `~/.arnold_pipeline/pipeline.sqlite3` | Pipeline run database |
| `~/.arnold_pipeline/config.yml` | User configuration |

## Uninstall

```bash
brew services stop arnold     # stop the service first
brew uninstall arnold
brew untap ArtifactHQ/arnold
```

## Development

### Test the formula locally

```bash
brew install --build-from-source ./Formula/arnold.rb
brew test ./Formula/arnold.rb
brew audit --strict ./Formula/arnold.rb
```

### Release process

When a new Arnold Pipeline version is released, either:

1. **Automatic**: Pushing a `v*` tag to Arnold-Prime triggers the `bump-homebrew.yml` workflow which updates this formula
2. **Manual**: Update `Formula/arnold.rb` with the new tarball URL and SHA256
