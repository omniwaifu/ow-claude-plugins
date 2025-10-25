# Workforce Assistant Plugin

Multi-agent patterns for Claude Code that teaches effective use of [Serena](https://github.com/oraios/serena)'s LSP-based symbol tools combined with [Eigent](https://github.com/eigent-ai/eigent)-inspired workforce patterns.

## Prerequisites

**THIS PLUGIN REQUIRES SERENA MCP SERVER.**

Serena provides the symbol-level code navigation tools this plugin teaches you to use:
- `activate_project` - Start LSP server for a project
- `get_symbols_overview` - See file structure without reading full contents
- `find_symbol` - Locate classes/functions/methods precisely
- `find_referencing_symbols` - Map dependencies
- `rename_symbol` - Language-aware refactoring
- `onboarding` - Built-in project familiarization workflow
- `write_memory` / `read_memory` - Cross-session knowledge persistence

### Install Serena

```bash
# For Claude Code (from project directory)
claude mcp add serena -- uvx --from git+https://github.com/oraios/serena serena start-mcp-server --context ide-assistant --project "$(pwd)"

# Verify installation
# In Claude Code, try: activate_project(current_directory)
```

See [Serena's documentation](https://github.com/oraios/serena) for detailed setup.

## What This Plugin Does

This plugin teaches Claude Code to:

1. **Use Serena's Built-In Systems:**
   - Project activation workflow (`activate_project`)
   - Onboarding system (`check_onboarding_performed`, `onboarding`)
   - Memory persistence (`.serena/memories/` via `write_memory`, `read_memory`)
   - Symbol-first code navigation

2. **Apply Eigent-Inspired Patterns:**
   - Multi-agent task decomposition
   - Parallel execution strategies
   - Verification-driven workflows
   - Structured result formatting

## Core Workflow

### Standard Serena Workflow (Plugin Teaches This)

```markdown
1. activate_project("/path/to/project")
   → Starts LSP server, loads config

2. check_onboarding_performed()
   → See if project has been explored before

3. If not onboarded:
   - onboarding() → Returns exploration prompt
   - Use symbol tools to explore codebase
   - write_memory() multiple times to persist findings

4. If already onboarded:
   - list_memories() → See available knowledge
   - read_memory(name) → Load relevant memories

5. Use symbol tools (first calls may be slow while LSP parses)
   → Recommend pre-indexing: `serena project index`

6. write_memory() to save new discoveries
```

### Pre-Indexing for Performance

**Problem:** First symbol tool calls are slow (LSP parsing files)

**Solution:**
```bash
# From project root
uvx --from git+https://github.com/oraios/serena serena project index
```

This creates `.serena/cache/document_symbols_cache_*.pkl` so subsequent calls are instant.

## Architecture

### Skills (Auto-Activating)

**Serena Workflow Skills:**
- **serena-setup** - Teaches activation → onboarding → memory workflow
- **symbol-navigator** - Guides symbol tool usage over file operations
- **code-structure-analyst** - Systematic exploration using Serena's onboarding
- **refactoring-coordinator** - Safe refactorings with symbol tools

**Eigent Workflow Skills:**
- **task-decomposer** - Breaks complex tasks into parallel subtasks
- **result-formatter** - Structured completion reports
- **url-validator** - Enforces URL sourcing policy

### Agents (Specialized)

**Serena-Powered:**
- **code-archeologist** - Uses Serena's onboarding to explore codebases (read-only)

**Eigent-Inspired:**
- **research-specialist** - Web research with memory persistence
- **implementation-engineer** - Code implementation with verification
- **document-architect** - User-facing documentation creation

### Hooks (Minimal)

**PreToolUse:**
- **safe-mode-guard** - Validates destructive Bash commands

## Installation

```bash
# Option 1: Clone to plugins directory
git clone <this-repo> ~/.claude/plugins/workforce-assistant

# Option 2: Symlink from development location
ln -s /path/to/workforce-assistant ~/.claude/plugins/workforce-assistant
```

## Quick Start

### First Time with a Project

```
User: Understand the authentication system
Claude:
  1. activate_project(current_directory)
  2. check_onboarding_performed()
  3. (If not onboarded) onboarding()
  4. Use symbol tools to explore auth
  5. write_memory("auth-system", findings)
```

### Using Existing Memories

```
User: Add JWT authentication
Claude:
  1. activate_project(current_directory)
  2. check_onboarding_performed()
  3. read_memory("auth-system")
  4. read_memory("code_style")
  5. Implement with symbol tools
```

## Key Patterns

### 1. Serena's Memory System (NOT .agent-notes)

**The plugin teaches using `.serena/memories/` (built into Serena):**

```markdown
## Storing Research
write_memory("jwt-research", """
# JWT Authentication Research

## Libraries Evaluated
- jsonwebtoken: Most popular, 15M weekly downloads
- jose: Modern, spec-compliant
...

Source: WebSearch "nodejs jwt libraries"
""")

## Loading Research
jwt_info = read_memory("jwt-research")
```

**NOT creating `.agent-notes/` files manually.**

### 2. Task Decomposition (Eigent Pattern)

For complex tasks, the plugin teaches breaking them into parallel subtasks with clear dependencies.

### 3. Symbol-First Navigation (Serena Pattern)

**Before:**
```
read_file("src/auth.ts")  # 800 lines, wasteful
```

**After (Plugin Teaches):**
```
get_symbols_overview("src/auth.ts")  # See structure first
find_symbol("AuthService", depth=1)   # Get class + methods
find_symbol("AuthService/login", include_body=true)  # Read specific method
```

### 4. Verification Workflow (Eigent Pattern)

Build → Test → Verify at every step, not just at the end.

## Usage Examples

### Example 1: Codebase Analysis

```
User: Understand the payment processing system

Plugin guides Claude to:
1. activate_project(cwd)
2. check_onboarding_performed()
3. If no memories:
   - onboarding()
   - find_symbol("payment", substring_matching=true)
   - find_symbol("PaymentProcessor", depth=1)
   - find_referencing_symbols("PaymentProcessor", ...)
   - write_memory("payment-system", findings)
4. If has memories:
   - read_memory("payment-system")
   - Update with new findings
```

### Example 2: Multi-Agent Task

```
User: Research auth libraries, implement JWT, document it

Plugin guides Claude to:
1. Decompose into 3 parallel tracks
2. research-specialist agent:
   - WebSearch for JWT libraries
   - write_memory("jwt-research", findings)
3. implementation-engineer agent:
   - read_memory("jwt-research")
   - read_memory("code_style")
   - Implement with symbol tools
   - write_memory("jwt-implementation", decisions)
4. document-architect agent:
   - Create user-facing docs
```

## File Structure

```
workforce-assistant/
├── .claude-plugin/
│   ├── plugin.json          # Plugin manifest
│   └── hooks.json           # Hook configurations
├── hooks/
│   └── safe-mode-guard.sh   # Validates destructive commands
├── skills/
│   ├── serena-setup/        # Core Serena workflow
│   ├── symbol-navigator/    # Symbol tool guidance
│   ├── code-structure-analyst/ # Systematic exploration
│   ├── refactoring-coordinator/ # Safe refactorings
│   ├── task-decomposer/     # Task breakdown (Eigent)
│   ├── result-formatter/    # Structured results (Eigent)
│   └── url-validator/       # URL sourcing (Eigent)
├── agents/
│   ├── code-archeologist.md      # Codebase analysis (Serena)
│   ├── research-specialist.md    # Research (Eigent + Serena memories)
│   ├── implementation-engineer.md # Implementation (Eigent)
│   └── document-architect.md     # Documentation (Eigent)
├── docs/
│   └── serena-integration.md # Detailed Serena workflows
└── README.md
```

## Generated Artifacts

**Serena creates `.serena/` in each project:**
- `memories/*.md` - Cross-session knowledge (write_memory)
- `cache/` - LSP symbol cache (pre-indexing)
- `project.yml` - Project configuration

**Plugin teaches using these, not creating parallel systems.**

## Philosophy

### Use Serena's Systems, Don't Duplicate Them

- ✅ Use `write_memory()` for persistence
- ❌ Don't create `.agent-notes/` manually
- ✅ Use Serena's `onboarding()` workflow
- ❌ Don't duplicate onboarding logic
- ✅ Use `activate_project()` first
- ❌ Don't assume symbol tools "just work"

### Symbol-First, Always

- Get overview before reading full files
- Use name paths for precise targeting
- Expect first-time slowness (LSP parsing)
- Recommend pre-indexing for large projects

### Verification-Driven

- Build → Test → Verify cycles
- Not extensive coding then test
- Incremental validation

## Troubleshooting

### "Tool not found: get_symbols_overview"

**Problem:** Serena MCP server not configured

**Solution:**
```bash
claude mcp add serena -- uvx --from git+https://github.com/oraios/serena serena start-mcp-server --context ide-assistant --project "$(pwd)"
```

### "No active project"

**Problem:** Forgot to activate project

**Solution:**
```python
activate_project("/path/to/project")
```

### "Symbol tools are slow"

**Problem:** LSP parsing files for first time

**Solution:**
```bash
# Pre-index project
uvx --from git+https://github.com/oraios/serena serena project index
```

## References

**Core Systems:**
- [Serena MCP Server](https://github.com/oraios/serena) - LSP-based symbol tools
- [Eigent Project](https://github.com/eigent-ai/eigent) - Multi-agent workforce patterns
- [CAMEL-AI Framework](https://github.com/camel-ai/camel) - Foundation for Eigent

**Documentation:**
- [Claude Code Plugins](https://docs.claude.com/en/docs/claude-code/plugins)
- [Serena Integration Guide](docs/serena-integration.md) - Detailed workflows
- [Model Context Protocol](https://modelcontextprotocol.io/) - MCP specification

## License

MIT
