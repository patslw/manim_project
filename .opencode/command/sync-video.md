---
description: Rebase the current video worktree onto the base branch.
---

Sync the current video branch with the base environment branch.

Run this from a video worktree:

```bash
scripts/sync-video-with-base.sh $ARGUMENTS
```

If the worktree is dirty or the current branch is not `video/*`, stop and explain the issue.
