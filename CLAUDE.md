# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A personal **dotfiles** repo. Each application's config lives in its own top-level folder; **Neovim** (under `neovim/`) is the first app. The "product" is the configs themselves, consumed by each app at startup — there is no build, test, or lint step. The canonical source of truth is this repo; configs get symlinked into place (Neovim → `~/.config/nvim`).

Each app folder carries a self-contained `sync` script (`./sync` installs the symlinks, `./sync verify` checks them). The top-level `Makefile` is the main interface and **auto-discovers** apps by globbing `*/sync`, so adding an app needs no `Makefile` edits.

## Files

- `Makefile` — top-level interface. Auto-discovers each app's `sync` script and exposes `make` (sync all), `make verify` (verify all), `make <app>` (sync one), `make <app>.verify` (verify one).
- `neovim/init.vim` — the entire Neovim config: settings, mappings, and the plugin spec. Plain Vimscript with one embedded `lua << EOF ... EOF` block for plugin management. `spring-night` is the active colorscheme (a lazy-managed plugin).
- `neovim/lazy-lock.json` — lazy.nvim's pinned plugin versions. Commit it whenever it changes.
- `neovim/sync` — install script (relocated from the old root `nvimlink`); symlinks `init.vim` and `lazy-lock.json` into `~/.config/nvim`, backing up any pre-existing config first. `./neovim/sync verify` asserts those paths are still symlinks into this repo (exits non-zero otherwise).

To **add a new app**: create a folder, drop its config files in, and add an executable `sync` script supporting `./sync` and `./sync verify` (use `neovim/sync` as a template). The `Makefile` picks it up automatically.

## Plugin management (lazy.nvim)

Plugins are managed by [lazy.nvim](https://github.com/folke/lazy.nvim), **not** pathogen or vim-plug (both were removed). The `lua` block in `init.vim` bootstraps lazy.nvim (clones it to `~/.local/share/nvim/lazy/` on first launch) and declares plugins. No plugin code is vendored in this repo — lazy fetches everything at runtime.

**To add a plugin**: add a spec entry to the `require("lazy").setup({ ... })` table in `neovim/init.vim`, then run `:Lazy sync`, and commit the updated `neovim/lazy-lock.json`. Do not reintroduce pathogen/vim-plug or a `bundle/` directory.

Note the colorscheme plugin is declared with `lazy = false, priority = 1000` so it loads eagerly before other startup; `vim.cmd.colorscheme(...)` is called right after `setup()`. Keep `set termguicolors` (in the Vimscript above the `lua` block) ahead of that call.

## Conventions

- **Leader** is `\` (`let mapleader="\\"`), set before the `lua` block — lazy.nvim requires the leader to be set before it loads.
- `inoremap jk <Esc>` is the escape convention; `tnoremap <Esc>` exits terminal mode.
- `<leader>nv` opens `~/.config/nvim/init.vim`. `<leader>rl` re-sources it, but note lazy.nvim does **not** support re-sourcing the config — it prints "Re-sourcing your config is not supported with lazy.nvim". Restart Neovim (or use `:Lazy reload`) to apply changes.

## Install / verify

- Install: `make neovim` (or `make` for every app), then launch `nvim` to trigger first-run plugin install. `make neovim` is equivalent to running `./neovim/sync` directly.
- Verify the link is intact: `make neovim.verify` (or `make verify` for every app) — handy after moving the repo or switching to a branch that lacks these files; re-run `make neovim` to repair.
- Headless smoke test: `nvim --headless "+source $HOME/.config/nvim/init.vim" +qa` should exit cleanly; `nvim --headless "+Lazy! sync" +qa` installs/updates plugins and regenerates `lazy-lock.json` (written through the symlink into `neovim/`).

## Possible future cleanup

`neovim/init.vim` keeps a couple of Vim-era lines from the original config (`set nocompatible`, `set encoding=utf-8`) that are no-ops under Neovim, and a full conversion to `init.lua` would be more idiomatic. Both are intentionally out of scope to stay faithful to the canonical config — only change them if the user asks.
