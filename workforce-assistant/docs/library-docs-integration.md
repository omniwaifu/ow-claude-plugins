# Context7 Integration Guide

## Overview

The workforce-assistant plugin integrates with **Context7**, an MCP server that provides up-to-date, authoritative documentation for external libraries and frameworks. This integration reduces hallucination on API usage and ensures Claude uses current library patterns.

## What is Context7?

Context7 is an MCP (Model Context Protocol) server that:
- Provides official documentation for popular libraries/frameworks
- Returns current API references and code examples
- Sources documentation from authoritative repositories
- Supports version-specific queries

**Examples of libraries covered:**
- Web frameworks: React, Next.js, Vue, FastAPI, Django, Express
- Databases: MongoDB, PostgreSQL, Supabase
- Cloud SDKs: AWS, Azure, GCP client libraries
- Data science: Pandas, NumPy, TensorFlow, PyTorch
- Mobile: React Native, Flutter

## Installation

### Option 1: Claude Code MCP Configuration

```bash
claude mcp add context7 [installation-command]
```

Verify installation:
```bash
claude mcp list
```

Should show `context7` in the list.

### Option 2: Manual Configuration

Add to your Claude Code MCP settings file:

```json
{
  "mcpServers": {
    "context7": {
      "command": "[context7-command]",
      "args": []
    }
  }
}
```

## Architecture: Three-Tier Documentation Strategy

The workforce-assistant uses a three-tier approach for comprehensive code understanding:

```
┌─────────────────────────────────────────────┐
│ 1. INTERNAL CODEBASE (Serena)              │
│    - Symbol navigation                       │
│    - Project structure                       │
│    - Custom implementations                  │
└─────────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────────┐
│ 2. EXTERNAL LIBRARIES (Context7)            │
│    - Library API documentation               │
│    - Official patterns                       │
│    - Framework conventions                   │
└─────────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────────┐
│ 3. GENERAL KNOWLEDGE (Web Search)           │
│    - Tutorials and guides                    │
│    - Troubleshooting                         │
│    - Community best practices                │
└─────────────────────────────────────────────┘
```

## How Agents Use Context7

### Automatic Detection

Agents automatically detect when questions involve external libraries:

**Triggers:**
- "How do I use [library] to..."
- "What's the [framework] API for..."
- "Does [library] support..."
- Implementing features with known frameworks
- Encountering import statements in code

**No triggers:**
- General programming concepts
- Internal codebase questions
- Non-library-specific tasks

### Two-Step Query Pattern

All Context7 queries follow this pattern:

#### Step 1: Resolve Library ID
```python
resolve-library-id(libraryName="next.js")
# Returns: "/vercel/next.js"
```

Context7 uses a specific ID format: `/org/project` or `/org/project/version`

#### Step 2: Get Documentation
```python
get-library-docs(
    context7CompatibleLibraryID="/vercel/next.js",
    topic="routing",              # Optional: focus area
    tokens=5000                   # Optional: context size
)
```

Returns up-to-date documentation and code examples.

## Memory Caching Pattern

To reduce API calls, library documentation is cached in Serena's memory system:

### Naming Convention

```
library-docs-{library}-{topic}.md
```

**Examples:**
- `library-docs-nextjs-routing.md`
- `library-docs-fastapi-async-patterns.md`
- `library-docs-react-hooks-reference.md`

### Cache Workflow

```python
# 1. Check cache first
list_memories()
existing = read_memory("library-docs-nextjs-routing")

# 2. If not cached, query Context7
if not existing:
    resolve-library-id("next.js")
    docs = get-library-docs("/vercel/next.js", topic="routing")

    # 3. Cache for future use
    write_memory("library-docs-nextjs-routing", docs)
```

### Cache Strategy

**When to cache:**
- Common libraries used across projects
- Frequently referenced patterns
- Stable API surfaces

**When to query fresh:**
- Niche packages
- Beta/experimental features
- First-time exploration

## Agent-Specific Usage

### Research Specialist

**Role:** Parallel investigation using Context7 + web search

**Pattern:**
```python
# Detect library question
if mentions_library(user_query):
    # Get official docs
    resolve-library-id("library-name")
    official_docs = get-library-docs("/org/library", topic="feature")

    # Also get community insights
    community = WebSearch("library-name feature best practices 2025")

    # Synthesize both sources
    write_memory("research-topic", """
    ## Official Documentation (Context7)
    [Authoritative patterns from library maintainers]

    ## Community Research (Web)
    [Real-world usage, gotchas, workarounds]

    ## Synthesis
    [Combined recommendation]
    """)
```

**Benefits:**
- Official docs: What's supported/recommended
- Web search: How people actually use it
- Cross-validation: Catch outdated tutorials

### Implementation Engineer

**Role:** Verify library APIs before implementing

**Pattern:**
```python
# Before implementing with external library
framework = detect_framework_from_task()

# Check cached docs first
docs = read_memory(f"library-docs-{framework}-{feature}")

# If not cached, query
if not docs:
    resolve-library-id(framework)
    docs = get-library-docs(f"/org/{framework}", topic=feature)

# Verify method signatures match current API
verify_api_current(docs)

# Implement using verified patterns
implement_feature_with_verified_api(docs)
```

**Critical Rule:**
> BEFORE implementing with external libraries, query Context7 for current API patterns. Check if implementation uses current, non-deprecated methods.

### Code Archeologist

**Role:** Document what external libraries do in the codebase

**Pattern:**
```python
# Discover library usage via symbol exploration
find_symbol("import", substring_matching=True)

# Document each external library
for library in discovered_libraries:
    resolve-library-id(library.name)
    docs = get-library-docs(f"/org/{library.name}", topic="overview")

    write_memory(f"library-docs-{library.name}", """
    ## Purpose in This Codebase
    [How it's used based on symbol analysis]

    ## Official Documentation
    [From Context7]

    ## Symbol Locations Using This Library
    - [Symbol]: [Location]
    """)

# Reference in architecture overview
architecture_docs += "## External Libraries\n"
for lib in libraries:
    architecture_docs += f"- {lib} - See library-docs-{lib}.md\n"
```

**Benefit:** Implementation team knows both what libraries do AND where they're used.

### Document Architect

**Role:** Link to cached library documentation in user-facing docs

**Pattern:**
```markdown
## FastAPI Dependency Injection

This project uses FastAPI's dependency injection system for database sessions.

**Implementation Pattern:**
\`\`\`python
from fastapi import Depends

async def get_db():
    # Implementation...
\`\`\`

**Official Documentation:**
See `.serena/memories/library-docs-fastapi-dependencies.md` for complete FastAPI dependency injection patterns and best practices (sourced from Context7).

**Why This Approach:**
- Automatic cleanup
- Type-safe
- Testable
```

## Parallel Research Strategy

Context7 works ALONGSIDE web search, not instead of:

### Why Parallel?

```
Official Docs (Context7)     Community (Web Search)
        ↓                             ↓
┌─────────────────┐          ┌──────────────────┐
│ What's official │    +     │ How people       │  =  Complete
│ What's current  │          │ actually use it  │     Picture
│ What's supported│          │ Common gotchas   │
└─────────────────┘          └──────────────────┘
```

### Example: "How do I implement authentication in FastAPI?"

**Context7 provides:**
- Official `OAuth2PasswordBearer` pattern
- Recommended dependency structure
- Current API signatures
- Security best practices from maintainers

**Web Search provides:**
- Real-world implementations
- Integration with databases
- JWT token handling examples
- Common mistakes to avoid

**Synthesis:**
Use official OAuth2PasswordBearer (Context7) with JWT tokens stored in Redis (web search community pattern), following FastAPI's dependency injection (Context7 docs).

## Graceful Fallback

Context7 is **recommended but optional**. Agents handle unavailability gracefully:

```python
try:
    # Attempt Context7
    resolve-library-id("library-name")
    docs = get-library-docs(...)
    status = "Using Context7"
except ToolNotAvailable:
    # Fall back to web search
    docs = WebSearch("library-name official documentation")
    status = "Using web search (Context7 not installed)"

# Never fail or complain - just adapt
write_memory("research", f"""
Status: {status}
[Documentation content...]
""")
```

## Skill: library-docs-navigator

A new skill teaches Claude when and how to use Context7:

**Located:** `skills/library-docs-navigator/SKILL.md`

**Teaches:**
- Detection heuristics (which questions trigger Context7)
- Two-step query pattern (resolve → get-docs)
- Memory caching strategy
- Parallel research approach
- When to use Context7 vs web search vs Serena symbols

**Auto-activates when:** Claude detects library/framework questions

## Integration with Serena Workflow

Context7 complements Serena's symbol-based navigation:

```python
# Complete workflow for implementing a feature

# 1. Activate Serena (internal code understanding)
activate_project(".")
check_onboarding_performed()

# 2. Understand internal structure
get_symbols_overview("src/auth/")

# 3. Check external library docs (Context7)
resolve-library-id("fastapi")
fastapi_docs = get-library-docs("/fastapi/fastapi", topic="security")

# 4. Web search for community patterns
community = WebSearch("fastapi jwt authentication 2025")

# 5. Persist combined research
write_memory("fastapi-auth-implementation", """
## Internal Structure (Serena)
[Symbol locations]

## Official Patterns (Context7)
[FastAPI security documentation]

## Community Insights (Web)
[Real-world examples]

## Implementation Plan
[Synthesis of all sources]
""")

# 6. Implement using all knowledge sources
```

## Example Sessions

### Session 1: Research Specialist - Library Question

```
User: "Research authentication best practices for FastAPI"

Agent Process:
1. Detect library: FastAPI (Python web framework)
2. Parallel research:
   - resolve-library-id("fastapi") → /fastapi/fastapi
   - get-library-docs("/fastapi/fastapi", topic="security authentication")
   - WebSearch("FastAPI authentication best practices 2025")
3. Compare Context7 official docs with web community insights
4. write_memory("fastapi-auth-research", combined_findings)
5. Optional: write_memory("library-docs-fastapi-auth", cache_for_reuse)

Result: Comprehensive research with official + community sources
```

### Session 2: Implementation Engineer - New Project

```
User: "Create a new FastAPI project with authentication"

Agent Process:
1. resolve-library-id("fastapi") → /fastapi/fastapi
2. get-library-docs("/fastapi/fastapi", topic="project structure")
3. Verify: app/ directory structure (not src/)
4. get-library-docs("/fastapi/fastapi", topic="security dependencies")
5. Confirm: OAuth2PasswordBearer is current pattern
6. Implement using verified API
7. Run tests to verify

Result: Project using current FastAPI patterns, not outdated conventions
```

### Session 3: Code Archeologist - Codebase Analysis

```
User: "Analyze the authentication system"

Agent Process:
1. activate_project(.)
2. find_symbol("auth", substring_matching=True)
3. Notice: Uses jsonwebtoken library
4. resolve-library-id("jsonwebtoken") → /auth0/node-jsonwebtoken
5. get-library-docs("/auth0/node-jsonwebtoken", topic="verification")
6. write_memory("library-docs-jsonwebtoken-verification", docs_with_usage_context)
7. write_memory("auth-system", analysis_with_library_references)

Result: Architecture documentation includes what libraries do + where used
```

## Benefits

### For Research

**Accuracy:**
- Authoritative sources (official maintainers)
- Current information (not outdated tutorials)
- Reduced hallucination on APIs
- Correct method signatures

**Comprehensiveness:**
- Official docs + community insights
- Cross-validation of patterns
- Complete understanding

### For Implementation

**Quality:**
- Uses current API patterns
- Follows official recommendations
- Avoids deprecated methods
- Production-ready code

**Efficiency:**
- No manual doc browsing
- Cached for repeated use
- Focused retrieval

### For Documentation

**Reliability:**
- Links to cached library docs
- References official sources
- Explains why patterns were chosen
- Helps future developers

## Troubleshooting

### Context7 Not Found

**Symptom:** `Tool not found: resolve-library-id`

**Solution:**
```bash
# Install Context7 MCP server
claude mcp add context7 [installation-command]

# Verify
claude mcp list
```

**Note:** Agents gracefully fall back to web search if Context7 unavailable.

### Empty Documentation Returned

**Symptom:** Context7 returns no results for library

**Cause:** Library not in Context7's index

**Solution:** Fall back to web search (automatic)

### Wrong Library Selected

**Symptom:** resolve-library-id returns unexpected library

**Solution:**
```python
# Be more specific with library name
resolve-library-id("@vercel/next.js")  # More specific
# instead of
resolve-library-id("next")  # Too generic
```

### Outdated Cached Documentation

**Symptom:** Cached docs don't reflect recent library changes

**Solution:**
```python
# Delete old cache
# (Will trigger fresh Context7 query)
# Or manually query fresh:
resolve-library-id("library-name")
fresh_docs = get-library-docs("/org/library", topic="feature")
write_memory("library-docs-library-feature", fresh_docs)
```

## Best Practices

### DO:
- Query Context7 for external library questions automatically
- Use parallel research (Context7 + web search)
- Cache frequently-used library docs
- Reference cached docs in generated documentation
- Fall back gracefully if Context7 unavailable

### DON'T:
- Skip Context7 and rely solely on LLM knowledge
- Query Context7 for internal codebase questions (use Serena)
- Query Context7 for general programming concepts (use web search)
- Fail if Context7 is unavailable
- Ignore community insights (always combine with web search)

## Configuration

### Skill Configuration

The `library-docs-navigator` skill is automatically loaded when Claude starts.

**Location:** `skills/library-docs-navigator/SKILL.md`

**No configuration needed** - skill teaches appropriate Context7 usage automatically.

### Agent Configuration

All workforce-assistant agents have Context7 integration built-in:

- **research-specialist**: Parallel Context7 + web research
- **implementation-engineer**: API verification before implementing
- **code-archeologist**: Document external dependencies
- **document-architect**: Reference cached library docs

**No configuration needed** - agents use Context7 automatically when appropriate.

## References

- **Skill:** `skills/library-docs-navigator/SKILL.md`
- **Agents:** `agents/{research-specialist,implementation-engineer,code-archeologist,document-architect}.md`
- **Command:** `commands/workspace-init.md` (includes Context7 setup)
- **Serena Integration:** `docs/serena-integration.md` (complementary system)

## Summary

Context7 integration provides:

1. **Automatic library documentation retrieval** when agents detect library questions
2. **Parallel research** combining official docs + community insights
3. **Memory caching** to reduce API calls across sessions
4. **Graceful fallback** to web search if unavailable
5. **Three-tier documentation strategy**: Serena (internal) + Context7 (libraries) + Web (general)

**Result:** More accurate, up-to-date implementations using current library patterns with authoritative sources.
