#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/create-scene.sh <number> <slug> <SceneClass>

Creates project/scenes/s<number>_<slug>/ with a storyboard, Manim scene, and
asset directory.

Example:
  scripts/create-scene.sh 010 opening Opening
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -ne 3 ]]; then
  usage >&2
  exit 2
fi

number="$1"
slug="$2"
scene_class="$3"

if [[ ! "$number" =~ ^[0-9]{3}$ ]]; then
  echo "Scene number must contain exactly three digits, such as 010." >&2
  exit 2
fi

if [[ ! "$slug" =~ ^[a-z][a-z0-9_]*$ ]]; then
  echo "Scene slug must use lowercase letters, numbers, and underscores." >&2
  exit 2
fi

if [[ ! "$scene_class" =~ ^[A-Z][A-Za-z0-9]*$ ]]; then
  echo "Scene class must be a valid PascalCase Python class name." >&2
  exit 2
fi

repo_root="$(git rev-parse --show-toplevel)"
scene_id="s${number}_${slug}"
scene_dir="$repo_root/project/scenes/$scene_id"

if [[ -e "$scene_dir" ]]; then
  echo "Scene already exists: $scene_dir" >&2
  exit 1
fi

mkdir -p "$scene_dir/assets"

cat > "$scene_dir/storyboard.md" <<EOF
# $scene_id

## Purpose

Describe what the audience should understand after this scene.

## Narration

Link or copy the approved narration segment.

## Shots

| Time | Narration | Visual | Motion and transition |
| --- | --- | --- | --- |
| | | | |

## References

List the sources used by this scene.
EOF

cat > "$scene_dir/scene.py" <<EOF
from manim import Scene


class $scene_class(Scene):
    def construct(self) -> None:
        pass
EOF

touch "$scene_dir/assets/.gitkeep"

cat <<EOF
Created scene:
  Directory: $scene_dir
  Class:     $scene_class

Render it with:
  scripts/dev.sh manim project/scenes/$scene_id/scene.py $scene_class
EOF
