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

Each video worktree keeps its video-only files under `project/`.

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

If a shared improvement starts inside a video branch, split it into its own
commit and add a standalone `#base` tag to the commit subject or body.

Good commit split:

```text
feat(core): add reusable number line helper

#base

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

To collect marked commits, use the promotion helper from the video worktree:

```bash
scripts/promote-base-changes.sh
```

The helper scans commits in `base..HEAD` and selects only messages containing
`#base` as a standalone token. It shows the selected commits, asks for
confirmation, creates `recontribute/<video>-to-base` from `base`, and
cherry-picks the commits in chronological order. Commits without the tag stay
on the video branch, even when they edit shared directories.

The tag grants promotion to the whole commit, so do not mix reusable files and
video-only files in one `#base` commit. If a cherry-pick conflicts, resolve it
in the base worktree and continue with `git cherry-pick --continue`.

## Commit Style

Use Conventional Commit-style messages.

Examples:

```text
feat(core): add reusable graph utilities

#base

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
project/
  script/
    outline.md
    narration.md
  references/
    README.md
  scenes/
    s010_opening/
      storyboard.md
      scene.py
      assets/
  assets/
  main.py
shared/
  manim/
  vscode/
scripts/
docs/
```

Use `scripts/create-scene.sh 010 opening Opening` to create a numbered scene.
Keep every scene independently renderable. Put one-scene assets beside the
scene and video-wide assets in `project/assets/`.

Put cross-video components in `shared/` and commit them separately with
`#base`. Helpers that serve only the current video stay under `project/`.

The exact structure can evolve, but the boundary should stay stable:
`project/` is video-specific, while `shared/` is eligible for base
recontribution. Do not confuse the in-repository `project/` directory with the
external `../videos/` worktree parent.

## Automation Scripts

Create a video worktree from the base worktree:

```bash
scripts/create-video-worktree.sh 001 intro-topic
```

Sync the current video worktree with the base branch:

```bash
scripts/sync-video-with-base.sh
```

Promote commits tagged with `#base` from a video worktree into a
recontribution branch:

```bash
scripts/promote-base-changes.sh
```

All scripts use `BASE_BRANCH=base` by default. Override it only if the base branch is renamed:

```bash
BASE_BRANCH=main scripts/sync-video-with-base.sh
```
