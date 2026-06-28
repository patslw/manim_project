---
description: Promote shared-path changes from a video branch back to base.
---

Promote reusable base-environment changes from the current video worktree into a recontribution branch based on `base`.

Run this from a video worktree:

```bash
scripts/promote-base-changes.sh $ARGUMENTS
```

Do not commit automatically. After the script applies changes, inspect `git diff` and `git status --short` in the base worktree, then ask before committing and opening a PR/MR into `base`.
