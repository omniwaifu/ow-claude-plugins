# Workforce Assistant Plugin

Multi-agent patterns for Claude Code combining [Eigent](https://github.com/eigent-ai/eigent)-inspired workflows with [Serena](https://github.com/exa-labs/serena)-powered symbol-level code navigation, emphasizing **automation over manual commands**.

## Inspiration

This plugin draws from two powerful systems:

1. **[Eigent](https://github.com/eigent-ai/eigent)** - Multi-agent workforce system built on CAMEL-AI framework, providing patterns for task decomposition, parallel execution, and cross-session note-taking
2. **[Serena](https://github.com/exa-labs/serena)** - MCP server with LSP-based symbol tools, enabling token-efficient codebase exploration and language-aware refactoring

## Architecture

### Automated Hooks (Primary Layer)

**PostToolUse Hooks:**
- **Tool Lifecycle Logger** - Auto-logs all tool usage to `.agent-notes/tool-usage-log.md`
- **Research Note Capture** - Automatically captures WebFetch/WebSearch results with citations to `.agent-notes/research-YYYY-MM-DD.md`

**PreToolUse Hooks:**
- **Safe Mode Guardian** - Validates destructive Bash commands before execution

**PreCompact Hooks:**
- **Context Checkpoint** - Creates progress summaries before context compaction

**SessionEnd Hooks:**
- **Session Reporter** - Generates structured completion reports with artifact inventory

### Autonomous Skills

Skills activate automatically based on context:

**Workflow Skills (Eigent-inspired):**
- **task-decomposer** - Analyzes complex tasks and breaks them into parallel subtasks
- **result-formatter** - Formats task completions with verification checklists
- **url-validator** - Enforces strict URL sourcing (search/visited/user-provided only)

**Code Navigation Skills (Serena-inspired):**
- **symbol-navigator** - Guides efficient code navigation using symbol tools over file reading
- **code-structure-analyst** - Systematic codebase exploration with 70-90% token reduction
- **refactoring-coordinator** - Coordinates safe, language-aware refactorings with verification

### Specialized Sub-Agents

Workforce agents with focused expertise and tool access:

**Task-Focused Agents (Eigent-inspired):**
- **research-specialist** - Deep web research with comprehensive note-taking (WebSearch/WebFetch only)
- **implementation-engineer** - Code implementation with continuous verification (full tool access)
- **document-architect** - Documentation creation from artifacts (file operations only)

**Code Analysis Agent (Serena-inspired):**
- **code-archeologist** - Deep codebase understanding through symbol-level analysis (read-only, symbol tools preferred)

### Manual Commands (Minimal)

Only essential operations require manual invocation:

- `/workspace-init` - Set up `.workspace/` and `.agent-notes/` directories
- `/playbook-search <keyword>` - Query logged tool patterns

## Serena Integration

When used with the [Serena MCP server](https://github.com/exa-labs/serena), this plugin unlocks powerful symbol-level code operations:

### Benefits

**Token Efficiency:**
- 70-90% reduction in context usage vs file reading
- Symbol overviews show structure without full file contents
- Targeted reads of specific functions/classes only

**Language-Aware Refactoring:**
- `rename_symbol` updates all references atomically
- Respects language scope and semantics
- No regex errors or missed references

**Systematic Exploration:**
- Three-phase analysis (Overview → Discovery → Deep Dive)
- Automated codebase documentation in `.agent-notes/`
- Symbol locations preserved for future reference

### Quick Example

**Without Serena:**
```
read_file("src/main.ts")  # 800 lines, 3200 tokens
grep("authenticate")       # Noisy string matches
```

**With Serena:**
```
get_symbols_overview("src/main.ts")  # 50 lines, 200 tokens
find_symbol("authenticate")           # Exact definitions only
find_symbol("AuthService/login", include_body=true)  # Specific method, 30 tokens
```

### Getting Started with Serena

1. Install serena: `pip install serena-mcp`
2. Configure MCP server in Claude Code
3. Skills automatically guide symbol tool usage
4. Use `@code-archeologist` for codebase analysis

**Full documentation:** See [docs/serena-integration.md](docs/serena-integration.md) for installation, workflows, and multi-agent patterns.

## Key Patterns from Eigent

### 1. Task Decomposition with Context Separation
- Coordinator gets full context
- Workers receive focused task descriptions
- Prevents context pollution

### 2. Parallel Task Execution
- Independent subtasks run concurrently
- Dependency-aware scheduling
- Aggregated results

### 3. Note-Taking System
- Detailed research capture with citations
- Cross-session continuity
- Implementation decision rationale

### 4. Strict URL Policy
- Only use URLs from search results, visited pages, or user input
- Never fabricate or guess URLs
- Traceability for all sources

### 5. Continuous Verification
- Build → Test → Verify at every step
- No extensive coding without checkpoints
- Fix issues immediately

### 6. Structured Output
- TaskResult format for completions
- Verification checklists
- Clear success criteria

## Installation

### Option 1: Local Development
```bash
# Clone into your Claude plugins directory
git clone <this-repo> ~/.claude/plugins/workforce-assistant

# Or symlink from your development location
ln -s /path/to/workforce-assistant ~/.claude/plugins/workforce-assistant
```

### Option 2: Plugin System
```
/plugin install workforce-assistant@local
```

## Quick Start

1. **Initialize workspace:**
   ```
   /workspace-init
   ```

2. **Let automation work:**
   - Research is auto-captured to `.agent-notes/research-*.md`
   - Tool usage logged to `.agent-notes/tool-usage-log.md`
   - Safe mode validates destructive commands
   - Context checkpoints created automatically

3. **Use specialized agents for complex workflows:**
   - Research: "Use the research-specialist agent to find authentication best practices"
   - Implementation: "Use the implementation-engineer agent to build the API"
   - Documentation: "Use the document-architect agent to create user guide"

4. **Review patterns:**
   ```
   /playbook-search WebFetch
   /playbook-search authentication
   ```

## File Structure

```
workforce-assistant/
├── .claude-plugin/
│   ├── plugin.json          # Plugin manifest
│   └── hooks.json           # Hook configurations
├── hooks/
│   ├── tool-logger.sh       # Auto-logs tool usage
│   ├── research-capture.sh  # Auto-captures research
│   ├── safe-mode-guard.sh   # Validates destructive commands
│   ├── context-checkpoint.sh # Progress checkpoints
│   └── session-reporter.sh  # Session completion reports
├── skills/
│   ├── task-decomposer/     # Task breakdown skill (Eigent)
│   ├── result-formatter/    # Structured results skill (Eigent)
│   ├── url-validator/       # URL sourcing policy skill (Eigent)
│   ├── symbol-navigator/    # Symbol tool guidance (Serena)
│   ├── code-structure-analyst/ # Codebase exploration (Serena)
│   └── refactoring-coordinator/ # Safe refactoring (Serena)
├── agents/
│   ├── research-specialist.md      # Research-focused agent (Eigent)
│   ├── implementation-engineer.md  # Implementation agent (Eigent)
│   ├── document-architect.md       # Documentation agent (Eigent)
│   └── code-archeologist.md        # Codebase analysis agent (Serena)
├── commands/
│   ├── workspace-init.md    # Initialize directories
│   └── playbook-search.md   # Search tool patterns
├── docs/
│   └── serena-integration.md # Serena integration guide
└── README.md
```

## Generated Artifacts

The plugin automatically creates `.agent-notes/` with:

- `tool-usage-log.md` - Chronological tool usage (all tools)
- `research-YYYY-MM-DD.md` - Dated research findings with citations
- `checkpoints-YYYY-MM-DD.md` - Context compaction markers
- `session-report-YYYY-MM-DD.md` - Session completion summaries

## Usage Examples

### Complex Multi-Step Task

**User:** "Research authentication best practices, implement JWT auth, and document the API"

**Claude with Plugin:**
1. Task decomposer skill activates → identifies 3 parallel tracks
2. Spawns research-specialist agent → WebSearch/WebFetch captured automatically
3. Spawns implementation-engineer agent → builds with verification at each step
4. Spawns document-architect agent → creates docs from artifacts
5. All research auto-saved to `.agent-notes/research-YYYY-MM-DD.md`
6. Tool usage logged for future playbook reference
7. Session end hook creates completion summary

### Research-Heavy Task

**User:** "Find the top 5 Node.js authentication libraries and compare them"

**Claude with Plugin:**
- Research-specialist agent handles with WebSearch
- Every WebFetch result auto-captured with URL citation
- Detailed findings in `.agent-notes/research-YYYY-MM-DD.md`
- No manual note-taking needed
- URL validator ensures no fabricated sources

### Implementation Task

**User:** "Add user authentication to the API"

**Claude with Plugin:**
- Implementation-engineer agent selected
- Reads `.agent-notes/research-*.md` for technical decisions
- Implements with Build → Test → Verify cycles
- Safe mode validates any destructive operations
- Structured result with verification checklist
- Tool usage logged for pattern building

### Codebase Analysis with Serena

**User:** "Understand the authentication system in this codebase"

**Claude with Plugin + Serena:**
- Code-archeologist agent activated
- Uses `get_symbols_overview` to see structure without reading full files
- Applies `find_symbol("authenticate")` to locate auth-related code
- Runs `find_referencing_symbols` to map dependencies
- Creates comprehensive documentation in `.agent-notes/auth-system.md`
- 80% token reduction compared to file reading
- Symbol locations preserved for implementation team

## Philosophy

### Automation Over Manual Commands

- Hooks run automatically → no need to remember to log
- Skills activate based on context → no need to invoke
- Sub-agents self-select → no need to coordinate
- Notes captured automatically → no manual documentation

### Transparency Through Notes

- Every research finding cited with source URL
- Tool usage patterns logged for playbook building
- Implementation decisions traceable to research
- Cross-session continuity through persistent artifacts

### Verification at Every Step

- Safe mode prevents destructive operations
- Continuous build/test cycles during implementation
- Structured results with verification checklists
- Context checkpoints preserve progress

## Debugging

Enable detailed logging:
```bash
claude --debug
```

Check hook execution in output.

View plugin status:
```
/hooks
/skills
/agents
```

## References

**Core Inspirations:**
- [Eigent Project](https://github.com/eigent-ai/eigent) - Multi-agent workforce patterns
- [Serena MCP Server](https://github.com/exa-labs/serena) - LSP-based symbol tools
- [CAMEL-AI Framework](https://github.com/camel-ai/camel) - Foundation for Eigent

**Documentation:**
- [Claude Code Plugins Documentation](https://docs.claude.com/en/docs/claude-code/plugins)
- [Serena Integration Guide](docs/serena-integration.md) - Full integration walkthrough
- [Eigent Insights Analysis](./eigent/insights.md) - Original analysis

## Contributing

This plugin is in the `claude-plugins` repository as a demonstration of eigent-inspired patterns adapted to Claude Code.

## License

MIT
