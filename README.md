# Claude Code Plugins

Personal collection of Claude Code plugins.

## Plugins

### workforce-assistant
Eigent-inspired multi-agent patterns for Claude Code, emphasizing automation over manual commands.

**Key Features:**
- Automated tool usage logging and research capture
- Safe mode validation for destructive commands
- Context checkpointing and session reporting
- Task decomposition and structured results
- Specialized workforce agents (research, implementation, documentation)

See [workforce-assistant/README.md](./workforce-assistant/README.md) for details.

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
