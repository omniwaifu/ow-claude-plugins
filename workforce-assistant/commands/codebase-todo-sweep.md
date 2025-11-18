---
description: Analyze codebase and insert TODO comments for code issues
allowed-tools: mcp__plugin_workforce-assistant_serena__*, Read, Edit, Grep, Glob, Bash
argument-hint: [scan|apply|clean] [path]
---

# Codebase TODO Sweep

Perform systematic code quality analysis to identify issues and optionally insert TODO comments.

## Arguments

- **Mode**: `$1` (required) - One of: `scan`, `apply`, `clean`
- **Path**: `$2` (optional) - Specific file or directory to analyze
- **Full args**: `$ARGUMENTS`

## Execution

### Mode: scan

If `$1` is "scan":

1. **Determine scope:**
   - If `$2` provided: analyze that path only
   - If no `$2`: analyze entire codebase
   - Skip: node_modules/, .git/, __pycache__/, venv/, dist/, build/

2. **Use Serena for efficient analysis:**
   - Call `get_symbols_overview` for each file to understand structure
   - Use `find_symbol` with `include_body=true` for detailed analysis
   - Apply heuristics to detect issues

3. **Issues to detect:**
   - **Code smells**: Functions >50 lines, deep nesting (>4 levels), high complexity
   - **Missing docs**: Undocumented public functions/classes
   - **Stubs**: Functions with only `pass`, `...`, or `return None`
   - **Bad naming**: Single-letter variables (except i,j,k,x,y), unclear names
   - **Unimplemented**: Empty functions, `NotImplementedError`
   - **Contextual issues**: Patterns inconsistent with codebase

4. **Generate report:**
   ```
   # Code Quality Sweep Report

   Scope: [path or "entire codebase"]
   Files analyzed: [count]
   Total issues: [count]

   ## Summary by Type
   - Code Smells: [count]
   - Missing Documentation: [count]
   - Stubs/Unimplemented: [count]
   - Confusing Code: [count]
   - Bad Naming: [count]

   ## Issues by File

   ### path/to/file.py ([count] issues)

   **[Type]** Line [num] - [symbol]
   - Issue: [description]
   - Would insert: `TODO(sweep): [comment]`
   ```

5. **Save findings:**
   - Use `write_memory` with filename `todo-sweep-[timestamp].md`

### Mode: apply

If `$1` is "apply":

1. **Perform analysis** (same as scan mode steps 1-3)

2. **For each issue found:**
   - Determine comment type:
     - `TODO(sweep):` - General improvements
     - `FIXME(sweep):` - Critical issues/broken functionality
     - `HACK(sweep):` - Code smells needing refactoring
     - `NOTE(sweep):` - Missing documentation

   - Determine insertion point:
     - Function issues: line before function definition
     - Code block issues: line before problematic block
     - Variable issues: line where variable defined

   - Format comment with language-appropriate syntax:
     - Python: `#`
     - JavaScript/TypeScript/C/C++/Rust/Go: `//`
     - HTML/XML: `<!-- -->`
     - CSS: `/* */`

   - Use `Edit` tool to insert comment
   - Check if `(sweep)` tag already exists at location (avoid duplicates)

3. **Generate summary:**
   ```
   # TODO Comments Applied

   Files modified: [count]
   Comments inserted: [count]

   ## Modified Files
   - path/to/file1.py: [count] comments
   - path/to/file2.py: [count] comments

   ## By Type
   - TODO(sweep): [count]
   - FIXME(sweep): [count]
   - HACK(sweep): [count]
   - NOTE(sweep): [count]

   Search for "(sweep)" to find all marked issues.
   ```

### Mode: clean

If `$1` is "clean":

1. **Find all sweep comments:**
   - Use `search_for_pattern` with regex: `(TODO|FIXME|HACK|NOTE)\(sweep\)`
   - Search entire codebase (or `$2` if provided)

2. **Remove comments:**
   - For each match, use `Edit` tool to remove the entire comment line
   - Match exact indentation and whitespace

3. **Generate summary:**
   ```
   # Sweep Comments Removed

   Files cleaned: [count]
   Comments removed: [count]

   ## Cleaned Files
   - path/to/file1.py: [count] removed
   - path/to/file2.py: [count] removed
   ```

### Invalid mode or no arguments

If `$1` is not one of the valid modes or is empty:

```
Usage: /codebase-todo-sweep <mode> [path]

Modes:
  scan   - Analyze and report issues without modifying files
  apply  - Analyze and insert TODO comments into files
  clean  - Remove all sweep-generated TODO comments

Examples:
  /codebase-todo-sweep scan
  /codebase-todo-sweep apply src/
  /codebase-todo-sweep clean
```

## Detection Heuristics

### Function Length
```
Count non-empty, non-comment lines in function body
If > 50 lines:
  Flag as TODO(sweep): "Function too long, break into smaller functions"
```

### Missing Documentation
```
For each public function/class (not starting with _):
  If no docstring/comment before definition:
    Flag as NOTE(sweep): "Add docstring explaining purpose, params, return value"
```

### Stub Detection
```
If function body contains ONLY: pass, ..., or return None:
  Flag as FIXME(sweep): "Implement function logic or remove if not needed"
```

### Bad Naming
```
For variable names:
  If single letter (except i,j,k in loops, x,y for coordinates):
    Flag as TODO(sweep): "Rename to descriptive name"

For function names:
  If no verb in name:
    Flag as NOTE(sweep): "Function name should describe action (get_*, calculate_*, etc.)"
```

### Complexity
```
Count nesting depth of if/for/while/try blocks
If depth > 4:
  Flag as HACK(sweep): "Reduce nesting complexity, extract logic to functions"
```

## Important Notes

- Be conservative: only flag genuine issues
- Context matters: long test functions may be acceptable
- Avoid noise: skip autogenerated code, vendored dependencies
- Preserve formatting: match file's existing comment style and indentation
- Safety: verify Edit operations succeed before proceeding
