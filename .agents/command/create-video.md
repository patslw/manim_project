---
description: Create a new Manim video branch and worktree.
---

Create a new video worktree using the repository workflow.

Arguments: `$ARGUMENTS`

Expected argument format:

```text
<id> <topic-slug>
```

Run this from the base worktree:

```bash
scripts/create-video-worktree.sh $ARGUMENTS
```

After it finishes, report the created branch and worktree path.
