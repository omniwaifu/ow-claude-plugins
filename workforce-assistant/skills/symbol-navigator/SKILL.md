---
name: symbol-navigator
description: Guides efficient code navigation using symbol-level operations from LSP tools (like serena) over file-based operations. Teaches when to use find_symbol, get_symbols_overview, and find_referencing_symbols for token-efficient codebase exploration.
---

# Symbol Navigator Skill

## Purpose

This skill teaches Claude to leverage symbol-level code understanding tools (provided by LSP-based MCP servers like serena) for efficient codebase navigation, preferring symbolic operations over reading entire files.

## When This Skill Activates

- Exploring unfamiliar codebases
- Searching for classes, functions, or methods
- Understanding code structure and relationships
- Analyzing dependencies and references
- Before reading large files

## Prerequisites

**CRITICAL: Project must be activated BEFORE using symbol tools.**

See the **serena-setup** skill for the complete workflow. Summary:

```python
# ALWAYS FIRST:
activate_project(current_directory)
check_onboarding_performed()

# THEN use symbol tools:
get_symbols_overview(...)
find_symbol(...)
```

**Performance Note:**
- First symbol tool calls may be slow (LSP parsing files)
- Cache persists in `.serena/cache/`
- Recommend pre-indexing: `serena project index`
- Subsequent calls are instant (cache hits)

## Symbol Tools vs File Tools

### Use Symbol Tools When:
- **Searching for specific code entities** (classes, functions, methods)
- **Understanding code structure** without reading full files
- **Finding all references** to a symbol
- **Performing refactorings** (renames, replacements)
- **Analyzing dependencies** between code entities

### Fall Back to File Tools When:
- Symbol tools not available (no LSP MCP server)
- Working with non-code files (markdown, JSON, YAML)
- Needing full file context including comments/docs
- Working with dynamically generated code

## Tool Selection Decision Tree

### 1. Finding Code by Name

**Goal:** Find a class/function/method by name

**Prefer:**
```
find_symbol(name_path="ClassName")
```

**Over:**
```
grep(pattern="class ClassName")
read_file("path/to/file.py")
```

**Why:** Symbol search is language-aware, finds exact definitions, provides location info

### 2. Understanding File Structure

**Goal:** See what's in a file before reading it

**Prefer:**
```
get_symbols_overview(relative_path="src/service.ts")
```

**Over:**
```
read_file("src/service.ts")
```

**Why:** Overview shows top-level structure (classes/functions) without full bodies, uses fewer tokens

### 3. Finding References/Usage

**Goal:** Find where a symbol is used

**Prefer:**
```
find_referencing_symbols(name_path="DatabaseConnection", relative_path="src/db.ts")
```

**Over:**
```
grep(pattern="DatabaseConnection")
```

**Why:** Language-aware, finds actual references not just string matches, includes context

### 4. Code Modification

**Goal:** Change a function/method

**Prefer:**
```
replace_symbol_body(name_path="calculateTotal", relative_path="src/cart.ts", body="...")
```

**Over:**
```
regex_replace(pattern="def calculateTotal.*?(?=\ndef)", repl="...")
```

**Why:** Precise, language-aware, handles indentation, safer

## Name Path System

Symbol tools use **name paths** for hierarchical navigation:

### Simple Name
```
find_symbol(name_path="authenticate")
```
Matches: `authenticate`, `User/authenticate`, `Admin/User/authenticate`

### Relative Path
```
find_symbol(name_path="User/authenticate")
```
Matches: `User/authenticate`, `Admin/User/authenticate`
Does NOT match: `authenticate` (missing parent)

### Absolute Path
```
find_symbol(name_path="/User/authenticate")
```
Matches: ONLY `User/authenticate` (top-level User class)
Does NOT match: `Admin/User/authenticate`

### With Depth
```
find_symbol(name_path="User", depth=1)
```
Returns User class + its immediate children (methods/properties)

## Symbol Kinds

Filter by symbol type for precision:

```python
# LSP Symbol Kinds (use integer values)
5  = Class
6  = Method
12 = Function
13 = Variable
14 = Constant
```

**Example:**
```
find_symbol(
    name_path="config",
    include_kinds=[14],  # Only constants
    relative_path="src/"
)
```

## Efficient Exploration Workflow

### Phase 1: High-Level Structure
```
1. get_symbols_overview("src/main.ts")
   → See top-level classes/functions

2. find_symbol(name_path="App", depth=1)
   → Get App class + immediate children
```

### Phase 2: Targeted Investigation
```
3. find_symbol(name_path="App/init", include_body=True)
   → Read only the specific method

4. find_referencing_symbols(name_path="App/init", relative_path="src/main.ts")
   → See where init is called
```

### Phase 3: Deep Dive (if needed)
```
5. read_file("src/main.ts", start_line=50, end_line=100)
   → Read specific section if symbol tools insufficient
```

## Integration with Serena Memories

When using symbol tools for research, persist findings with `write_memory()`:

```python
write_memory("auth-flow-analysis", """
# Authentication Flow Analysis

## Symbol Discovery
- `find_symbol("authenticate")` → Found 3 implementations:
  - `/auth/basic.ts:15` - BasicAuth/authenticate
  - `/auth/oauth.ts:42` - OAuthHandler/authenticate
  - `/auth/jwt.ts:28` - JWTVerifier/authenticate

## Usage Analysis
- `find_referencing_symbols("BasicAuth/authenticate")` → 12 references
  - Primary callers: LoginController, APIGateway

## Decision
Use JWTVerifier (modern, stateless, used in 40% of endpoints)

## Symbol Locations
- JWTVerifier/authenticate: src/auth/jwt.ts:28
- LoginController: src/controllers/login.ts:42

## Source
Symbol navigation via Serena LSP tools
""")
```

## Checking for Symbol Tool Availability

Before using symbol tools, check if LSP MCP server is available:

```markdown
## Quick Check

1. Try: `get_symbols_overview(".")`
2. If error about unknown tool → LSP tools not available
3. Fall back to file-based operations
```

## Common Patterns

### Pattern: Find and Modify
```
1. find_symbol(name_path="processPayment", include_body=True)
2. Review current implementation
3. replace_symbol_body(name_path="processPayment", relative_path="...", body="...")
4. Verify with tests
```

### Pattern: Impact Analysis
```
1. find_symbol(name_path="DatabaseConnection")
2. find_referencing_symbols(name_path="DatabaseConnection", ...)
3. Analyze all call sites before making changes
4. write_memory() to persist findings
```

### Pattern: Rename Safely
```
1. find_symbol(name_path="oldName")
2. find_referencing_symbols(name_path="oldName", ...)
3. rename_symbol(name_path="oldName", new_name="newName")
   → LSP handles all references automatically
```

## Benefits

**Token Efficiency:**
- Don't read entire files when you need one function
- Symbol overview >> full file read
- Precise targeting saves context

**Accuracy:**
- Language-aware (not string matching)
- Understands scope and hierarchy
- Finds definitions, not just occurrences

**Safety:**
- Symbol renames update all references
- Respects language syntax
- Reduces regex errors

## Limitations

**Not Available:**
- When no LSP MCP server installed
- For unsupported languages
- For dynamically generated code

**Not Ideal For:**
- Reading comments/docstrings
- Understanding business logic flow
- Configuration files
- Non-code assets

## Example Session

**Bad (File-Heavy):**
```
1. read_file("src/services/payment.ts")         # 500 lines
2. read_file("src/models/transaction.ts")      # 300 lines
3. grep(pattern="PaymentProcessor")           # Noisy results
4. regex_replace("class PaymentProcessor.*", ...) # Error-prone
```

**Good (Symbol-Aware):**
```
1. get_symbols_overview("src/services/payment.ts")  # 20 lines
   → See: PaymentProcessor, RefundHandler, validateCard
2. find_symbol("PaymentProcessor", depth=1)         # 50 lines
   → Get class + methods
3. find_referencing_symbols("PaymentProcessor", ...)
   → 8 call sites identified
4. replace_symbol_body("PaymentProcessor/process", ...)
   → Precise, safe replacement
```

**Tokens Saved:** ~80% reduction in context usage

## Integration with Other Skills

- **task-decomposer**: Use symbol tools for codebase discovery phase
- **result-formatter**: Document symbol locations in results
- **url-validator**: N/A (different domain)

## References

- Serena MCP server: Symbol-level LSP tools
- LSP Symbol Kinds: (insights.md:symbol-kinds)
- Name path patterns: (insights.md:name-paths)
