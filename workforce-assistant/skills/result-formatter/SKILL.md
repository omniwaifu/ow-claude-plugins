---
name: result-formatter
description: Formats task completion reports with structured verification checklists, file changes, and next steps. Ensures consistent, comprehensive task documentation inspired by eigent's TaskResult pattern.
---

# Structured Result Formatter Skill

## Purpose

Provides consistent, structured format for task completion reports with built-in verification checklists.

## When This Skill Activates

- At the end of complex multi-step tasks
- When implementation work is complete
- User requests summary of what was accomplished
- After significant code changes or features

## Standard Task Result Format

```markdown
## Task Result

**Status:** ✓ Success / ✗ Failed / ⚠ Partial

### What Was Accomplished

- [Concise bullet points of deliverables]
- [Focus on outcomes, not activities]
- [Include key decisions made]

### Files Modified

- `path/to/file1.ext` - [Brief description of changes]
- `path/to/file2.ext` - [Brief description of changes]
- `path/to/file3.ext` - [created/updated/deleted]

### Verification Checklist

- [✓] Build succeeds
- [✓] Tests pass (X/Y)
- [✓] Type checking passes
- [✓] Changes tested manually
- [✓] Documentation updated
- [✓] Dependencies installed

### Implementation Details

[Brief technical summary of approach taken]

Key patterns used:
- [Pattern 1]
- [Pattern 2]

### Known Issues / Follow-ups

- [ ] Item 1 requiring future work
- [ ] Item 2 for next session
- [ ] Item 3 pending clarification

### Next Steps (if applicable)

1. [Immediate next action]
2. [Follow-up task]
3. [Future enhancement]

### References

- Research notes: `.agent-notes/research-YYYY-MM-DD.md`
- Tool usage: `.agent-notes/tool-usage-log.md`
- Decisions: `.agent-notes/implementation-decisions.md`
```

## Verification Guidelines

### Build Verification
Always verify changes compile/build:
```bash
npm run build    # Node projects
cargo build      # Rust projects
mvn compile      # Java projects
go build         # Go projects
```

### Test Verification
Run relevant tests:
```bash
npm test                    # All tests
npm test -- path/to/test   # Specific tests
pytest tests/              # Python tests
```

### Type Verification
For typed languages:
```bash
tsc --noEmit               # TypeScript
mypy .                     # Python
cargo check                # Rust
```

## Key Principles from Eigent

1. **Structured Output**: Forced structure prevents rambling, ensures completeness
2. **Verification Focus**: Don't just implement - verify it works
3. **Clear Success Criteria**: Explicit checklist of what "done" means
4. **Reference Context**: Link to notes for future sessions

## Success Criteria

A task is only "complete" when:
- [ ] Implementation finished
- [ ] Code compiles/builds
- [ ] Tests written and passing
- [ ] Manual testing confirms functionality
- [ ] Documentation updated
- [ ] No blocking errors or warnings

## Example Usage

**After implementing user authentication:**

```markdown
## Task Result

**Status:** ✓ Success

### What Was Accomplished

- Implemented JWT-based authentication system
- Added user registration and login endpoints
- Created protected route middleware
- Integrated with existing user database schema

### Files Modified

- `src/auth/jwt.ts` - JWT token generation and verification
- `src/routes/auth.ts` - Registration and login endpoints
- `src/middleware/protect.ts` - Route protection middleware
- `src/types/user.ts` - Extended user types for auth
- `package.json` - Added jsonwebtoken and bcrypt dependencies

### Verification Checklist

- [✓] Build succeeds
- [✓] Tests pass (12/12)
- [✓] Type checking passes
- [✓] Login flow tested manually
- [✓] Protected routes verified
- [✓] Password hashing confirmed

### Implementation Details

Used JWT with httpOnly cookies for security. Passwords hashed with bcrypt (10 rounds).
Protected routes use middleware that verifies token and attaches user to request.

Key patterns:
- Factory pattern for auth service
- Middleware composition for route protection
- Dependency injection for testability

### Known Issues / Follow-ups

- [ ] Add refresh token rotation
- [ ] Implement email verification flow
- [ ] Add rate limiting to login endpoint
- [ ] Setup password reset functionality

### Next Steps

1. Test in staging environment
2. Add monitoring for failed login attempts
3. Document API endpoints
4. Setup CI/CD pipeline tests

### References

- Auth pattern research: `.agent-notes/research-2025-10-24.md`
- Security decisions: `.agent-notes/implementation-decisions.md`
```

## Notes

- Always run verification steps before marking task complete
- If any verification fails, status should be "Partial" not "Success"
- Document any deviations from original plan in Implementation Details
- Link to research notes for decision rationale

## References

- Eigent TaskResult structure (insights.md:479-521)
- Structured output pattern (insights.md:482-489)
- Verification best practices (insights.md:114-119)
