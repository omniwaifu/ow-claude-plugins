---
name: refactoring-coordinator
description: Coordinates safe, multi-step refactorings using symbol-level operations. Teaches the Find → Verify → Refactor → Test pattern with LSP tools for precise, language-aware code transformations.
---

# Refactoring Coordinator Skill

## Purpose

Guides safe, systematic refactorings using symbol-level operations from LSP tools. Emphasizes verification before changes and testing after, leveraging language-aware tools over regex-based modifications.

## When This Skill Activates

- Renaming symbols across codebase
- Extracting/moving functions or classes
- Changing function signatures
- Restructuring code organization
- Before symbol-based modifications

## Prerequisites

**CRITICAL: Project must be activated and onboarded BEFORE refactoring.**

See the **serena-setup** skill for the complete workflow. Before refactoring:

```python
# 1. Activate project
activate_project(current_directory)

# 2. Check if onboarded
check_onboarding_performed()

# 3. Read style guide to follow conventions
style_guide = read_memory("code_style")
# Ensure refactorings follow project patterns

# 4. THEN use refactoring tools
rename_symbol(...)
replace_symbol_body(...)
```

**Performance Note:**
- First symbol tool calls may be slow (LSP parsing)
- Pre-index for instant performance: `serena project index`

## Core Refactoring Workflow

### Standard Pattern: Find → Verify → Refactor → Test

```
1. FIND: Locate symbol and all references
2. VERIFY: Understand impact and dependencies
3. REFACTOR: Apply language-aware transformation
4. TEST: Verify changes work correctly
```

## Refactoring Operations

### 1. Safe Rename

**Goal:** Rename symbol throughout codebase

**Using Symbol Tools (Preferred):**
```
Step 1 - Find:
find_symbol(name_path="oldName", include_body=false)
→ Verify it's the right symbol

Step 2 - Verify Impact:
find_referencing_symbols(name_path="oldName", relative_path="...")
→ See all usage sites (expect X references)

Step 3 - Refactor:
rename_symbol(
    name_path="oldName",
    relative_path="src/module.ts",
    new_name="newName"
)
→ LSP updates ALL references automatically

Step 4 - Test:
Bash("npm test")
→ Verify no breakage
```

**Why Symbol Tools:**
- Updates all references atomically
- Language-aware (handles imports, re-exports)
- Respects scope (local vs global)
- Safer than find-and-replace

### 2. Extract Function

**Goal:** Move code block into new function

**Pattern:**
```
Step 1 - Find Context:
find_symbol(name_path="LargeFunction", include_body=true)
→ Read current implementation

Step 2 - Verify Dependencies:
# Identify variables used in extraction target
# Check for side effects

Step 3 - Refactor:
A. Create new function:
   insert_after_symbol(
       name_path="LargeFunction",
       relative_path="...",
       body="function extractedLogic() { ... }"
   )

B. Replace old code:
   replace_symbol_body(
       name_path="LargeFunction",
       relative_path="...",
       body="... extractedLogic() ..."
   )

Step 4 - Test:
Bash("npm test")
```

### 3. Move Symbol Between Files

**Goal:** Relocate class/function to different file

**Pattern:**
```
Step 1 - Find & Copy:
find_symbol(name_path="UtilityClass", include_body=true)
→ Get full definition

Step 2 - Verify Usage:
find_referencing_symbols(name_path="UtilityClass", ...)
→ Identify all import sites

Step 3 - Refactor:
A. Add to new location:
   insert_after_symbol(
       name_path="", # Insert at end
       relative_path="src/utils/new-file.ts",
       body="export class UtilityClass { ... }"
   )

B. Update imports at each usage site

C. Remove from old location:
   # Delete old definition

Step 4 - Test:
Bash("npm run build && npm test")
```

### 4. Replace Implementation

**Goal:** Change function/method body while keeping signature

**Pattern:**
```
Step 1 - Find Current:
find_symbol(name_path="processData", include_body=true)
→ Review current implementation

Step 2 - Verify Signature:
# Ensure new implementation matches expected signature
# Check return type, parameters

Step 3 - Refactor:
replace_symbol_body(
    name_path="processData",
    relative_path="src/processor.ts",
    body="""
    function processData(input: Data): Result {
        // New implementation
        return result;
    }
    """
)

Step 4 - Test:
Bash("npm test -- processor.test")
→ Run specific tests first
```

## Tool Selection for Refactoring

### Use Symbol Tools When:

| Refactoring | Symbol Tool | Why |
|-------------|-------------|-----|
| Rename variable/function | `rename_symbol` | Updates all references |
| Replace function body | `replace_symbol_body` | Preserves signature, handles indentation |
| Insert new method | `insert_after_symbol` | Correct placement, proper spacing |
| Move code | `insert_before_symbol` | Precise positioning |

### Fall Back to Regex When:

| Situation | Why Regex Needed |
|-----------|------------------|
| Multi-line text replacement | Symbol spans not applicable |
| Non-code files | No symbol information |
| Pattern-based changes | Need wildcards/capture groups |

**But verify with symbol tools first!**

## Verification Checklist

Before every refactoring:

- [ ] Found exact symbol location
- [ ] Identified all references
- [ ] Understand dependencies
- [ ] Checked for overloads/shadows
- [ ] Planned test strategy
- [ ] Created backup (git commit)

## Language-Specific Patterns

### TypeScript/JavaScript

```
# Rename with type safety
1. find_symbol("calculateTotal")
2. find_referencing_symbols("calculateTotal", ...)
3. rename_symbol(
     name_path="calculateTotal",
     new_name="computeTotal"
   )
   # LSP updates imports, exports, type refs

# Extract hook (React)
1. find_symbol("Component", include_body=true)
2. Identify state logic
3. insert_after_symbol(
     name_path="Component",
     body="function useCustomLogic() { ... }"
   )
4. replace_symbol_body(
     name_path="Component",
     body="... const data = useCustomLogic() ..."
   )
```

### Python

```
# Rename class method
1. find_symbol("MyClass/old_method")
2. find_referencing_symbols("MyClass/old_method", ...)
3. rename_symbol(
     name_path="MyClass/old_method",
     new_name="new_method"
   )
   # Updates all self.old_method() calls

# Extract function from method
1. find_symbol("MyClass/large_method", include_body=true)
2. insert_before_symbol(
     name_path="MyClass",
     body="def _extracted_logic(): ..."
   )
3. replace_symbol_body(
     name_path="MyClass/large_method",
     body="... self._extracted_logic() ..."
   )
```

### Java

```
# Rename interface implementation
1. find_symbol("/InterfaceName/methodName")
2. find_referencing_symbols("/InterfaceName/methodName", ...)
3. rename_symbol(
     name_path="/InterfaceName/methodName",
     new_name="betterMethodName"
   )
   # Updates interface + all implementations
```

## Multi-Step Refactoring Coordination

For complex refactorings involving multiple files:

```markdown
## Refactoring Plan: Extract Payment Service

### Phase 1: Preparation
- [ ] Find all payment-related symbols
      find_symbol("payment", substring_matching=true)
- [ ] Map dependencies
      find_referencing_symbols for each
- [ ] Create git checkpoint
      git commit -am "Before payment service extraction"

### Phase 2: Create New Service
- [ ] Create service file
      create_text_file("src/services/payment-service.ts", ...)
- [ ] Move PaymentProcessor
      insert_after_symbol in new file
- [ ] Move supporting functions

### Phase 3: Update References
- [ ] Update imports in controller
- [ ] Update imports in tests
- [ ] Update configuration

### Phase 4: Cleanup
- [ ] Remove old code
- [ ] Run tests
      Bash("npm test")
- [ ] Verify build
      Bash("npm run build")
```

## Integration with Workflow Patterns

### With Implementation Engineer Agent

```
Research Specialist:
→ Identifies refactoring need

Code Structure Analyst:
→ Maps dependencies

Refactoring Coordinator (this skill):
→ Plans safe refactoring steps

Implementation Engineer:
→ Executes refactoring with verification
```

### With Safe Mode Guardian Hook

```
Refactoring Coordinator plans:
"replace_symbol_body in production code"

Safe Mode Guardian:
→ Validates change isn't on blocklist

Implementation Engineer:
→ Applies if approved
→ Runs tests immediately
```

## Common Refactoring Patterns

### Pattern: Extract Constant

```
# Instead of repeated magic numbers
1. find_symbol("calculatePrice", include_body=true)
2. insert_before_symbol(
     name_path="calculatePrice",
     body="const TAX_RATE = 0.08;"
   )
3. replace_symbol_body(
     name_path="calculatePrice",
     body="... price * (1 + TAX_RATE) ..."
   )
```

### Pattern: Inline Function

```
# Remove unnecessary indirection
1. find_symbol("simpleWrapper", include_body=true)
2. find_referencing_symbols("simpleWrapper", ...)
3. For each call site:
   # Replace call with inlined implementation
```

### Pattern: Introduce Parameter

```
# Make hardcoded value configurable
1. find_symbol("processData", include_body=true)
2. replace_symbol_body(
     name_path="processData",
     body="""
     function processData(input: Data, maxRetries = 3): Result {
         // Use maxRetries instead of hardcoded 3
     }
     """
   )
3. find_referencing_symbols("processData", ...)
4. Update critical call sites if needed
```

## Error Recovery

If refactoring fails:

```
1. Check git status
   → See what was changed

2. Run tests
   → Identify failures

3. If using rename_symbol:
   → Check LSP didn't miss references
   → Use find_referencing_symbols to verify

4. If tests fail:
   → Revert: git checkout -- <files>
   → Re-analyze with find_symbol
   → Try more targeted approach

5. Document in .agent-notes/
   → What failed, why, how to avoid
```

## Success Criteria

Refactoring complete when:
- [ ] Symbol correctly modified/moved/renamed
- [ ] All references updated (verified with find_referencing_symbols)
- [ ] Tests pass (npm test / pytest / etc)
- [ ] Build succeeds
- [ ] No new warnings/errors
- [ ] Git commit with clear message
- [ ] Notes updated in `.agent-notes/`

## Best Practices

1. **Always use rename_symbol for renames** - Don't use regex
2. **Verify before refactor** - Use find_referencing_symbols
3. **Small steps** - One symbol at a time
4. **Test incrementally** - After each change
5. **Commit often** - Easy rollback
6. **Document symbol locations** - For future reference

## Anti-Patterns to Avoid

❌ **Regex rename without symbol verification**
```
# DON'T: replace_regex("oldName", "newName")
# DO: rename_symbol("oldName", new_name="newName")
```

❌ **Refactoring without reference check**
```
# DON'T: Just replace the definition
# DO: find_referencing_symbols first
```

❌ **Batch changes without testing**
```
# DON'T: Change 10 symbols then test
# DO: Change 1, test, change 1, test
```

❌ **Manual string replacement in multiple files**
```
# DON'T: Edit each file manually
# DO: Use rename_symbol (handles all files)
```

## References

- Symbol Navigator skill for tool selection
- Implementation Engineer for execution patterns
- Eigent verification patterns (insights.md:114-119)
- LSP rename capabilities (serena docs)
