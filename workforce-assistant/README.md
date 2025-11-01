# Workforce Assistant

Behavioral nudges and automation to make Claude Code effectively use Serena's symbol-aware tools and Context7 library documentation.

## What This Plugin Does

**Problem:** Claude often falls back to basic tools (Read/Grep) instead of using Serena's powerful symbol navigation, and forgets to persist discoveries to memory.

**Solution:** Automated behavioral nudges at key decision points:
- SessionStart: Auto-prompts Serena activation and memory loading
- PreToolUse: Suggests symbol tools when about to Read code files or Grep for code
- PostToolUse: Reminds to write_memory() after research or symbol exploration

## Features

### 1. Auto-Activating Skills
Skills trigger automatically based on context (no manual invocation needed):
- `serena-project-activator` - Activates Serena and runs onboarding
- `serena-symbol-navigator` - Use symbol tools instead of Read/Grep
- `library-docs-fetcher` - Query Context7 for library docs
- `safe-refactoring-workflow` - Find → Verify → Refactor → Test pattern
- `systematic-codebase-explorer` - Onboarding-first exploration
- `task-breakdown-specialist` - Break complex tasks into subtasks
- `structured-completion-reporter` - Format task completion reports
- `citation-discipline-enforcer` - Enforce URL sourcing policy

### 2. Tool-Restricted Subagents
Specialized agents with constrained tool access:
- `code-archeologist` - Read-only analysis (no Write/Edit)
- `implementation-engineer` - Full editing with symbol-aware refactoring
- `research-specialist` - WebFetch/Context7 only (no file editing)
- `document-architect` - Documentation writing with code analysis

### 3. Behavioral Nudge Hooks
Automatic reminders at decision points:
- **SessionStart** → Activate Serena + load memories
- **PreToolUse(Read)** → Suggest get_symbols_overview for code files
- **PreToolUse(Grep)** → Suggest find_symbol for code searches
- **PostToolUse(WebFetch/WebSearch/Context7)** → Prompt write_memory()
- **PostToolUse(Symbol Tools)** → After 5+ calls, suggest memory write
- **PostToolUse(check_onboarding)** → Auto-suggest loading memories
- **PreToolUse(Bash)** → Safe mode validation for destructive commands

## Installation

```bash
# Add this plugin's marketplace
claude plugin marketplace add ./

# Install the plugin
claude plugin install workforce-assistant@omniwaifu-claude-plugins-local
```

## Requirements

**Serena MCP (required):**
```bash
claude mcp add serena -- uvx --from git+https://github.com/oraios/serena \
  serena start-mcp-server --context ide-assistant --project "$(pwd)"
```

**Context7 (optional but recommended):**
```bash
claude mcp add context7 -- npx -y @context7/mcp-server
```

## Quick Start

1. Install plugin (above)
2. In any code project, run `/workspace-init` to activate Serena
3. Hooks automatically nudge Claude to use symbol tools and persist discoveries

## How It Works

### Skills Auto-Activate
When you ask questions matching skill descriptions, Claude automatically gets those skill prompts. For example:
- "How does authentication work?" → `systematic-codebase-explorer` activates
- "Refactor the User class" → `safe-refactoring-workflow` activates
- "Find all uses of this function" → `serena-symbol-navigator` activates

### Hooks Nudge Behavior
At key moments, hooks inject reminders:
- About to `Read src/auth.py`? → "Consider get_symbols_overview() first"
- Just did `WebFetch` for React docs? → "Consider write_memory('library-docs-react-hooks', ...)"
- Made 5+ symbol exploration calls? → "Consider documenting discoveries"

### Agents Provide Constraints
Invoke agents explicitly for specialized workflows:
- `@code-archeologist` → Explore code without risk of accidental edits
- `@research-specialist` → Research with enforced citation discipline
- `@implementation-engineer` → Implement with symbol-aware refactoring

## Architecture

```
workforce-assistant/
├── skills/              # Auto-activating behavioral guides (~50 lines each)
├── agents/              # Tool-restricted subagents (~50 lines each)
├── hooks/               # Behavioral nudge hooks (~30 lines each)
├── commands/            # Slash commands (/workspace-init)
└── .claude-plugin/      # Plugin metadata
```

## Philosophy

**Do, Don't Teach:**
- Hooks automate at decision points
- Skills provide concise context when relevant
- Agents enforce constraints through tool restrictions
- No verbose tutorials or teaching materials

**Lean into Serena:**
- Symbol tools over Read/Grep for code
- write_memory() for cross-session persistence
- onboarding() for systematic exploration
- Context7 for library documentation

## Version

1.2.0 - Pure automation focus

## License

MIT
