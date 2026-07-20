---
name: conventional-commits
description: Suggest or review conventional commit messagesss
---
# Conventional Commit Message Skill

Suggests or reviews conventional commit messages based on local changes or the latest commit.

## When to Use

- User wants a commit message suggestion for their current changes
- User wants feedback on a commit message they wrote
- User asks "what commit message should I use?"

## Workflow

1. **Detect the scope of changes:**
   - Run `git diff --cached` to check staged changes.
   - If no staged changes, run `git diff` to check unstaged changes.
   - If no unstaged changes either, run `git log -1 --format="%H%n%B" && git diff HEAD~1..HEAD` to inspect the latest commit.

2. **Analyze the diff:**
   - Identify what was changed (files, functions, features, bug fixes, refactors, etc.).
   - Determine the primary intent of the change (fix, feat, refactor, chore, docs, style, test, perf, ci, build, revert).

3. **If the user provided a draft commit message:**
   - Compare it against the diff to check accuracy and completeness.
   - Evaluate whether it follows the Conventional Commits spec (see below).
   - Provide specific, actionable feedback: what's good, what to fix, and a suggested revision.

4. **If no draft message was provided:**
   - Generate a conventional commit message that accurately reflects the diff.
   - If multiple concerns are mixed in one diff, suggest breaking them into separate commits (list each with its own message).

5. **Present the result** and ask the user if they want to apply it.

## Conventional Commits Reference

Format:
<type>(<optional scope>): <subject>

[optional body]

[optional footer(s)]

### Types

| Type | Usage |
|------|-------|
| feat | A new feature |
| fix | A bug fix |
| docs | Documentation only |
| style | Formatting, whitespace, semicolons — no code change |
| refactor | Code restructuring without changing behavior |
| perf | Performance improvement |
| test | Adding or updating tests |
| chore | Maintenance, tooling, deps — no production code |
| ci | CI/CD configuration |
| build | Build system or external dependencies |
| revert | Reverting a previous commit |

### Rules

- **subject**: lowercase, imperative mood ("add" not "added"), no period, ≤72 chars
- **scope**: optional, lowercase, noun or short phrase indicating the area (e.g. `auth`, `mailbox`, `sidebar`)
- **body**: optional, explains *why* not *what*, wrap at 72 chars
- **footer**: optional, for breaking changes (`BREAKING CHANGE:`) or issue references (`Refs: INWEB-123`)
- **breaking change**: use `!` after type/scope OR `BREAKING CHANGE:` in footer

## Guidelines

- Always base the message on the **actual diff**, not assumptions.
- Prefer a single concise subject; only add a body if the subject alone doesn't convey intent.
- If the diff touches many unrelated things, suggest splitting commits.
- Never commit unless the user explicitly asks.
- Match the repo's existing commit message style (check `git log --oneline -10`).
