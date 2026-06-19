---
name: git-commit-rules
description: "Enforce Conventional Commits and sign-off on every commit. Use whenever the user asks to commit code, create a commit, amend a commit, or write a commit message. Applies to all git commit operations — never commit without following these rules."
allowed-tools: Bash(git:*) Read Write
---

# Git Commit Rules

Every commit must follow two non-negotiable rules.

## 1. Conventional Commits Format

```
<type>[optional scope]: <description>
```

**Types:** `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`

**Breaking changes:** Append `!` after type, e.g. `feat!:` or include `BREAKING CHANGE:` footer.

Examples:
- `feat: add user authentication`
- `fix(parser): handle empty input edge case`
- `docs: update API reference`
- `chore: bump dependencies`

Before committing, stage only the intended files and show the user the draft message. Confirm before executing.

## 2. Sign-Off Required

Every commit must be signed off with `--signoff` (`-s`).

The commit command must always include `-s`:

```bash
git commit -s -m "feat: description"
```

Do not omit `-s` under any circumstances.
