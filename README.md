# stunning-meme

Personal dotfiles. Each application's config lives in its own folder with a
self-contained `sync` script; a top-level `Makefile` is the main interface and
auto-discovers those scripts.

Neovim was the first app: plain Vimscript `init.vim` with plugins managed by
[lazy.nvim](https://github.com/folke/lazy.nvim). lazy.nvim bootstraps itself and
installs plugins into `~/.local/share/nvim/lazy/`, so no plugin code is vendored
here.

## Layout

- `Makefile` — top-level interface; auto-discovers each app's `sync` script.
- `neovim/` — Neovim config.
  - `init.vim` — settings, mappings, and the lazy.nvim plugin spec.
  - `lazy-lock.json` — pinned plugin versions.
  - `sync` — symlinks this config into `~/.config/nvim`; `./sync verify` checks it.
- `claude-code/` — Claude Code user config.
  - `settings.json` — global preferences (model, permissions, hooks, env).
  - `hooks/notify.sh` — cross-platform desktop-notification script for the
    `Notification` hook; dispatches to `terminal-notifier`/`osascript` (macOS) or
    `notify-send` (Linux), and is a silent no-op where none exist.
  - `skills/` — user-authored skills (e.g. `commit`).
  - `sync` — symlinks these into `~/.claude`; `./sync verify` checks it. Because
    `~/.claude` also holds credentials and session state, only these tracked
    items are linked/backed up — never the whole directory.

## Install

```sh
make              # sync every app
make verify       # verify every app's symlinks
make neovim       # sync just neovim
make neovim.verify
make claude-code  # sync just Claude Code
make claude-code.verify
```

`make neovim` symlinks the Neovim config into `~/.config/nvim`, backing up any
pre-existing real config first. Then launch `nvim` — lazy.nvim bootstraps and
installs the plugins on first start.

`make claude-code` symlinks `settings.json`, `skills/`, and `hooks/` into
`~/.claude`, backing up any pre-existing real versions per-item first.

## Adding a new app

1. Create a folder for it (e.g. `tmux/`) and put its config files inside.
2. Add an executable `sync` script in that folder supporting `./sync` (install
   the symlinks) and `./sync verify` (check them) — see `neovim/sync` as a
   template.
3. That's it: the `Makefile` auto-discovers the new `sync`, so `make`,
   `make verify`, `make <app>`, and `make <app>.verify` all just work.

## Adding a Neovim plugin

Add a spec entry to the `require("lazy").setup({ ... })` table in
`neovim/init.vim`, then run `:Lazy sync` and commit the updated
`neovim/lazy-lock.json`.
