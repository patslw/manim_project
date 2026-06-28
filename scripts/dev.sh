#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/dev.sh <command> [args...]

Runs a command with Nix system dependencies and the uv-managed Python
environment. The first run may create .venv and install locked dependencies.

Examples:
  scripts/dev.sh python --version
  scripts/dev.sh manim project/scenes/s010_opening/scene.py Opening
  scripts/dev.sh ruff check .
EOF
}

if [[ $# -eq 0 || "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

if [[ -n "${IN_NIX_SHELL:-}" ]]; then
  exec uv run "$@"
fi

exec nix develop --command uv run "$@"
