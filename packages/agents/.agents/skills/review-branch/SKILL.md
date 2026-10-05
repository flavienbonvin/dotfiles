---
name: review-branch
description: Review the current branch against its parent branch (usually main). Checks for leftover debug code, TODOs, commented code, logic bugs, race conditions, unhandled cases, standards compliance, feature flag or kill switch coverage, sensible test coverage, accessibility, and privacy leaks in logs. Use when the user asks for a code review, a pre PR review, or says "review my branch".
---

# Review branch against parent

Review only the changes introduced by the current branch. Be concise, high signal, no nitpicking. This is a read-only task, never edit files or touch history.

## 1. Get the diff

```bash
BASE_REF=$(git rev-parse --verify -q origin/main || git rev-parse --verify -q main)
BASE=$(git merge-base HEAD "$BASE_REF")
git status --short
git diff "$BASE" --stat
git diff "$BASE"
```

Read the stat first. On a large diff, read it per file or per directory instead of in one dump.

- If the user names another base branch or a PR, use that instead of main.
- `git diff "$BASE"` compares against the working tree, so uncommitted work on the branch is included. Say so in the verdict if the diff contains uncommitted changes.
- With GitButler, HEAD can be the workspace commit and hold several branches. If the user names a branch, diff that branch's tip (`git diff "$BASE" <branch>`) so other agents' work stays out of the review.
- Skip lockfiles, snapshots, and generated files. Only check that generated output matches its source change.
- Read the changed files in full when the diff alone lacks context, and read callers of any changed shared function.
- Load the coding standards from the repo root (AGENTS.md or CLAUDE.md, whichever exists) and from `~/.claude/coding-rules.md`. Honor both, and skip a file that does not exist.

## 2. Review checklist

Scan the diff for each category. Report only real findings and skip categories with nothing to flag. Before reporting, re-read the surrounding code and confirm the problem is reachable. Drop anything tsc, eslint, or prettier already catches.

**Leftovers (blocker if found)**

- `console.log`, `debugger`, `print` statements left in production paths
- TODO, FIXME, HACK comments introduced by this branch
- Commented-out code blocks, `.only` / `.skip` in tests, `@ts-ignore` or `any` added without a reason
- Dead code or exports the branch leaves unused

**Correctness**

- Race conditions: async ordering assumptions, stale closures, concurrent state writes, missing cancellation on unmount
- Effects whose dependency array hides the real data dependency, or that compute data inside the effect
- Unhandled cases: null/undefined paths, empty arrays, error branches, network failure and offline handling
- Data that flows from an API response to storage to a later request and gets overridden along the way
- Logic that will misbehave at runtime, not just style concerns

**Standards**

- Check the diff against the rules loaded in step 1. Cite the rule violated, briefly.

**Feature flag / kill switch**

- New user-facing behavior must sit behind a flag or config gate
- Flag absence or failure to load must degrade to the old behavior, not crash
- Kill switches (`*Disabled`) are read into a named variable, not negated inline
- If no flag exists and the change is risky, flag it as a release risk

**Privacy and security**

- Logs, telemetry, and error reports must not carry user content, filenames, custom names, or addresses
- No secrets, tokens, or keys in code, fixtures, or logs
- Untrusted input rendered as HTML, used in URLs, or passed to `dangerouslySetInnerHTML`

**Tests (common sense, not line coverage)**

- Critical paths covered: happy path, main error path, flag off and on
- Test data uses whole objects from the shared generators, not partial literals
- Do not demand tests for trivial glue, getters, or obvious code
- Note flaky-looking patterns: timing sleeps, shared mutable state between tests

**Accessibility (only for modified UI)**

- Icon buttons need accessible names, decorative icons get `aria-hidden`
- Interactive elements must be real buttons or links, or have roles and keyboard handlers
- Missing `alt`, unlabeled form inputs, modals without focus trap or focus return
- User-facing strings that bypass the translation function

## 3. Output format

Group findings by severity, most severe first.

- Blocker. Must fix before merge: leftovers, reachable races or crashes, unguarded risky rollout, privacy leaks, missing a11y on interactive controls.
- Should fix. Real gaps: unhandled errors, weak test coverage on core paths, standards violations.
- Nits. Optional polish, max 3 items.

Each finding gets a `file:line`, one sentence on the problem, and one sentence on the fix. Write them as a flat list under each severity heading.

End with a one-line verdict: ship it, ship with fixes, or rework. If nothing was found, say "No findings" and give the verdict. Do not pad.

## Ground rules

- Review the diff, not the whole codebase. Pre-existing issues are out of scope unless the change makes them worse.
- Prefer one finding with a clear fix over three speculative ones. If you are unsure, say what you could not verify.
- No praise padding, no restating what the code does.
- If the diff is large, prioritize by risk. Shared code and stateful UI come first.
- Plain prose, no em dashes.
- Never run commands that change state: no commit, checkout, stash, reset, or formatter with write mode.
