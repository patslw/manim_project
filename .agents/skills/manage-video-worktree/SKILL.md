---
name: manage-video-worktree
description: "Manage this repository's Manim Git worktrees. Use when explicitly creating a new video worktree, syncing a video branch with base, or promoting commits tagged #base into a recontribution branch. Do not use for ordinary work inside one video."
---

# Manage Video Worktree

Read `docs/workflow.md` before changing branches or worktrees. Preserve
unrelated changes and use the repository scripts instead of rebuilding their
Git operations by hand.

## Create A Video

From the base worktree, run:

```bash
scripts/create-video-worktree.sh <id> <topic-slug>
```

Report the branch and worktree path printed by the script.

## Sync With Base

From a clean `video/*` worktree, run:

```bash
scripts/sync-video-with-base.sh
```

Pass `--fetch` only when the user wants remote refs refreshed. If the script
rejects a dirty worktree, stop and report the files instead of stashing them.

## Promote Reusable Commits

Keep reusable and video-only changes in separate commits. Add `#base` as a
standalone token in the subject or body of each reusable commit.

From the video worktree, run:

```bash
scripts/promote-base-changes.sh
```

The script creates a recontribution branch and cherry-picks only marked
commits. Inspect the resulting history. Ask before pushing or opening a pull
request unless the user already requested those actions.
