# Manim Project Base

This repository is the base environment for Manim video projects.

The intended workflow is:

- `base` keeps the reusable base environment.
- Each video uses its own `video/<id>-<topic>` branch.
- Active video branches should be checked out as separate Git worktrees under `../videos/`.
- Shared improvements discovered while making a video should be split into clean commits and brought back to `base`.

Useful commands:

```bash
scripts/create-video-worktree.sh 001 intro-topic
scripts/sync-video-with-base.sh
scripts/promote-base-changes.sh
```

See `docs/workflow.md` for the full workflow.
