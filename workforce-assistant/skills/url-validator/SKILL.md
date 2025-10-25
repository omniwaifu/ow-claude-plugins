---
name: url-validator
description: Enforces strict URL sourcing policy - ensures all URLs come from trusted sources (search results, web pages visited, or user-provided). Prevents URL fabrication inspired by eigent's search agent URL policy.
---

# URL Validator Skill

## Purpose

Enforces disciplined URL usage to prevent fabrication and ensure all web research is traceable to legitimate sources.

## Critical URL Policy

**You are STRICTLY FORBIDDEN from inventing, guessing, or constructing URLs yourself.**

### Allowed URL Sources

1. **Search Results**: URLs returned by WebSearch tool
2. **Visited Pages**: URLs found while browsing with WebFetch
3. **User Provided**: URLs explicitly given by the user
4. **Well-Known Patterns**: Only for official documentation sites

### Forbidden Practices

- ❌ Guessing URL structure
- ❌ Constructing URLs from assumptions
- ❌ Assuming API endpoints exist
- ❌ Fabricating blog post URLs

## When This Skill Activates

- Before using WebFetch with any URL
- When researching APIs, libraries, or services
- When looking for documentation
- When citing sources in notes

## Validation Process

### Step 1: Source Check

Before using any URL, verify its source:

```markdown
**URL Source Verification:**
- URL: [actual URL]
- Source: [WebSearch result / Found on page X / User provided / Official docs]
- Verified: [Yes/No]
```

### Step 2: Search First Pattern

When you need to find information:

1. **Start with search**: Use WebSearch with descriptive query
2. **Extract URLs**: Get URLs from search results
3. **Visit pages**: Use WebFetch with verified URLs
4. **Follow links**: Extract new URLs from visited pages
5. **Document source**: Note where each URL came from

### Example: Finding API Documentation

**CORRECT Approach:**
```markdown
1. WebSearch("library-name official API documentation")
2. Results include verified URL from search
3. WebFetch with that URL
4. Page contains additional links
5. WebFetch those links

Source chain documented: Search → Official docs → Auth page
```

**INCORRECT Approach:**
```markdown
1. Assume API docs are at some constructed path  ❌ FABRICATED
2. WebFetch without verification  ❌ NO SOURCE
```

## Well-Known Official Documentation Exceptions

Only these patterns are acceptable without search:

- `https://docs.python.org/3/`
- `https://docs.rust-lang.org/`
- `https://go.dev/doc/`
- `https://docs.oracle.com/en/java/`
- `https://developer.mozilla.org/`
- `https://nodejs.org/docs/`

For everything else: **Search first, verify, then fetch.**

## Documentation in Notes

When creating research notes, always cite sources:

```markdown
## Finding: Authentication Implementation

**Source:** [verified URL from search/page]
**How found:** WebSearch("auth-service getting started") → First result
**Accessed:** 2025-10-24T10:30:00Z

Key information:
- OAuth 2.0 implementation
- Requires client_id and client_secret
- Token endpoint documented

**Additional source:** [verified URL]
**How found:** Link on quickstart page
**Accessed:** 2025-10-24T10:35:00Z
```

## Red Flags

Watch for these warning signs:

- "I'll check the documentation at [guessed URL]" ❌
- "The API endpoint should be at [constructed URL]" ❌
- "Based on their naming convention, it's probably..." ❌
- "Let me try [speculative URL]" ❌

## Correct Patterns

Use these safe approaches:

- "Let me search for the official documentation" ✓
- "I found this URL in the search results" ✓
- "The page I visited contains a link to this URL" ✓
- "You provided this URL" ✓

## Key Principles from Eigent

1. **Traceability**: Every URL has documented origin
2. **Search-First**: Always start with search tools
3. **No Speculation**: Never guess URL structure
4. **Citation Required**: Note how URL was discovered
5. **Critical Error**: Fabricating URLs is unacceptable

## Implementation Notes

- Research notes auto-capture tool helps track URL sources
- Always include "Source:" and "How found:" in documentation
- For API exploration, search for official docs, don't construct endpoints
- If you catch yourself constructing a URL, STOP and search instead

## Error Recovery

If you realize you used an unverified URL:

1. Acknowledge the mistake
2. Perform proper search to find legitimate source
3. Document the corrected URL source
4. Update any notes with proper citation

## References

- Eigent strict URL policy (insights.md:263-283)
- Search agent prompt guidance (insights.md:267-277)
- Research capture patterns (insights.md:151-216)
