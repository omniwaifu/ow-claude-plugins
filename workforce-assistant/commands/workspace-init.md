Initialize workspace directories and activate Serena project.

Execute these steps:

1. Create directory structure:
   ```bash
   mkdir -p .workspace/{research,implementation,testing}
   mkdir -p .agent-notes
   ```

2. Create agent notes README:
   ```bash
   cat > .agent-notes/README.md << 'EOF'
# Agent Notes Directory

Auto-generated notes from workforce-assistant plugin.

## Files
- `research-YYYY-MM-DD.md` - Research findings with citations
- `tool-usage-log.md` - Tool usage patterns for playbooks
- `checkpoints-YYYY-MM-DD.md` - Context compaction markers
- `session-report-YYYY-MM-DD.md` - Session summaries

## Purpose
- Cross-session continuity
- Decision rationale
- Implementation patterns
- Context for new sessions
EOF
   ```

3. Update .gitignore:
   ```bash
   echo "" >> .gitignore
   echo "# Workforce Assistant" >> .gitignore
   echo "# .agent-notes/" >> .gitignore
   echo "# .workspace/" >> .gitignore
   ```

4. Activate Serena:
   ```python
   # Start LSP server
   activate_project(current_directory)

   # Check onboarding status
   status = check_onboarding_performed()

   # If not onboarded: call onboarding() and follow its prompt
   # If onboarded: list_memories() and read_memory() as needed
   ```

5. Report completion:
   - Directory structure: created
   - Serena project: activated
   - Memories: loaded/created
   - Status: ready

## Purpose

One-command bootstrap for:
- Workspace directories (agent sandboxing)
- Agent notes (cross-session continuity)
- Serena activation (LSP + memory system)

## Troubleshooting

**"Tool not found: activate_project"**
- Install: `pip install serena-mcp`
- Configure in Claude Code MCP settings
- See: workforce-assistant/docs/serena-integration.md

**Slow symbol tools**
- Recommend: `uvx --from git+https://github.com/oraios/serena serena project index`
