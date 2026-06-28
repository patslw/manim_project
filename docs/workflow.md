# Manim Project Workflow

This repository is the base environment for Manim video projects. The base branch keeps reusable infrastructure, while each video should live on its own branch and worktree.

## Goals

- Keep the base environment stable and reusable.
- Let each video evolve independently without mixing unrelated scripts, assets, and experiments.
- Make reusable improvements easy to bring back into the base environment.
- Support multiple active videos at the same time through Git worktrees.

## Branch Model

Use `base` as the base environment branch for this repository.

Use one branch per video:

```text
base
video/001-topic
video/002-topic
video/experiment-name
```

The `base` branch should contain shared project infrastructure:

- Python environment files, such as `pyproject.toml`, `requirements.txt`, lock files, or tool config.
- Shared Manim utilities, components, templates, and helper scripts.
- Documentation for the project workflow.
- Common assets or asset-processing tools that are useful across videos.

Video branches should contain video-specific work:

- Scene code for a specific video.
- Video-only assets, notes, scripts, and experiments.
- Temporary rendering experiments that should not become part of the base environment.

## Worktree Layout

Recommended local layout:

```text
manim_project/
  base/              # base branch, base environment
  videos/
    video-001/       # video/001-topic branch
    video-002/       # video/002-topic branch
```

The current repository directory is expected to be the base worktree:

```text
/home/pats/projects/manim_project/base
```

Create a new video worktree from the base directory:

```bash
scripts/create-video-worktree.sh 001 topic
```

List worktrees:

```bash
git worktree list
```

Remove a worktree when a video is archived or no longer active:

```bash
git worktree remove ../videos/video-001
git worktree prune
```

## Daily Workflow

Start shared environment work in the base worktree:

```bash
cd /home/pats/projects/manim_project/base
git switch base
```

Start video-specific work in that video's worktree:

```bash
cd /home/pats/projects/manim_project/videos/video-001
```

Keep video branches up to date with the base environment:

```bash
git fetch
git rebase base
```

If everything is local and `base` is already current, this is often enough:

```bash
git rebase base
```

Or use the helper script from a video worktree:

```bash
scripts/sync-video-with-base.sh
```

## Bringing Shared Work Back To Base

Prefer making shared improvements directly on `base` in the base worktree.

If a shared improvement starts inside a video branch, split it into its own commit before moving it back to `base`.

Good commit split:

```text
feat(core): add reusable number line helper
feat(video-001): use number line helper in opening scene
```

Avoid mixed commits:

```text
feat: update helper and video scene
```

For important shared changes, prefer a recontribution branch and a PR/MR over directly changing `base`. This leaves a reviewable record on GitHub and makes the base environment history easier to audit.

Create a recontribution branch manually:

```bash
cd /home/pats/projects/manim_project/base
git switch base
git switch -c recontribute/video-001-topic-to-base
git cherry-pick <commit-hash>
git push -u origin recontribute/video-001-topic-to-base
```

Then open a PR/MR into `base`. After it is merged, update the video branch:

```bash
cd /home/pats/projects/manim_project/videos/video-001
git rebase base
```

For shared-path changes, use the promotion helper from the video worktree:

```bash
scripts/promote-base-changes.sh
```

The helper only considers approved shared paths, shows the patch, asks for confirmation, creates a `recontribute/<video>-to-base` branch from `base`, applies the patch there, and leaves review plus commit to the user.

Approved shared paths currently include:

- `AGENTS.md`, `README.md`, and `docs/`.
- `scripts/`, `src/`, and `templates/`.
- `.opencode/`, `.agents/`, and `.gitmodules`.
- `flake.nix`, `flake.lock`, `manim.cfg`, and Python dependency files.

New shared files in a video worktree must be tracked or marked with intent-to-add before promotion:

```bash
git add -N path/to/new-shared-file
scripts/promote-base-changes.sh
```

## Commit Style

Use Conventional Commit-style messages.

Examples:

```text
feat(core): add reusable graph utilities
fix(core): handle missing asset directory
docs(workflow): document video worktree model
feat(video-001): add intro scene
chore(video-002): organize source assets
```

Suggested scopes:

- `core` for reusable base environment changes.
- `workflow` for project process documentation.
- `video-001`, `video-002`, etc. for video-specific changes.
- `assets` for shared asset pipeline changes.

## Directory Guidelines

Keep reusable code separate from video-specific code.

Suggested structure:

```text
src/
  manim_base/
    components/
    utils/
    templates/
scripts/
docs/
projects/
  001-topic/
    scene.py
    assets/
    notes.md
```

The exact structure can evolve, but the rule should stay stable: shared code belongs in shared directories, and video-only code belongs under that video's area. Do not confuse an in-repository video source directory with the external `../videos/` worktree parent directory.

## Rules For OpenCode And Other Agents

- Treat `/home/pats/projects/manim_project/base` as the base environment worktree.
- Do not put video-specific work directly into the base environment unless the user explicitly asks for that.
- When creating a new video, prefer a new `video/<id>-<topic>` branch through `git worktree`.
- Keep shared changes and video changes in separate commits whenever possible.
- Do not modify or remove another worktree's changes unless explicitly instructed.
- Before committing, inspect the worktree and commit only intended files.

The project-level OpenCode config is `opencode.json`. It loads `AGENTS.md` and the project skill directories. Restart OpenCode after changing `opencode.json`, `.opencode/command/`, `.opencode/skills/`, or agent instructions.

Available OpenCode commands:

- `/create-video <id> <topic-slug>` creates a `video/<id>-<topic>` branch and worktree.
- `/sync-video` rebases the current video branch onto `base`.
- `/promote-base` applies shared-path changes from the current video worktree into a recontribution branch for review.

## Automation Scripts

Create a video worktree from the base worktree:

```bash
scripts/create-video-worktree.sh 001 intro-topic
```

Sync the current video worktree with the base branch:

```bash
scripts/sync-video-with-base.sh
```

Promote shared-path changes from a video worktree into a recontribution branch:

```bash
scripts/promote-base-changes.sh
```

All scripts use `BASE_BRANCH=base` by default. Override it only if the base branch is renamed:

```bash
BASE_BRANCH=main scripts/sync-video-with-base.sh
```
