#!/usr/bin/env bash
# Session Start: Serena Activation & Context Loading
# Automatically activates Serena and loads previous session context

set -euo pipefail

# Only activate for code projects
if [ -d ".serena" ] || [ -f "package.json" ] || [ -f "pyproject.toml" ] || [ -f "Cargo.toml" ] || [ -f "go.mod" ]; then
  cat << 'PROMPT'
🔧 Code Project Detected - Serena Available

IMPORTANT: Before ANY code operations:
1. initial_instructions() - Read Serena manual
2. Activate project for current directory
3. check_onboarding_performed()
   → If NOT done: Run onboarding() workflow
   → If done: list_memories() and load relevant ones

Previous session knowledge persists in .serena/memories/
PROMPT
fi
