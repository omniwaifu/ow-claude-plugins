---
name: code-structure-analyst
description: Systematic codebase exploration workflow using symbol-level tools. Teaches the Overview → Symbol Search → Targeted Reading pattern for efficient context usage and architectural understanding.
---

# Code Structure Analyst Skill

## Purpose

Provides a systematic, token-efficient workflow for understanding codebase structure using symbol-level operations. Emphasizes building understanding incrementally rather than reading entire files.

## When This Skill Activates

- Onboarding to new codebases
- Understanding architectural patterns
- Planning feature implementations
- Analyzing code organization
- Before major refactorings

## Core Workflow: Three-Phase Analysis

### Phase 1: Architectural Overview

**Goal:** Understand high-level organization without reading code

**Steps:**
1. **Directory Structure**
   ```
   list_dir(".", recursive=true)
   ```
   Identify: src/, tests/, docs/, config/

2. **Top-Level Symbols** (if LSP tools available)
   ```
   get_symbols_overview("src/")
   ```
   For each major file, see: Classes, top-level functions, exports

3. **Pattern Recognition**
   - Identify framework (React/Vue/Django/Rails/etc)
   - Find entry points (main.ts, app.py, index.js)
   - Locate configuration (config/, .env, package.json)

**Output:** High-level architecture map in `.agent-notes/architecture-overview.md`

### Phase 2: Component Discovery

**Goal:** Identify key components and their relationships

**Steps:**
1. **Find Core Abstractions**
   ```
   find_symbol(name_path="", include_kinds=[5])  # All classes
   find_symbol(name_path="", include_kinds=[12]) # All functions
   ```
   Build component list

2. **Analyze Dependencies**
   For each major component:
   ```
   find_symbol("ComponentName", depth=1)
   find_referencing_symbols("ComponentName", ...)
   ```
   Understand: What it does, what uses it

3. **Identify Patterns**
   - Controllers, Services, Models (MVC)
   - Components, Hooks, Stores (React)
   - Handlers, Middleware, Routes (Backend)

**Output:** Component relationship map

### Phase 3: Targeted Deep Dives

**Goal:** Understand specific implementations only when needed

**Steps:**
1. **Selective Reading**
   ```
   find_symbol("SpecificFunction", include_body=true)
   ```
   Read only relevant symbols

2. **Context Expansion** (if needed)
   ```
   read_file("path/to/file.ts", start_line=X, end_line=Y)
   ```
   Get surrounding context only when symbol view insufficient

3. **Documentation**
   Record findings in `.agent-notes/` with symbol locations

## Symbol-First Analysis Pattern

### Anti-Pattern (File-Heavy)
```
❌ 1. list_dir("src/", recursive=true)
❌ 2. read_file("src/components/Dashboard.tsx")  # 800 lines
❌ 3. read_file("src/components/Chart.tsx")      # 600 lines
❌ 4. read_file("src/api/client.ts")             # 400 lines
❌ 5. grep("API_URL")                            # Many false positives
```
**Problem:** Reading full files wastes tokens, hard to see structure

### Recommended Pattern (Symbol-First)
```
✓ 1. list_dir("src/", recursive=true)
✓ 2. get_symbols_overview("src/components/Dashboard.tsx")
    → See: Dashboard, ChartWidget, DataTable (no bodies)
✓ 3. find_symbol("Dashboard", depth=1)
    → Get component + hooks/methods
✓ 4. find_symbol("fetchDashboardData", include_body=true)
    → Read only the data fetching function
✓ 5. find_referencing_symbols("API_URL", ...)
    → See actual usage sites
```
**Benefit:** 70-90% token reduction, clearer structure

## Architectural Analysis Templates

### For Web Applications

```markdown
## Architecture Analysis: [Project Name]

### Technology Stack
- Framework: [Detected from package.json/imports]
- Language: [TypeScript/JavaScript/Python/etc]
- State Management: [Redux/Context/Vuex/etc]
- Backend: [Express/Django/Rails/etc]

### Directory Structure
[From list_dir with annotations]

### Core Components (from symbol analysis)

**Frontend:**
- Components: [List from find_symbol with kinds=[5])]
- Hooks/Utilities: [Custom hooks found]
- State Management: [Stores/reducers]

**Backend:**
- Routes: [API endpoints]
- Controllers: [Request handlers]
- Services: [Business logic]
- Models: [Data layer]

### Key Entry Points
- Frontend: [src/index.tsx:15 - App component]
- Backend: [src/main.py:42 - create_app()]
- API Routes: [src/routes/api.ts:10 - router definition]

### Dependencies & References
[From find_referencing_symbols analysis]

### Next Investigation Areas
- [ ] Authentication flow
- [ ] Data fetching patterns
- [ ] Error handling
```

### For Libraries/SDKs

```markdown
## Library Analysis: [Name]

### Public API Surface (from symbol overview)
- Classes: [Exported classes]
- Functions: [Public functions]
- Types: [Type definitions]

### Internal Structure
- Core: [Main implementation symbols]
- Utils: [Helper functions]
- Tests: [Test organization]

### Usage Patterns (from find_referencing_symbols)
[How public API is used internally]

### Extension Points
[Interfaces, abstract classes, hooks]
```

## Language-Specific Patterns

### TypeScript/JavaScript
```
# Phase 1: Find exports
find_symbol(name_path="", relative_path="src/index.ts")

# Phase 2: Analyze classes
find_symbol(name_path="ClassName", depth=2)

# Phase 3: Find React components
find_symbol(name_path="", include_kinds=[12], relative_path="src/components/")
# Look for functions returning JSX
```

### Python
```
# Phase 1: Find classes
find_symbol(name_path="", include_kinds=[5])

# Phase 2: Find methods
find_symbol(name_path="ClassName", depth=1)

# Phase 3: Find imports
search_for_pattern(substring_pattern="^import |^from ", context_lines_before=0)
```

### Java
```
# Phase 1: Find packages
find_symbol(name_path="", include_kinds=[4])

# Phase 2: Find classes/interfaces
find_symbol(name_path="", include_kinds=[5,11])

# Phase 3: Analyze inheritance
find_referencing_symbols(name_path="BaseClass", ...)
```

## Integration with Workforce Patterns

### With Task Decomposer

When decomposing complex feature implementation:

```markdown
## Task Decomposition: Add User Profile Feature

### Research Phase (This Skill)
1. Analyze current user authentication
   - find_symbol("User")
   - find_referencing_symbols("User", ...)
2. Understand data layer patterns
   - get_symbols_overview("src/models/")
3. Identify UI component patterns
   - find_symbol("", include_kinds=[12], relative_path="src/components/")

### Implementation Plan (From Analysis)
Based on structure analysis:
- [Subtask 1] Create UserProfile model (pattern matches User model)
- [Subtask 2] Add profile routes (pattern matches auth routes)
- [Subtask 3] Build profile component (pattern matches existing components)
```

### With Research Specialist

```markdown
**Codebase Research Workflow:**

1. Code-Structure-Analyst explores architecture
2. Documents structure in .agent-notes/architecture.md
3. Research Specialist reads notes + performs targeted symbol searches
4. Implementation Engineer uses structure knowledge for implementation
```

## Efficient Context Management

### Context Budget Strategy

**Phase 1 (Overview):** ~5-10% of context
- Directory listings
- Symbol overviews
- Pattern identification

**Phase 2 (Discovery):** ~20-30% of context
- Symbol searches with depth
- Reference analysis
- Component mapping

**Phase 3 (Deep Dive):** ~60-70% of context
- Targeted symbol body reads
- Specific file sections
- Implementation details

### When to Checkpoint

Create checkpoint in `.agent-notes/` after:
- Completing architectural overview
- Discovering major components
- Before switching to implementation
- When approaching context limits

## Output Format

Always structure findings as:

```markdown
## Code Structure Analysis: [Component/Module]

**Analysis Date:** [ISO timestamp]
**Scope:** [What was analyzed]
**Method:** [Symbol tools used]

### Structure Summary
[High-level organization]

### Key Symbols Discovered
| Symbol | Type | Location | Purpose |
|--------|------|----------|---------|
| ClassName | Class | src/models/user.ts:15 | User data model |
| processPayment | Function | src/services/payment.ts:42 | Payment processing |

### Dependencies
[What this uses]

### Dependents
[What uses this]

### Patterns Observed
[Architectural/code patterns]

### Recommendations
[Suggestions for implementation/refactoring]

### Symbol Locations for Future Reference
[name_path values for symbol tools]
```

## Success Criteria

Analysis is complete when:
- [ ] High-level architecture documented
- [ ] Major components identified with symbol locations
- [ ] Key dependencies mapped
- [ ] Entry points documented
- [ ] Patterns recognized
- [ ] Recommendations provided
- [ ] Notes written to `.agent-notes/`

## Common Mistakes to Avoid

1. **Reading files before symbol overview** - Wastes tokens
2. **Not using depth parameter** - Miss component structure
3. **Forgetting to document symbol locations** - Can't find code later
4. **Over-analyzing** - Get 80% understanding with 20% effort
5. **Not checking for LSP tools** - Assume availability

## References

- Symbol Navigator skill for tool selection
- Eigent decomposition pattern (insights.md:16-45)
- Serena symbol operations (serena docs)
