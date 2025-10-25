---
name: code-structure-analyst
description: Teaches systematic codebase exploration using Serena's built-in onboarding system. Guides the Overview → Symbol Search → Targeted Reading pattern for efficient architectural understanding.
---

# Code Structure Analyst Skill

## Purpose

Teaches systematic, token-efficient codebase exploration by following Serena's built-in `onboarding()` workflow combined with symbol-level operations.

**Key Principle:** Use Serena's onboarding system, don't duplicate it.

## When This Skill Activates

- After calling `check_onboarding_performed()` and it returns "not performed"
- When exploring unfamiliar codebases
- Planning major features or refactorings
- Understanding architectural patterns
- First-time project analysis

## Prerequisites

**CRITICAL: This skill assumes Serena's activation workflow is complete.**

See the **serena-setup** skill for the complete workflow. You should have already:

```python
# 1. Activated project
activate_project(current_directory)

# 2. Checked onboarding status
status = check_onboarding_performed()

# 3a. If not onboarded:
if "not performed" in status:
    instructions = onboarding()
    # THIS SKILL teaches how to follow those instructions

# 3b. If already onboarded:
else:
    list_memories()
    # Use existing knowledge
```

## Integration with Serena's Onboarding

When you call `onboarding()`, Serena returns a detailed prompt instructing you to gather project information. This skill teaches **HOW** to efficiently gather that information using symbol-first operations.

### Serena's Onboarding Requirements

The `onboarding()` prompt asks you to identify:

1. **Project's purpose** - What it does
2. **Tech stack** - Languages, frameworks, libraries
3. **Code style and conventions** - Naming, types, docstrings
4. **Commands** - Testing, formatting, linting
5. **Codebase structure** - Organization
6. **Entry points** - How to run the project
7. **Guidelines** - Patterns, standards, design principles

### How to Gather This Information Efficiently

## Phase 1: High-Level Discovery (5-10% of context)

**Goal:** Quick overview without reading full files

```python
# 1. Directory structure
dir_structure = list_dir(".", recursive=True)
# Identify: src/, tests/, docs/, config/

# 2. Configuration files (read these - small and informative)
package_info = read_file("package.json")  # Or requirements.txt, Cargo.toml, etc.
readme = read_file("README.md")

# 3. Symbol overview of main entry point
main_symbols = get_symbols_overview("src/main.ts")  # Or app.py, index.js, etc.
# NOTE: First call may be slow (LSP parsing)
# Recommend to user if slow: `serena project index`

# 4. Identify framework from imports/structure
# React? Vue? Django? Express? Rails?
```

**Output Format (use write_memory):**
```python
write_memory("architecture_overview", """
# Architecture Overview

## Project Type
[React app / Django backend / CLI tool / etc]

## Technology Stack
- Language: TypeScript
- Framework: React 18
- State: Redux Toolkit
- Styling: Tailwind CSS
- Backend: Express + PostgreSQL

## Directory Structure
- `/src/components` - React components
- `/src/services` - Business logic
- `/src/api` - API client
- `/tests` - Test files
- `/config` - Configuration

## Entry Points
- Frontend: src/index.tsx
- Backend: src/server.ts
""")
```

## Phase 2: Symbol-Based Component Discovery (20-30% of context)

**Goal:** Identify major code entities and their relationships

```python
# 1. Find all classes
classes = find_symbol(
    name_path="",
    include_kinds=[5],  # Classes
    relative_path="src/"
)

# 2. Find top-level functions
functions = find_symbol(
    name_path="",
    include_kinds=[12],  # Functions
    relative_path="src/"
)

# 3. For each major component, get structure
for component in major_components:
    structure = find_symbol(component, depth=1)
    # See methods/properties without bodies

# 4. Understand relationships
for key_component in key_components:
    usages = find_referencing_symbols(
        name_path=key_component,
        relative_path=f"src/{component_file}"
    )
```

**Output Format:**
```python
write_memory("architecture_overview", """
[Previous content...]

## Key Symbols

### Frontend Components
- App: src/App.tsx:10 (main component)
- Dashboard: src/components/Dashboard.tsx:15
- UserProfile: src/components/UserProfile.tsx:22

### Services
- AuthService: src/services/auth.ts:8
  - login: Line 15
  - logout: Line 42
  - verifyToken: Line 68
- PaymentService: src/services/payment.ts:10

### API Layer
- apiClient: src/api/client.ts:5
- endpoints: src/api/endpoints.ts:8

## Dependencies
- Dashboard uses AuthService (5 calls)
- UserProfile uses AuthService (3 calls)
- PaymentService uses apiClient (8 calls)
""")
```

## Phase 3: Pattern Recognition (minimal additional context)

**Goal:** Understand conventions without reading full implementations

```python
# 1. Sample one file from each category to understand patterns
sample_component = find_symbol("Dashboard", depth=1)
# See: functional component? class component? hooks used?

sample_service = find_symbol("AuthService", depth=1)
# See: class-based? method structure?

# 2. Check test structure (read one test file)
sample_test = read_file("tests/example.test.ts")
# Understand: testing framework, patterns

# 3. Check for style guides
if file_exists(".eslintrc.json"):
    eslint_config = read_file(".eslintrc.json")
if file_exists("pyproject.toml"):
    pyproject = read_file("pyproject.toml")
```

**Output Format:**
```python
write_memory("code_style", """
# Code Style & Conventions

## Language & Tooling
- TypeScript with strict mode
- ESLint + Prettier
- Jest for testing

## Conventions
- React: Functional components with hooks
- File naming: PascalCase for components, camelCase for utilities
- Export style: Named exports preferred
- State management: Redux Toolkit slices

## Patterns
- Services: Class-based with dependency injection
- Components: Function components with custom hooks
- Tests: Co-located in __tests__ directories
- API calls: Centralized in services layer

## Type Annotations
- All functions have return types
- Props interfaces for all components
- Strict null checks enabled
""")
```

## Phase 4: Command Discovery

**Goal:** Find how to test, build, run the project

```python
# 1. Read package.json scripts (or Makefile, etc.)
package_json = read_file("package.json")

# 2. Check for CI config
if file_exists(".github/workflows/ci.yml"):
    ci_config = read_file(".github/workflows/ci.yml")

# 3. Read docs if available
if file_exists("CONTRIBUTING.md"):
    contrib = read_file("CONTRIBUTING.md")
```

**Output Format:**
```python
write_memory("suggested_commands", """
# Suggested Commands

## Development
- Start dev server: `npm run dev`
- Build: `npm run build`
- Preview build: `npm run preview`

## Testing
- Run all tests: `npm test`
- Watch mode: `npm test -- --watch`
- Coverage: `npm run test:coverage`
- E2E tests: `npm run test:e2e`

## Linting & Formatting
- Lint: `npm run lint`
- Fix lint: `npm run lint:fix`
- Format: `npm run format`
- Type check: `npm run type-check`

## Database
- Migrations: `npm run db:migrate`
- Seed: `npm run db:seed`
- Reset: `npm run db:reset`

## Deployment
- Build production: `npm run build:prod`
- Deploy: `npm run deploy`
""")
```

## Phase 5: Task Completion Checklist

```python
write_memory("task_completion_checklist", """
# Task Completion Checklist

When a coding task is complete, ensure:

## Code Quality
- [ ] ESLint passes: `npm run lint`
- [ ] Prettier formatted: `npm run format`
- [ ] TypeScript compiles: `npm run type-check`

## Testing
- [ ] Unit tests pass: `npm test`
- [ ] New tests added for new features
- [ ] Coverage meets threshold (>80%)
- [ ] E2E tests pass if applicable

## Documentation
- [ ] JSDoc comments for public APIs
- [ ] README updated if needed
- [ ] CHANGELOG.md updated

## Review
- [ ] Code follows style guide (see code_style.md)
- [ ] No console.log/debugger statements
- [ ] Error handling implemented
- [ ] Accessibility considered (WCAG 2.1)
""")
```

## Symbol-First vs File-Heavy Comparison

### Anti-Pattern: File-Heavy Approach
```python
❌ # Reading full files (wastes 90% context)
read_file("src/components/Dashboard.tsx")     # 800 lines
read_file("src/services/auth.ts")             # 600 lines
read_file("src/api/client.ts")                # 400 lines

# Total: ~2000 lines read, most not needed
```

### Recommended: Symbol-First Approach
```python
✅ # Get overview first
get_symbols_overview("src/components/Dashboard.tsx")  # 20 lines
# → See: Dashboard, useAuth, useDashboardData

✅ # Get class structure without implementation
find_symbol("AuthService", depth=1)  # 50 lines
# → See: all methods, no bodies

✅ # Read ONLY what's needed
find_symbol("AuthService/login", include_body=True)  # 15 lines
# → Just the login method

# Total: ~85 lines read, highly relevant
# Savings: 95% context reduction
```

## Integration with Other Skills

### With serena-setup
```
serena-setup: activate → check onboarding
  ↓ (if not onboarded)
code-structure-analyst: Follow onboarding() prompt
  ↓
symbol-navigator: Efficient tool selection
  ↓
write_memory(): Persist findings
```

### With task-decomposer
```python
# After onboarding, task decomposer can:
arch = read_memory("architecture_overview")
style = read_memory("code_style")
commands = read_memory("suggested_commands")

# Use this knowledge to decompose tasks intelligently
```

## Performance Optimization

### First-Time Slowness

**Problem:** First symbol tool calls may be slow (LSP parsing)

**What to tell user:**
```markdown
## Performance Note

First symbol exploration may take 10-60 seconds (LSP parsing files).

**Recommendation:**
For instant subsequent calls, run in terminal:

    uvx --from git+https://github.com/oraios/serena serena project index

This creates `.serena/cache/` so future symbol calls are <1 second.
```

### Progressive Exploration

Don't analyze everything at once:

```python
# Good: Start broad, narrow down
get_symbols_overview("src/")           # All files overview
find_symbol("AuthService", depth=1)    # One component structure
find_symbol("AuthService/login", include_body=True)  # One method

# Bad: Try to analyze everything deeply
for file in all_files:
    for symbol in get_symbols_overview(file):
        find_symbol(symbol, depth=3, include_body=True)  # Too much!
```

## Onboarding Completion Checklist

Before considering onboarding complete:

**Memories Written:**
- [ ] `architecture_overview.md` - Tech stack, structure, entry points
- [ ] `code_style.md` - Conventions, patterns, tooling
- [ ] `suggested_commands.md` - Test/lint/build/run commands
- [ ] `task_completion_checklist.md` - What to do when done

**Information Gathered:**
- [ ] Project purpose understood
- [ ] Tech stack identified
- [ ] Major components mapped with symbol locations
- [ ] Testing strategy understood
- [ ] Development commands documented
- [ ] Code conventions identified

**Token Efficiency:**
- [ ] Used symbol tools instead of reading full files
- [ ] Context usage < 30% of budget
- [ ] Focused on structure, not implementation details

## Example: Complete Onboarding Session

**User:** "Help me understand this React codebase"

**Your Process:**

```python
# 0. Activation (from serena-setup skill)
activate_project(current_directory)
status = check_onboarding_performed()
# → "Onboarding not performed yet"

instructions = onboarding()
# → Returns detailed prompt

# 1. High-level discovery (5% context)
structure = list_dir(".", recursive=True)
package = read_file("package.json")
readme = read_file("README.md")

main_overview = get_symbols_overview("src/App.tsx")
# (may be slow first time - LSP parsing)

# 2. Symbol-based discovery (20% context)
components = find_symbol("", include_kinds=[12], relative_path="src/components/")
# → 15 React components found

services = find_symbol("", include_kinds=[5], relative_path="src/services/")
# → 5 service classes found

# Sample one of each
dashboard = find_symbol("Dashboard", depth=1)
# → Functional component with useAuth, useDashboardData hooks

auth_service = find_symbol("AuthService", depth=1)
# → Methods: login, logout, verifyToken, refreshToken

# 3. Understand patterns (5% context)
sample_test = read_file("src/__tests__/Dashboard.test.tsx")
# → Using Jest + React Testing Library

eslint = read_file(".eslintrc.json")
# → Airbnb style guide

# 4. Document findings (write_memory)
write_memory("architecture_overview", """...""")
write_memory("code_style", """...""")
write_memory("suggested_commands", """...""")
write_memory("task_completion_checklist", """...""")

# Done! Total context: ~30%
```

**Next time:**
```python
activate_project(current_directory)
status = check_onboarding_performed()
# → "Onboarding already performed. Memories: [...]"

# Load existing knowledge
arch = read_memory("architecture_overview")
# Ready to work immediately!
```

## Common Mistakes to Avoid

1. **Duplicating onboarding** → Use Serena's built-in `onboarding()` tool
2. **Reading files before symbols** → Get overview first
3. **Using Write instead of write_memory** → Bypass Serena's memory system
4. **Creating .agent-notes/** → Use `.serena/memories/` instead
5. **Not checking activation** → Symbol tools won't work
6. **Over-analyzing** → Get 80% understanding, not 100%
7. **Ignoring first-call slowness** → Warn user, recommend pre-indexing

## Philosophy

- **Use Serena's Systems**: onboarding() provides the prompt, this skill teaches execution
- **Symbol-First Always**: Overview → Depth → Targeted reads
- **Memory-Driven**: write_memory() for cross-session continuity
- **Performance-Aware**: Expect LSP slowness, recommend pre-indexing
- **Efficient**: 70-90% token reduction via symbol tools

## References

- serena-setup skill: Complete activation workflow
- symbol-navigator skill: Tool selection guidance
- Serena onboarding system: Built-in workflow
