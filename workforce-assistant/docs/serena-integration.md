# Serena Integration Guide

## Overview

This guide explains how to use the Workforce Assistant plugin together with the [Serena MCP server](https://github.com/exa-labs/serena) to unlock powerful symbol-level code navigation and manipulation capabilities.

**What You Get:**
- Token-efficient codebase exploration (70-90% reduction vs file reading)
- Language-aware refactoring (rename symbols across all references)
- Automated skills that teach Claude when to use symbol tools
- Specialized agents for codebase analysis and safe refactoring

## Installation

### 1. Install Workforce Assistant

```bash
# If using Claude Code's plugin system
cd ~/.claude/plugins
git clone <workforce-assistant-repo-url> workforce-assistant

# Verify installation
ls ~/.claude/plugins/workforce-assistant
```

### 2. Install Serena MCP Server

```bash
# Install serena (Python-based MCP server)
pip install serena-mcp

# Or install from source
git clone https://github.com/exa-labs/serena.git
cd serena
pip install -e .
```

### 3. Configure Claude Code to Use Serena

Add serena to your MCP servers configuration:

**For Claude Desktop (`claude_desktop_config.json`):**
```json
{
  "mcpServers": {
    "serena": {
      "command": "python",
      "args": ["-m", "serena"],
      "cwd": "/path/to/your/project"
    }
  }
}
```

**For Claude Code CLI:**
```bash
# Set environment variable
export CLAUDE_MCP_SERVERS='{"serena": {"command": "python", "args": ["-m", "serena"]}}'
```

### 4. Verify Integration

Start a Claude Code session and check for serena tools:

```
You: List available tools

Claude: [Should show tools like find_symbol, get_symbols_overview,
         find_referencing_symbols, rename_symbol, etc.]
```

## How It Works

### Automated Skill Activation

When serena is available, Workforce Assistant's skills automatically guide Claude to use symbol tools:

1. **symbol-navigator** - Teaches when to prefer `find_symbol` over `grep`
2. **code-structure-analyst** - Provides systematic exploration workflows
3. **refactoring-coordinator** - Ensures safe refactoring with verification

These skills activate automatically when Claude is:
- Searching for code entities
- Understanding code structure
- Planning refactorings
- Analyzing dependencies

### Symbol Tools Available (via Serena)

**Core Navigation:**
- `get_symbols_overview(relative_path)` - See file structure without reading full content
- `find_symbol(name_path, depth, include_body)` - Find and optionally read specific symbols
- `find_referencing_symbols(name_path)` - Find all references to a symbol

**Refactoring:**
- `rename_symbol(name_path, new_name)` - Safely rename across all references
- `replace_symbol_body(name_path, body)` - Replace function/method implementation
- `insert_after_symbol(name_path, body)` - Add new code after symbol
- `insert_before_symbol(name_path, body)` - Add new code before symbol

**File Operations:**
- `list_dir(path, recursive)` - Directory listing with depth control
- `read_file(relative_path, start_line, end_line)` - Targeted file reading
- `search_for_pattern(substring_pattern)` - Pattern-based search

## Example Workflows

### Workflow 1: Understanding a New Codebase

**Without Serena (Traditional):**
```
1. read_file("src/main.ts")           # 800 lines, many tokens
2. read_file("src/services/auth.ts")  # 600 lines
3. grep(pattern="authenticate")       # Noisy results
4. read_file("src/models/user.ts")    # 400 lines
```

**With Serena + Workforce Assistant:**
```
1. get_symbols_overview("src/main.ts")
   → See: App, initializeServices, setupRoutes (no bodies)

2. find_symbol("authenticate", include_kinds=[12])
   → Found in: AuthService, OAuthHandler, JWTVerifier

3. find_symbol("AuthService", depth=1)
   → Methods: login, logout, verifyToken, refreshSession

4. find_symbol("AuthService/login", include_body=true)
   → Read only the login method implementation
```

**Token Savings:** ~80% reduction

### Workflow 2: Safe Refactoring

**Task:** Rename `processPayment` to `handlePayment` across codebase

**Workflow:**
```
1. find_symbol("processPayment")
   → Found at: src/services/payment.ts:42

2. find_referencing_symbols("processPayment")
   → 15 references found in:
     - src/controllers/checkout.ts (4 uses)
     - src/api/routes.ts (2 uses)
     - tests/payment.test.ts (9 uses)

3. rename_symbol(
     name_path="processPayment",
     relative_path="src/services/payment.ts",
     new_name="handlePayment"
   )
   → LSP updates all 15 references automatically

4. Bash("npm test")
   → Verify no breakage
```

**Why This Is Better:**
- Language-aware (handles imports, exports, type refs)
- Atomic updates (all references changed together)
- Respects scope (local vs global)
- No regex errors

### Workflow 3: Extracting a Function

**Task:** Extract authentication logic into separate function

**Workflow:**
```
1. find_symbol("LoginController/handleLogin", include_body=true)
   → Review current implementation

2. insert_after_symbol(
     name_path="LoginController/handleLogin",
     relative_path="src/controllers/login.ts",
     body="""
     private async verifyCredentials(username: string, password: string): Promise<boolean> {
         // Extracted logic here
         return isValid;
     }
     """
   )

3. replace_symbol_body(
     name_path="LoginController/handleLogin",
     relative_path="src/controllers/login.ts",
     body="""
     async handleLogin(req: Request, res: Response) {
         const { username, password } = req.body;
         const isValid = await this.verifyCredentials(username, password);
         // Rest of login logic
     }
     """
   )

4. Bash("npm test")
```

### Workflow 4: Architecture Documentation with Code Archeologist

**Task:** Document a new codebase for your team

**Using the code-archeologist sub-agent:**

```
You: @code-archeologist Please analyze the authentication system in this codebase

Claude (as Code Archeologist):
Phase 1: Architectural Overview
- list_dir(".", recursive=true)
- get_symbols_overview("src/auth/")
- Identified entry points: src/auth/index.ts, src/middleware/auth.ts

Phase 2: Component Discovery
- find_symbol("", include_kinds=[5]) in src/auth/
  → Found: BasicAuth, OAuthHandler, JWTVerifier, SessionManager
- find_referencing_symbols for each component
  → Mapped dependencies

Phase 3: Documentation
Creating .agent-notes/auth-system.md...
```

**Generated Documentation:**
```markdown
# Authentication System Analysis

## Architecture Overview
- Type: Multi-strategy authentication
- Strategies: Basic, OAuth 2.0, JWT
- Entry Point: src/auth/index.ts:8 (authenticateRequest)

## Core Components
| Component | Location | Purpose | Dependencies |
|-----------|----------|---------|--------------|
| BasicAuth | src/auth/basic.ts:15 | Username/password auth | UserRepository |
| JWTVerifier | src/auth/jwt.ts:28 | Token validation | crypto, config |
| SessionManager | src/auth/session.ts:12 | Session lifecycle | Redis client |

## Authentication Flow
1. Request → authenticateRequest (index.ts:8)
2. Strategy selection → selectStrategy (index.ts:24)
3. Verification → [Strategy].verify()
4. Session creation → SessionManager.create()

## Symbol Locations for Implementation
- Add new strategy: Implement IAuthStrategy (src/auth/types.ts:5)
- Modify token validation: JWTVerifier/verify (src/auth/jwt.ts:42)
- Extend session storage: SessionManager/store (src/auth/session.ts:34)
```

## Multi-Agent Patterns

### Pattern 1: Research → Implementation

**Scenario:** Add a new feature to existing codebase

```
Step 1: Code Archeologist explores structure
@code-archeologist Analyze the payment processing system

Step 2: Research Specialist finds patterns
@research-specialist How do similar projects implement refunds?

Step 3: Implementation Engineer builds
@implementation-engineer Implement refund functionality following
the patterns identified in .agent-notes/payment-system.md
```

**Why This Works:**
- Code Archeologist uses symbol tools (read-only, efficient)
- Creates documentation with exact symbol locations
- Implementation Engineer knows exactly where to add code
- No duplicate file reading across agents

### Pattern 2: Safe Refactoring at Scale

**Scenario:** Rename multiple symbols across large codebase

```
Step 1: Code Archeologist maps dependencies
@code-archeologist Map all dependencies of the DatabaseConnection class

Step 2: Review impact in notes
Read .agent-notes/database-connections.md
→ See: 42 classes depend on DatabaseConnection

Step 3: Coordinate refactoring
Use refactoring-coordinator skill to plan rename
→ find_referencing_symbols for each dependent
→ rename_symbol with verification

Step 4: Verify with tests
Bash("npm test")
```

### Pattern 3: Incremental Codebase Understanding

**Scenario:** Onboarding to large unfamiliar codebase

```
Session 1: High-level architecture
@code-archeologist Create architectural overview
→ Produces: .agent-notes/architecture-overview.md

Session 2: Dive into specific subsystem
@code-archeologist Analyze the API routing system
→ Uses existing architecture-overview.md as starting point
→ Produces: .agent-notes/api-routing.md

Session 3: Implementation planning
@implementation-engineer Add new API endpoint for user preferences
→ Reads .agent-notes/api-routing.md
→ Follows established patterns
→ Uses symbol tools to find exact insertion points
```

## Best Practices

### 1. Symbol-First Exploration

**Do:**
```
get_symbols_overview("src/module.ts")
find_symbol("ClassName", depth=1)
find_symbol("ClassName/methodName", include_body=true)
```

**Don't:**
```
read_file("src/module.ts")  # Reads entire file unnecessarily
grep("methodName")          # String matching, not symbol-aware
```

### 2. Verification Before Refactoring

**Always follow: Find → Verify → Refactor → Test**

```
# 1. FIND
find_symbol("oldName")

# 2. VERIFY
find_referencing_symbols("oldName")
→ Review all usage sites

# 3. REFACTOR
rename_symbol("oldName", new_name="newName")

# 4. TEST
Bash("npm test")
```

### 3. Document Symbol Locations

**In .agent-notes/, always include symbol paths:**

```markdown
## Implementation Notes

To extend authentication:
- Implement IAuthStrategy interface
  Symbol: /IAuthStrategy (src/auth/types.ts:5)
- Register in strategy map
  Symbol: AuthManager/strategies (src/auth/manager.ts:18)
- Add tests
  Pattern: See BasicAuthTest (tests/auth/basic.test.ts:10)
```

### 4. Leverage Agent Specialization

**Code Archeologist:**
- Use for: Understanding existing code
- Produces: Documentation with symbol locations
- Does NOT: Modify code

**Implementation Engineer:**
- Use for: Writing new code
- Reads: Documentation from Code Archeologist
- Uses: Symbol tools for precise insertion/modification

**Document Architect:**
- Use for: Creating end-user documentation
- Reads: Technical notes from Code Archeologist
- Produces: User-facing docs, API references

## Troubleshooting

### Serena Not Detected

**Symptom:** Skills don't suggest symbol tools

**Check:**
```bash
# Verify serena is installed
python -m serena --version

# Check MCP configuration
cat ~/.config/claude/claude_desktop_config.json

# Test serena directly
python -m serena --help
```

### Symbol Tools Return Empty Results

**Possible Causes:**
1. **LSP not initialized for language**
   - Serena needs language server for TypeScript, Python, etc.
   - Install language servers: `npm install -g typescript-language-server`

2. **Working directory mismatch**
   - Serena's `cwd` must match your project root
   - Update MCP config with correct path

3. **Symbol not public/exported**
   - Private symbols may not be indexed
   - Use `find_symbol` with `substring_matching=true`

### Rename Failed or Incomplete

**If `rename_symbol` doesn't update all references:**

```bash
# 1. Verify with find_referencing_symbols
find_referencing_symbols("symbolName")

# 2. Check git diff
git diff

# 3. If some references missed, use fallback
grep -r "oldName" src/
# Manually update or use Edit tool
```

## Performance Optimization

### Token Usage Comparison

**Large File (2000 lines):**
- `read_file()`: ~8000 tokens
- `get_symbols_overview()`: ~200 tokens
- Savings: **97.5%**

**Finding Specific Method:**
- `read_file()` then manual search: ~8000 tokens
- `find_symbol("Class/method", include_body=true)`: ~50 tokens
- Savings: **99.4%**

### Context Budget Strategy

Following code-structure-analyst skill:

- **Phase 1 (Overview):** 5-10% of context
  - Directory listings
  - Symbol overviews
  - Entry point identification

- **Phase 2 (Discovery):** 20-30% of context
  - Component mapping with depth=1
  - Reference analysis
  - Pattern recognition

- **Phase 3 (Deep Dive):** 60-70% of context
  - Targeted body reads
  - Implementation details
  - Specific file sections

## Advanced Features

### Name Path Navigation

Serena's name path system allows hierarchical navigation:

```
"User"              → Matches User anywhere in hierarchy
"User/authenticate" → Matches authenticate in User class (any depth)
"/User/authenticate"→ Matches ONLY top-level User class
```

**Use Cases:**
- Find specific method in nested classes
- Disambiguate symbols with same name
- Target refactorings precisely

### Symbol Kinds Filtering

Use LSP symbol kinds for precise searches:

```python
find_symbol(
    name_path="",
    include_kinds=[5],      # Classes only
    relative_path="src/"
)

find_symbol(
    name_path="",
    include_kinds=[12],     # Functions only
    relative_path="src/utils/"
)

find_symbol(
    name_path="config",
    include_kinds=[14],     # Constants only
)
```

**Common Symbol Kinds:**
- 5 = Class
- 6 = Method
- 12 = Function
- 13 = Variable
- 14 = Constant
- 11 = Interface

### Depth Control

Control how deep to traverse symbol hierarchies:

```
depth=0  → Just the symbol itself
depth=1  → Symbol + immediate children (methods/properties)
depth=2  → Symbol + children + grandchildren
```

**Example:**
```python
# Get class outline
find_symbol("UserService", depth=1)
→ UserService + all methods (signatures only)

# Get full implementation
find_symbol("UserService", depth=1, include_body=true)
→ UserService + all methods with bodies
```

## Language Support

Serena supports languages through LSP:

- **Full Support:** TypeScript, JavaScript, Python, Java, Go, Rust
- **Partial Support:** C/C++, C#, Ruby, PHP
- **No Support:** Bash, Markdown, JSON (use file tools)

**Check Language Support:**
```python
# If get_symbols_overview returns results → supported
# If returns empty/error → fall back to file tools
```

## Migration Guide

### From File-Heavy to Symbol-First

**Old Pattern:**
```
1. grep -r "className" src/
2. read_file("src/file1.ts")
3. read_file("src/file2.ts")
4. Edit tool with regex
```

**New Pattern:**
```
1. find_symbol("className")
2. find_symbol("className", depth=1, include_body=true)
3. find_referencing_symbols("className")
4. rename_symbol or replace_symbol_body
```

### Updating Existing Workflows

**Before:** Read many files to understand architecture
```markdown
## Research Workflow
1. Read package.json
2. Read all files in src/
3. Grep for patterns
4. Create notes manually
```

**After:** Use code-archeologist agent
```markdown
## Research Workflow
1. @code-archeologist Analyze src/ directory
2. Review .agent-notes/architecture-overview.md
3. Targeted deep dives only when needed
```

## Integration with Other Plugins

Workforce Assistant + Serena works well with:

- **Git hooks:** Capture symbol-level changes in commit messages
- **Testing frameworks:** Verify refactorings with automated tests
- **Documentation generators:** Use symbol locations for API docs
- **Code review tools:** Reference exact symbol paths in reviews

## Further Reading

- [Serena Documentation](https://github.com/exa-labs/serena)
- [LSP Specification](https://microsoft.github.io/language-server-protocol/)
- [Workforce Assistant README](../README.md)
- [Symbol Navigator Skill](../skills/symbol-navigator/SKILL.md)
- [Code Archeologist Agent](../agents/code-archeologist.md)
