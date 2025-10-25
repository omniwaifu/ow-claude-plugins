#!/usr/bin/env bash
# Session Reporter Hook (SessionEnd)
# Generates structured task results at session completion
# Inspired by eigent's TaskResult structured output pattern

set -euo pipefail

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
DATE_ONLY=$(date -u +"%Y-%m-%d")

# Create .agent-notes directory if it doesn't exist
NOTES_DIR="${PWD}/.agent-notes"
mkdir -p "$NOTES_DIR"

# Session report file
REPORT_FILE="${NOTES_DIR}/session-report-${DATE_ONLY}.md"

# Check if notes were generated during session
TOOL_LOG_EXISTS=false
RESEARCH_LOG_EXISTS=false

[ -f "${NOTES_DIR}/tool-usage-log.md" ] && TOOL_LOG_EXISTS=true
[ -f "${NOTES_DIR}/research-${DATE_ONLY}.md" ] && RESEARCH_LOG_EXISTS=true

# Append session end marker
cat >> "$REPORT_FILE" << EOF

## Session End: ${TIMESTAMP}

**Session artifacts generated:**
- Tool Usage Log: ${TOOL_LOG_EXISTS}
- Research Notes: ${RESEARCH_LOG_EXISTS}

**Review checklist:**
- [ ] All tasks completed?
- [ ] Code changes verified (build/test)?
- [ ] Documentation updated?
- [ ] Any blockers or follow-ups?

**Next session preparation:**
- Review .agent-notes/ for context
- Check tool-usage-log.md for patterns
- Reference research notes for decisions made

---

EOF

# Output message
cat << EOF
{
  "status": "session_ended",
  "report": "${REPORT_FILE}",
  "artifacts": {
    "tool_log": ${TOOL_LOG_EXISTS},
    "research_log": ${RESEARCH_LOG_EXISTS}
  },
  "message": "Session artifacts saved to .agent-notes/ for future reference"
}
EOF

exit 0
