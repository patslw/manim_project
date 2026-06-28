# Manim Project Base

This repository is the base environment for Manim video projects.

The intended workflow is:

- `base` keeps the reusable base environment.
- Each video uses its own `video/<id>-<topic>` branch.
- Active video branches should be checked out as separate Git worktrees under `../videos/`.
- Mark reusable commits with `#base` in the commit message. The promotion
  script brings only those commits back to `base`.

Useful commands:

```bash
scripts/create-video-worktree.sh 001 intro-topic
scripts/sync-video-with-base.sh
scripts/promote-base-changes.sh
```

Inside a video worktree, prepare the Python environment and check Manim:

```bash
direnv allow
uv sync
scripts/dev.sh manim --version
```

See `docs/environment.md` for shell setup and `docs/workflow.md` for the full
branch and video workflow.
