# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A personal **Neovim** configuration. The "product" is the config itself, consumed by Neovim at startup — there is no build, test, or lint step. The canonical source of truth is this repo; it gets symlinked into `~/.config/nvim`.

## Files

- `init.vim` — the entire config: settings, mappings, and the plugin spec. Plain Vimscript with one embedded `lua << EOF ... EOF` block for plugin management. `spring-night` is the active colorscheme (a lazy-managed plugin).
- `lazy-lock.json` — lazy.nvim's pinned plugin versions. Commit it whenever it changes.
- `nvimlink` — install script; symlinks `init.vim` and `lazy-lock.json` into `~/.config/nvim`, backing up any pre-existing config first.

## Plugin management (lazy.nvim)

Plugins are managed by [lazy.nvim](https://github.com/folke/lazy.nvim), **not** pathogen or vim-plug (both were removed). The `lua` block in `init.vim` bootstraps lazy.nvim (clones it to `~/.local/share/nvim/lazy/` on first launch) and declares plugins. No plugin code is vendored in this repo — lazy fetches everything at runtime.

**To add a plugin**: add a spec entry to the `require("lazy").setup({ ... })` table in `init.vim`, then run `:Lazy sync`, and commit the updated `lazy-lock.json`. Do not reintroduce pathogen/vim-plug or a `bundle/` directory.

Note the colorscheme plugin is declared with `lazy = false, priority = 1000` so it loads eagerly before other startup; `vim.cmd.colorscheme(...)` is called right after `setup()`. Keep `set termguicolors` (in the Vimscript above the `lua` block) ahead of that call.

## Conventions

- **Leader** is `\` (`let mapleader="\\"`), set before the `lua` block — lazy.nvim requires the leader to be set before it loads.
- `inoremap jk <Esc>` is the escape convention; `tnoremap <Esc>` exits terminal mode.
- `<leader>nv` opens `~/.config/nvim/init.vim`. `<leader>rl` re-sources it, but note lazy.nvim does **not** support re-sourcing the config — it prints "Re-sourcing your config is not supported with lazy.nvim". Restart Neovim (or use `:Lazy reload`) to apply changes.

## Install / verify

- Install: `./nvimlink` (then launch `nvim` to trigger first-run plugin install).
- Headless smoke test: `nvim --headless "+source $HOME/.config/nvim/init.vim" +qa` should exit cleanly; `nvim --headless "+Lazy! sync" +qa` installs/updates plugins and regenerates `lazy-lock.json`.

## Possible future cleanup

`init.vim` keeps a couple of Vim-era lines from the original config (`set nocompatible`, `set encoding=utf-8`) that are no-ops under Neovim, and a full conversion to `init.lua` would be more idiomatic. Both are intentionally out of scope to stay faithful to the canonical config — only change them if the user asks.
