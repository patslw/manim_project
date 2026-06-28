# Development Environment

The development environment has two layers:

- Nix supplies system libraries and tools: Cairo, Pango, FFmpeg, TeX,
  `pkg-config`, a compiler, and `uv`.
- `uv` installs Python 3.12 and project packages into `.venv` from
  `pyproject.toml` and `uv.lock`.

Do not add Python packages to `flake.nix`. Add runtime dependencies with
`uv add <package>` and development dependencies with `uv add --dev <package>`.

## Automatic Shell Activation

The tracked `.envrc` loads the flake through nix-direnv and adds `.venv/bin` to
`PATH`. The repository cannot modify its parent shell, so each workstation
needs direnv shell integration once.

With Home Manager:

```nix
programs.direnv = {
  enable = true;
  enableBashIntegration = true;
  nix-direnv.enable = true;
};
```

Without Home Manager, install both programs:

```bash
nix profile install nixpkgs#direnv nixpkgs#nix-direnv
mkdir -p ~/.config/direnv
echo 'source $HOME/.nix-profile/share/nix-direnv/direnvrc' >> ~/.config/direnv/direnvrc
```

Add the Bash hook to `~/.bashrc`:

```bash
eval "$(direnv hook bash)"
```

Restart the shell, enter the repository, and approve its checked-in `.envrc`:

```bash
direnv allow
uv sync
```

After that, entering the worktree loads the Nix environment and exposes
`.venv/bin`; leaving it restores the previous shell environment. Run
`direnv reload` after changing `flake.nix`, `flake.lock`, or `.envrc`.

## Commands Without Direnv

Use the wrapper from terminals and CI sessions that have not loaded direnv:

```bash
scripts/dev.sh python --version
scripts/dev.sh manim --version
scripts/dev.sh ruff check .
```

The wrapper enters `nix develop` when needed and runs the command through
`uv run`. `uv run` creates or updates `.venv` from the lock file.

Use an interactive `nix develop` shell for a debugging session that needs
several commands:

```bash
nix develop
uv sync
```
