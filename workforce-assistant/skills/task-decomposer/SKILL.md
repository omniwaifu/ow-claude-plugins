---
name: task-decomposer
description: Analyzes complex multi-step tasks and decomposes them into focused, parallel-executable subtasks with clear dependency relationships. Inspired by eigent's coordinator pattern for workforce task distribution.
---

# Task Decomposer Skill

## Purpose

This skill helps Claude autonomously identify when a task should be decomposed into multiple parallel subtasks and provides a structured decomposition strategy.

## When This Skill Activates

- User requests involve multiple distinct steps
- Task requires coordination between different concerns (research, implementation, testing)
- Work could benefit from parallel execution
- Complex workflows with clear separation of concerns

## Decomposition Framework

When decomposing tasks, follow this pattern:

### 1. Analyze Task Structure

Identify:
- **Independent components** - can run in parallel
- **Sequential dependencies** - must run in order
- **Resource requirements** - which tools/agents needed
- **Estimated complexity** - small/medium/large effort

### 2. Create Clean Subtask Descriptions

Each subtask should:
- Be self-contained with clear goal
- Include necessary context (but not full history)
- Specify success criteria
- Note dependencies on other subtasks

### 3. Execution Strategy

```markdown
## Task Decomposition

### Parallel Track A (Independent)
1. [Subtask A1] - Research phase
2. [Subtask A2] - Data gathering

### Parallel Track B (Independent)
1. [Subtask B1] - Implementation setup
2. [Subtask B2] - Configuration

### Sequential Track C (Depends on A + B)
1. [Subtask C1] - Integration
2. [Subtask C2] - Testing
3. [Subtask C3] - Documentation
```

## Key Principles from Eigent

1. **Context Separation**: Workers receive focused descriptions, not coordinator's full context
2. **Dependency Awareness**: Clearly mark what can run in parallel vs sequential
3. **Clean Task Boundaries**: Each subtask is independently understandable
4. **Explicit Coordination**: State how results will be aggregated

## Example Decomposition

**User Request:** "Build a user authentication system with email verification"

**Decomposition:**

```markdown
### Parallel Phase 1 (Independent):

**Subtask 1: Research Authentication Patterns**
- Goal: Identify best practices for email-based auth in [framework]
- Tools: WebSearch, WebFetch
- Output: Decision document in .agent-notes/

**Subtask 2: Design Database Schema**
- Goal: Create users, sessions, email_verifications tables
- Tools: File operations
- Output: Schema definition file

### Parallel Phase 2 (Depends on Phase 1):

**Subtask 3: Implement Auth API Routes**
- Goal: /register, /login, /verify endpoints
- Dependencies: Needs schema from Subtask 2, patterns from Subtask 1
- Tools: Edit, Write

**Subtask 4: Build Email Service Integration**
- Goal: Connect to email provider, create templates
- Dependencies: Needs patterns from Subtask 1
- Tools: Edit, Write

### Sequential Phase 3 (Integration):

**Subtask 5: Integration Testing**
- Goal: Test full registration → email → verification flow
- Dependencies: Needs Subtask 3 + 4 complete
- Tools: Bash (test runner)

**Subtask 6: Documentation**
- Goal: API docs + setup instructions
- Dependencies: All implementation complete
- Tools: Write
```

## Usage Notes

- Use Task tool with single message, multiple agent invocations for parallel work
- Create `.agent-notes/task-decomposition.md` to track decomposition decisions
- For simple tasks (< 3 steps), decomposition may not be needed
- Always verify subtask results before marking overall task complete

## References

- Eigent coordinator pattern (insights.md:16-45)
- Parallel task execution (insights.md:48-68)
- Context separation for workers (insights.md:31-34)
