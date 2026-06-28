# Agent Instructions

This repository is the base environment for Manim video projects.

Read `docs/workflow.md` before making structural, branch, worktree, or project-organization changes.

Core rules:

- Treat this directory as the base worktree for the `base` branch.
- Keep reusable environment, tooling, Manim helpers, templates, and documentation in the base environment.
- Put video-specific work in separate `video/<id>-<topic>` branches, preferably through `git worktree` under `../videos/`.
- Keep reusable changes and video-specific changes in separate commits.
- Prefer `scripts/create-video-worktree.sh`, `scripts/sync-video-with-base.sh`, and `scripts/promote-base-changes.sh` for routine branch/worktree operations.
- Do not edit unrelated user changes or other worktrees unless explicitly asked.
- Use Conventional Commit-style messages when committing.
