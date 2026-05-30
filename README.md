# stunning-meme

Personal dotfiles. Each application's config lives in its own folder with a
self-contained `sync` script; a top-level `Makefile` is the main interface and
auto-discovers those scripts.

Neovim was the first app: a Lua config (`init.lua` plus modules under `lua/`)
with plugins managed by [lazy.nvim](https://github.com/folke/lazy.nvim).
lazy.nvim bootstraps itself and installs plugins into `~/.local/share/nvim/lazy/`,
so no plugin code is vendored here.

## Layout

- `Makefile` — top-level interface; auto-discovers each app's `sync` script and exposes `make setup` for machine bootstrap.
- `setup` — Ubuntu/Debian bootstrap orchestrator; installs missing prerequisites and apps, skips existing installs by default, and then runs the normal sync flow.
- `lib/backup.sh` — shared helper; each `sync` sources it to archive displaced
  config into `backups/` and commit it.
- `backups/` — committed backups of config a `sync` displaced on first install
  (`backups/<app>/<timestamp>/`); see `backups/README.md`.
- `.githooks/` — this repo's git hooks (not an app); `make hooks` activates them.
  See "Git hooks".
- `neovim/` — Neovim config.
  - `init.lua` — entry point: sets the leader, loads the `lua/config` modules,
    bootstraps lazy.nvim, and auto-imports plugin specs.
  - `lua/config/` — editor settings (`options.lua`) and mappings (`keymaps.lua`).
  - `lua/plugins/` — one file per plugin, each returning a lazy.nvim spec.
  - `lazy-lock.json` — pinned plugin versions.
  - `sync` — symlinks `init.lua`, `lua/`, and `lazy-lock.json` into `~/.config/nvim`;
    `./sync verify` checks it.
- `claude-code/` — Claude Code user config.
  - `settings.json` — global preferences (model, permissions, hooks, env).
  - `hooks/notify.sh` — cross-platform desktop-notification script for the
    `Notification` hook; dispatches to `terminal-notifier`/`osascript` (macOS) or
    `notify-send` (Linux), and is a silent no-op where none exist.
  - `skills/` — user-authored skills (e.g. `commit`).
  - `sync` — symlinks these into `~/.claude`; `./sync verify` checks it. Because
    `~/.claude` also holds credentials and session state, only these tracked
    items are linked/backed up — never the whole directory, never credentials.
- `codex/` — Codex CLI user-authored config.
  - `config.toml` — global Codex preferences, trusted projects, enabled plugins,
    sandbox policy, and shell environment policy.
  - `rules/default.rules` — reusable command approval rules.
  - `skills/` and `memories/` — optional user-authored portable content. Generated
    system skills, sessions, auth, caches, logs, sqlite state, plugin cache, and
    other runtime artifacts stay local under `~/.codex` and are not tracked.
  - `sync` — links tracked files into `~/.codex` one file at a time; `./sync verify`
    checks them. It never moves or backs up the whole `~/.codex` directory.
- `kitty/` — Kitty terminal config, ported from a KDE Konsole setup.
  - `kitty.conf` — font (Hack 11pt), bottom tab bar, background opacity, and the
    16-color ANSI palette, captured from a running Konsole via OSC color queries
    (its built-in default palette, which Profile 1 actually renders).
  - `sync` — symlinks `kitty.conf` into `~/.config/kitty`; `./sync verify` checks it.
- `tmux/` — tmux terminal multiplexer config.
  - `tmux.conf` — conservative defaults for truecolor, mouse support, vi-style
    copy mode, larger scrollback, and simple split/pane bindings.
  - `sync` — symlinks `tmux.conf` into `~/.tmux.conf`; `./sync verify` checks it.

## Setup and sync

```sh
make setup                         # install missing apps, then sync configs
make setup SETUP_FLAGS="--check"   # report planned actions without changing state
make setup SETUP_FLAGS="--app kitty --force"
make setup SETUP_FLAGS="--app codex"
make setup SETUP_FLAGS="--app tmux"
make                               # sync every app only
make verify                        # verify every app's symlinks
make neovim                        # sync just Neovim config
make neovim.verify
make claude-code                   # sync just Claude Code config
make claude-code.verify
make codex                         # sync just Codex config
make codex.verify
make kitty                         # sync just Kitty config
make kitty.verify
make tmux                          # sync just tmux config
make tmux.verify
```

`make setup` is for Ubuntu/Debian machines. It installs missing core prerequisites
(`curl`, `git`, `unzip`, `npm`/Node, `jq`) plus Neovim from the latest upstream
stable tarball into `~/.local/neovim`, Kitty via the official binary installer,
tmux via apt, Claude Code via npm (`@anthropic-ai/claude-code`), and Codex via
npm (`@openai/codex`). It skips apps that already exist by default, especially
when they appear to come from a different source than this repo prefers; pass
`--force` through `SETUP_FLAGS` to opt into reinstall/update behavior.

After dependency setup, the script runs the normal sync flow. The app-specific
`make <app>` targets only link config files: `make neovim` links into
`~/.config/nvim`, `make claude-code` links tracked items into `~/.claude`,
`make codex` links tracked user-authored files into `~/.codex`, and `make kitty`
links into `~/.config/kitty`, and `make tmux` links into `~/.tmux.conf`,
backing up displaced real config into `backups/<app>/<timestamp>/` first.

Smoke tests are plain shell scripts: `sh tests/setup_test.sh` checks setup
policy, `sh tests/codex_sync_test.sh` checks the Codex sync migration against a
temporary HOME, and `sh tests/tmux_sync_test.sh` checks tmux link behavior.

## Git hooks

This repo ships two git hooks in the tracked `.githooks/` dir. Activate them once
per clone — this is separate from `make` and only touches *this repo's* git config
(`core.hooksPath`, covering all worktrees):

```sh
make hooks        # sets core.hooksPath -> .githooks
```

- **`pre-merge-commit`** — on `master`, blocks a merge commit while the working
  tree has uncommitted (unstaged) changes, so stray edits aren't folded into the
  merge. (Real merges with *staged* changes and fast-forward merges are already
  handled by git, so they're not gated here.) Bypass with `git merge --no-verify`.
- **`post-merge`** — on `master`, re-syncs every app (`make`) after a merge/pull,
  skipping when only `backups/` changed. Any config it displaces is backed up and
  committed automatically.

Both no-op on non-`master` branches, so feature-branch worktrees are unaffected.

## Adding a new app

1. Create a folder for it (e.g. `tmux/`) and put its config files inside.
2. Add an executable `sync` script in that folder supporting `./sync` (install
   the symlinks) and `./sync verify` (check them) — see `neovim/sync` as a
   template. To back up displaced config, source `lib/backup.sh` and call
   `repo_backup "$SRC" <app> <paths>` rather than rolling your own.
3. That's it: the `Makefile` auto-discovers the new `sync`, so `make`,
   `make verify`, `make <app>`, and `make <app>.verify` all just work.

## Adding a Neovim plugin

Create `neovim/lua/plugins/<name>.lua` returning a lazy.nvim spec table, then
run `:Lazy sync` and commit the updated `neovim/lazy-lock.json`. No edit to
`init.lua` is needed — `import = "plugins"` picks the file up.
