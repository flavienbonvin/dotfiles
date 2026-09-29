---
name: conventional-commits
description: Use when the user asks for a commit message, or wants a draft commit message or the latest commit reviewed. Produces Conventional Commits messages.
model: haiku
---

# Conventional Commit Message Skill

Suggests or reviews conventional commit messages from local changes or the latest commit. Only run read-only git commands.

## Workflow

1. **Learn the repo style:** run `git log --format=%s -10` and match its types and scopes.

2. **Find what to describe:**
    - Run `git status --short` (this also shows untracked files).
    - If there are staged changes, use `git diff --cached` and say that only staged changes are covered.
    - Otherwise use `git diff`, and read new untracked files directly.
    - To review an existing commit, use `git show HEAD`.
    - For large diffs, start with `git diff --stat` and only read the files that matter.

3. **Draft or review:**
    - **No draft from the user:** write a message that reflects the actual diff. If the diff mixes unrelated concerns, propose separate commits, each with its own message.
    - **Draft from the user:** check it against the diff and the rules below. Say what is good, what to fix, and give a corrected version.

4. **Present the result** in the output format below, then ask if the user wants to commit it. Never commit unless they say yes.

## Output Format

````
```
<commit message>
```
One line explaining the choice of type and scope.
````

For several commits, list each message in its own block, with the files it covers.

## Conventional Commits Reference

```
<type>(<optional scope>): <subject>

[optional body]

[optional footer(s)]
```

### Types

| Type     | Usage                                               |
| -------- | --------------------------------------------------- |
| feat     | A new feature                                       |
| fix      | A bug fix                                           |
| docs     | Documentation only                                  |
| style    | Formatting, whitespace, semicolons — no code change |
| refactor | Code restructuring without changing behavior        |
| perf     | Performance improvement                             |
| test     | Adding or updating tests                            |
| chore    | Maintenance, tooling, deps — no production code     |
| ci       | CI/CD configuration                                 |
| build    | Build system or external dependencies               |
| revert   | Reverting a previous commit                         |

### Rules

- **subject**: lowercase, imperative mood ("add", not "added"), no period. Aim for 50 chars, hard limit 72.
- **scope**: optional, lowercase, short noun for the area (e.g. `fish`, `zed`, `claude`). Reuse scopes already in the git log.
- **body**: optional, explains _why_ not _what_, wrapped at 72 chars. Skip it if the subject is enough.
- **footer**: issue references (`Refs: #123`) and breaking changes.
- **breaking change**: `!` after the type/scope, or a `BREAKING CHANGE:` footer.

### Examples

| Bad                                                     | Good                                                                            |
| ------------------------------------------------------- | ------------------------------------------------------------------------------- |
| `fixed bug`                                             | `fix(auth): handle expired token on refresh`                                    |
| `Update stuff.`                                         | `chore(deps): bump prettier to 3.4`                                             |
| `feat: Added new prompt`                                | `feat(fish): replace starship with hydro`                                       |
| `refactor: moved a lot of things and also fixed a typo` | two commits: `refactor(lib): split setup script` and `docs: fix typo in readme` |
