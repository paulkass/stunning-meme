# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A personal **dotfiles** repo. Each application's config lives in its own top-level folder; the apps so far are **Neovim** (under `neovim/`) and **Claude Code** (under `claude-code/`). The "product" is the configs themselves, consumed by each app at startup — there is no build, test, or lint step. The canonical source of truth is this repo; configs get symlinked into place (Neovim → `~/.config/nvim`, Claude Code → `~/.claude`).

Each app folder carries a self-contained `sync` script (`./sync` installs the symlinks, `./sync verify` checks them). Installing only runs from the canonical **master** branch — `./sync` refuses on any other branch (e.g. a git worktree) so the live config never gets linked to a checkout that will disappear; `./sync verify` is read-only and works anywhere, and `FORCE=1 ./sync` overrides the guard deliberately. The top-level `Makefile` is the main interface and **auto-discovers** apps by globbing `*/sync`, so adding an app needs no `Makefile` edits.

## Files

- `Makefile` — top-level interface. Auto-discovers each app's `sync` script and exposes `make` (sync all), `make verify` (verify all), `make <app>` (sync one), `make <app>.verify` (verify one).
- `neovim/init.vim` — the entire Neovim config: settings, mappings, and the plugin spec. Plain Vimscript with one embedded `lua << EOF ... EOF` block for plugin management. `spring-night` is the active colorscheme (a lazy-managed plugin).
- `neovim/lazy-lock.json` — lazy.nvim's pinned plugin versions. Commit it whenever it changes.
- `neovim/sync` — install script (relocated from the old root `nvimlink`); symlinks `init.vim` and `lazy-lock.json` into `~/.config/nvim`, backing up any pre-existing config first. `./neovim/sync verify` asserts those paths are still symlinks into this repo (exits non-zero otherwise).
- `claude-code/settings.json` — Claude Code global preferences (model, permission allowlist, env, the Notification hook, `extraKnownMarketplaces`, `enabledPlugins`). The Notification hook just runs `$HOME/.claude/hooks/notify.sh` (see below); it carries no inline logic. No secrets — credentials live separately in `~/.claude/.credentials.json`, which is never tracked here.
  - **Plugins are tracked here, not as vendored code.** Two keys make the plugin setup portable: `extraKnownMarketplaces` declares *where* plugins come from (the `anthropics/claude-plugins-official` GitHub marketplace) and `enabledPlugins` declares *which* are on. On a fresh machine Claude Code reads these and offers to install the marketplace + plugins. The `~/.claude/plugins/` files (`known_marketplaces.json`, `installed_plugins.json`, `cache/`, `marketplaces/`, `plugin-catalog-cache.json`) are deliberately **not** tracked — they're machine-specific local state (absolute paths, timestamps, commit SHAs, cloned source) that Claude Code regenerates.
- `claude-code/hooks/notify.sh` — cross-platform desktop-notification script invoked by the `Notification` hook. Reads the hook JSON on stdin and dispatches to the first available notifier (`terminal-notifier` or `osascript` on macOS, `notify-send` on Linux); on a machine with none (headless/SSH, no libnotify) it exits 0 silently. `jq` and the transcript snippet are optional — it degrades instead of failing. The whole `hooks/` dir is symlinked into `~/.claude/hooks`.
- `claude-code/skills/` — user-authored skills, one folder per skill with a `SKILL.md` (currently `commit`). The whole dir is symlinked, so any skill created later (e.g. via skill-creator) is version-controlled automatically.
- `claude-code/sync` — symlinks `settings.json`, `skills`, and `hooks` into `~/.claude`. **Unlike `neovim/sync`, it links and backs up _per item_, never the whole `~/.claude` dir** — that directory is a mix of tracked config and untracked credentials/session state, so it must not be moved or backed up wholesale. A pre-existing real item is moved to `<item>.bak.<timestamp>` before linking.

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
