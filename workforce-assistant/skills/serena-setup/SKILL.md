---
name: serena-project-activator
description: Activates Serena LSP server and runs onboarding workflow for codebase projects. Automatically triggers when starting work on any project with Serena MCP available.
---

# Serena Project Activator

## Activation Sequence

When working with a codebase project:

1. **Read Serena Manual**
   ```
   mcp__plugin_workforce-assistant_serena__initial_instructions()
   ```

2. **Activate Project**
   ```
   # Activate LSP server for current directory
   # (Serena auto-detects language and starts appropriate LSP)
   ```

3. **Check Onboarding Status**
   ```
   mcp__plugin_workforce-assistant_serena__check_onboarding_performed()
   ```

4. **If Not Onboarded - Run Onboarding**
   ```
   mcp__plugin_workforce-assistant_serena__onboarding()
   # Follow the onboarding prompt - it will guide you through:
   # - Creating architecture_overview memory
   # - Documenting code_style conventions
   # - Recording suggested_commands for build/test
   ```

5. **If Already Onboarded - Load Memories**
   ```
   mcp__plugin_workforce-assistant_serena__list_memories()
   # Then read relevant ones:
   mcp__plugin_workforce-assistant_serena__read_memory("architecture_overview")
   ```

## Performance Tip

If symbol tools are slow on first use, Serena is parsing the codebase. This only happens once per project. Be patient on first activation.

## Remember

- Onboarding creates foundational knowledge - don't skip it
- Memories persist across sessions - use them
- Symbol tools (get_symbols_overview, find_symbol) are faster than Read/Grep for code
