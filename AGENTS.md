# Agent Instructions

This repository is the base environment for Manim video projects.

Read `docs/workflow.md` before making structural, branch, worktree, or project-organization changes.

Core rules:

- Treat this directory as the base worktree for the `base` branch.
- Keep reusable environment, tooling, Manim helpers, templates, and documentation in the base environment.
- Put video-specific work in separate `video/<id>-<topic>` branches, preferably through `git worktree` under `../videos/`.
- Keep reusable changes and video-specific changes in separate commits.
- Add a standalone `#base` tag to the subject or body of each reusable commit
  that should return to `base`.
- Prefer `scripts/create-video-worktree.sh`, `scripts/sync-video-with-base.sh`, and `scripts/promote-base-changes.sh` for routine branch/worktree operations.
- Run Python, Manim, and lint commands through `scripts/dev.sh` unless the
  current shell already came from this flake.
- Let Nix provide system libraries and command-line tools. Manage Python and
  Python packages with `uv` and the repository `.venv`.
- Do not edit unrelated user changes or other worktrees unless explicitly asked.
- Use Conventional Commit-style messages when committing.
- Codex reads this file for repository instructions and discovers project
  skills under `.agents/skills/`.
- Use `docs/` and `README.md` for human-facing setup and workflow material.
  Keep agent-only execution rules in `AGENTS.md` or a focused skill.
