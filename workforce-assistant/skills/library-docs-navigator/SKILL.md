---
name: library-docs-navigator
description: Guides intelligent use of Context7 MCP server for retrieving authoritative, up-to-date library documentation. Teaches when to query external library docs, memory caching patterns, and parallel web research strategies.
---

# Library Documentation Navigator Skill

## Purpose

This skill teaches Claude to automatically leverage Context7 (library documentation MCP server) for retrieving authoritative, current documentation for external libraries and frameworks, reducing hallucination on API usage and staying current with evolving library patterns.

## When This Skill Activates

- Implementing features using external libraries (React, FastAPI, Next.js, etc.)
- Questions about library APIs, methods, or patterns
- Debugging library integration issues
- Checking if implementation follows current best practices
- Understanding how external dependencies work
- Before writing code that uses third-party packages

## Prerequisites

**Context7 MCP Server:**
- Context7 should be installed as an MCP server
- Not strictly required (graceful fallback to web search)
- Installation: `claude mcp add context7 ...`
- Provides: `resolve-library-id`, `get-library-docs`

**Serena Memory System:**
- Used for caching library docs across sessions
- Reduces repeated API calls for common libraries
- See **serena-setup** skill for memory workflow

## Detection Heuristics

Automatically use Context7 when questions mention:

### Common Libraries/Frameworks
- **Web**: React, Next.js, Vue, Angular, Svelte, Astro
- **Backend**: FastAPI, Django, Flask, Express, NestJS
- **Databases**: MongoDB, PostgreSQL, Redis, Supabase
- **Cloud**: AWS SDK, Azure SDK, GCP client libraries
- **Mobile**: React Native, Flutter SDK
- **Data**: Pandas, NumPy, TensorFlow, PyTorch
- **DevOps**: Docker, Kubernetes, Terraform

### Trigger Patterns
- "How do I use [library] to..."
- "What's the [library] API for..."
- "Is this the right way to use [library]..."
- "Does [library] support..."
- "[Library] documentation says..."
- "Current [library] best practices for..."

## Two-Step Query Pattern

Context7 requires two-step workflow:

### Step 1: Resolve Library ID
```python
resolve-library-id(libraryName="next.js")
```

Returns Context7-compatible library ID (e.g., `/vercel/next.js`)

### Step 2: Get Documentation
```python
get-library-docs(
    context7CompatibleLibraryID="/vercel/next.js",
    topic="routing",           # Optional: focus area
    tokens=5000                # Optional: context size (default 5000)
)
```

Returns up-to-date documentation and code examples.

## Parallel Research Strategy

Use Context7 ALONGSIDE web search, not instead of:

### Pattern: Triangulate Information
```markdown
1. WebSearch("next.js app router best practices 2025")
   → Community insights, tutorials, real-world usage

2. resolve-library-id("next.js")
   → Get Context7 ID

3. get-library-docs("/vercel/next.js", topic="routing")
   → Official authoritative documentation

4. Compare results:
   - Official docs: What's supported/recommended
   - Web search: How people actually use it, gotchas, patterns
   - Synthesis: Best approach combining both

5. write_memory() with both sources cited
```

### Benefits of Parallel Approach
- **Official docs**: Current API surface, supported patterns
- **Web search**: Real-world usage, common pitfalls, workarounds
- **Cross-validation**: Catch outdated tutorials vs current APIs
- **Comprehensiveness**: Complete picture of library usage

## Memory Caching Pattern

Cache frequently-used library docs to avoid repeated API calls:

### Naming Convention
```
library-docs-{library}-{topic}.md
```

Examples:
- `library-docs-nextjs-routing.md`
- `library-docs-fastapi-async-patterns.md`
- `library-docs-react-hooks-reference.md`

### When to Cache
```markdown
**Cache (common libraries):**
- React hooks reference
- Next.js routing patterns
- FastAPI dependency injection
- Popular libraries used across projects

**Query fresh (niche libraries):**
- Less common packages
- Beta/experimental features
- First-time exploration

**Cache invalidation:**
- Major version changes
- When docs feel outdated
- User reports issues with cached info
```

### Cache Workflow
```python
# Before querying Context7:
1. list_memories()
   → Check for existing library-docs-* entries

2. read_memory("library-docs-nextjs-routing")
   → Use cached if available and recent

3. If not cached or outdated:
   resolve-library-id("next.js")
   get-library-docs("/vercel/next.js", topic="routing")

4. write_memory("library-docs-nextjs-routing", """
   # Next.js Routing Documentation

   **Source:** Context7 `/vercel/next.js`
   **Retrieved:** 2025-10-29
   **Topic:** App Router routing patterns

   [documentation content...]

   **Cross-referenced with:**
   - WebSearch: "next.js routing best practices 2025"
   - Found: [URLs from search results]
   """)
```

## Library Selection

When `resolve-library-id` returns multiple matches:

### Selection Criteria
1. **Exact name match** (prioritize)
2. **Higher documentation coverage** (more code snippets)
3. **Trust score 7-10** (authoritative sources)
4. **Description relevance** to user's question

### Example Response
```markdown
**Context7 Library Resolution:**
- Query: "react hooks"
- Found 3 matches:
  1. `/facebook/react` (Official, Trust: 10, 5000 snippets) ✓ SELECTED
  2. `/react-community/hooks-library` (Community, Trust: 7, 200 snippets)
  3. `/hooks-tutorial/examples` (Tutorial, Trust: 5, 50 snippets)

Using official React docs for most authoritative information.
```

## Graceful Fallback

Context7 may not be installed. Handle gracefully:

```python
# Pattern: Try Context7, fall back to web search
try:
    # Attempt Context7 workflow
    resolve-library-id("library-name")
    get-library-docs(...)
    status = "Context7 available"
except ToolNotAvailable:
    # Fall back to web search
    WebSearch("library-name official documentation")
    status = "Using web search (Context7 not installed)"

# Note status in memory/notes
```

Never fail or complain if Context7 unavailable - just use alternative research methods.

## Integration with Serena Workflow

Context7 complements Serena's symbol navigation:

### Three-Tier Documentation Strategy

**1. Internal Codebase (Serena)**
- Project's own code structure
- Custom implementations
- Local patterns and conventions

**2. External Libraries (Context7)**
- Third-party dependencies
- Framework documentation
- Library API references

**3. General Knowledge (Web Search)**
- Concepts and tutorials
- Troubleshooting and debugging
- Community best practices

### Example Workflow
```markdown
**Task:** Implement authentication with JWT in FastAPI app

1. activate_project(".")  [Serena]
   → Start LSP server

2. get_symbols_overview("src/auth/")  [Serena]
   → See existing auth structure

3. resolve-library-id("fastapi")  [Context7]
   get-library-docs("/fastapi/fastapi", topic="security")
   → Get current FastAPI auth patterns

4. resolve-library-id("python-jose")  [Context7]
   get-library-docs("/mpdavis/python-jose", topic="JWT")
   → Get JWT library documentation

5. WebSearch("fastapi jwt authentication 2025")  [Web]
   → Real-world implementation patterns

6. find_symbol("AuthService")  [Serena]
   → Locate where to implement

7. write_memory("fastapi-jwt-implementation", ...)
   → Persist research combining all sources
```

## Common Patterns

### Pattern: Current API Verification
```markdown
**Goal:** Verify implementation uses current API

1. Read existing code
2. resolve-library-id(detected-library)
3. get-library-docs(..., topic=detected-usage)
4. Compare code against current docs
5. Flag deprecated patterns
6. Suggest updates if needed
```

### Pattern: Feature Discovery
```markdown
**Goal:** Check if library supports desired feature

1. WebSearch("library-name feature-name 2025")
   → Quick check for existence

2. resolve-library-id("library-name")
   get-library-docs(..., topic="feature-name")
   → Official confirmation and API details

3. If supported: Return official implementation
4. If not supported: Suggest alternatives from web research
```

### Pattern: Migration Assistance
```markdown
**Goal:** Update to new library version

1. get-library-docs("/org/library/v1.0.0")  [Old version]
2. get-library-docs("/org/library/v2.0.0")  [New version]
3. Compare APIs and breaking changes
4. WebSearch("library migration v1 to v2")
   → Community migration guides
5. Plan migration with combined insights
```

## Documentation in Notes

When using Context7, document sources:

```markdown
## Library Research: FastAPI Async Patterns

**Context7 Source:**
- Library: `/fastapi/fastapi`
- Topic: async-database
- Retrieved: 2025-10-29T14:30:00Z
- Tokens: 5000

**Key Findings:**
- FastAPI supports async database operations via SQLAlchemy 2.0
- Use `AsyncSession` for database connections
- Dependency injection pattern for session management

**Cross-referenced with:**
- WebSearch: "fastapi sqlalchemy async best practices"
- Found: [community tutorials showing real implementations]

**Synthesis:**
Official docs recommend AsyncSession, community confirms this works well
with PostgreSQL, common pattern is using dependency injection for sessions.

**Cached to:** library-docs-fastapi-async-db.md
```

## Benefits

**Accuracy:**
- Authoritative sources (official docs)
- Current information (not outdated tutorials)
- Reduced hallucination on APIs
- Correct method signatures

**Efficiency:**
- Focused documentation retrieval
- Memory caching reduces API calls
- Faster than manual doc browsing
- Combined with web search for completeness

**Quality:**
- Up-to-date best practices
- Official recommendations
- Verified code examples
- Cross-validation with community usage

## Limitations

**Not Available:**
- When Context7 not installed (use web search)
- For internal/proprietary libraries
- For very niche packages not in Context7

**Not Ideal For:**
- Conceptual explanations (web search better)
- Troubleshooting specific errors (community forums better)
- Historical context (web search better)
- Opinion on library choice (web search for comparisons)

## Integration with Other Skills

- **serena-setup**: Use memory system for caching library docs
- **symbol-navigator**: Context7 for external deps, Serena symbols for internal code
- **task-decomposer**: Use Context7 in research phase of complex tasks
- **url-validator**: Context7 provides verified, authoritative sources
- **research-specialist**: Agent uses Context7 alongside web research

## Example: Bad vs Good

**Bad (Guessing APIs):**
```markdown
User: "How do I create protected routes in Next.js?"

Claude: "Based on common patterns, you probably want to use
middleware like this: [guesses implementation that may be outdated]"
```

**Good (Context7 + Web Research):**
```markdown
User: "How do I create protected routes in Next.js?"

Claude:
1. resolve-library-id("next.js")
2. get-library-docs("/vercel/next.js", topic="middleware authentication")
3. WebSearch("next.js protected routes app router 2025")

"According to official Next.js docs (Context7), the current
recommended approach is using middleware.ts with the matcher config.
Community tutorials confirm this works well with NextAuth.js.

[Provides current, verified implementation]

Sources:
- Context7: /vercel/next.js (middleware patterns)
- Web: [verified URLs from search results]
"
```

**Token Savings:** Minimal (Context7 adds some overhead)
**Accuracy Gain:** Significant (current, official, verified)

## Quick Reference

```markdown
## Context7 Decision Tree

Is this about an external library/framework?
├─ Yes → Use Context7 (automatic)
│   ├─ resolve-library-id(name)
│   ├─ get-library-docs(id, topic, tokens)
│   ├─ Also: WebSearch for community insights
│   └─ Cache: write_memory("library-docs-...")
│
└─ No → Use other tools
    ├─ Internal code → Serena symbol tools
    ├─ Concepts → Web search
    └─ Troubleshooting → Web search + Stack Overflow

Check memory cache first:
1. list_memories()
2. read_memory("library-docs-*") if exists
3. Use cached or query fresh
```

## References

- Context7 MCP server: Library documentation retrieval
- Serena memory system: Cross-session caching (serena-setup)
- Eigent URL policy: Authoritative source verification (url-validator)
- Multi-source research: Parallel investigation patterns
