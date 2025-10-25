# Omniwaifu Claude Code Plugins

Personal marketplace of Claude Code plugins.

## Plugins

### workforce-assistant

Automated hooks, task decomposition skills, and specialized agents. Integrates [Eigent](https://github.com/eigent-ai/eigent) patterns and [Serena](https://github.com/exa-labs/serena) symbol tools.

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
