# Workforce Assistant Plugin

Eigent-inspired multi-agent patterns for Claude Code, emphasizing **automation over manual commands**.

## Inspiration

This plugin distills core mechanisms from [Eigent](https://github.com/eigent-ai/eigent), a multi-agent workforce system built on CAMEL-AI framework, and adapts them to Claude Code's plugin architecture.

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

- **task-decomposer** - Analyzes complex tasks and breaks them into parallel subtasks
- **result-formatter** - Formats task completions with verification checklists
- **url-validator** - Enforces strict URL sourcing (search/visited/user-provided only)

### Specialized Sub-Agents

Workforce agents with focused expertise and tool access:

- **research-specialist** - Deep web research with comprehensive note-taking (WebSearch/WebFetch only)
- **implementation-engineer** - Code implementation with continuous verification (full tool access)
- **document-architect** - Documentation creation from artifacts (file operations only)

### Manual Commands (Minimal)

Only essential operations require manual invocation:

- `/workspace-init` - Set up `.workspace/` and `.agent-notes/` directories
- `/playbook-search <keyword>` - Query logged tool patterns

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
│   ├── task-decomposer/     # Task breakdown skill
│   ├── result-formatter/    # Structured results skill
│   └── url-validator/       # URL sourcing policy skill
├── agents/
│   ├── research-specialist.md      # Research-focused agent
│   ├── implementation-engineer.md  # Implementation agent
│   └── document-architect.md       # Documentation agent
├── commands/
│   ├── workspace-init.md    # Initialize directories
│   └── playbook-search.md   # Search tool patterns
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

- [Eigent Project](https://github.com/eigent-ai/eigent)
- [CAMEL-AI Framework](https://github.com/camel-ai/camel)
- [Claude Code Plugins Documentation](https://docs.claude.com/en/docs/claude-code/plugins)
- [Eigent Insights Analysis](./eigent/insights.md)

## Contributing

This plugin is in the `claude-plugins` repository as a demonstration of eigent-inspired patterns adapted to Claude Code.

## License

MIT
