# Omniwaifu Claude Code Plugins

Personal marketplace of Claude Code plugins.

## Plugins

### workforce-assistant

Behavioral nudges and automation to make Claude Code effectively use Serena's symbol-aware tools and Context7 library documentation. Features auto-activating skills, tool-restricted subagents, and behavioral hooks.

## Installation

This directory is configured as a local marketplace:

```bash
# Add marketplace
claude plugin marketplace add /mnt/data/Code/claude-plugins

# Install plugins
claude plugin install workforce-assistant
```

## Development

```bash
# Validate plugin
claude plugin validate ./workforce-assistant

# Add new plugins
# 1. Create plugin directory structure
# 2. Add to .claude-plugin/marketplace.json
# 3. Update marketplace: claude plugin marketplace update claude-plugins-local
```
