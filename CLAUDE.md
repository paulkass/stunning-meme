# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A personal **dotfiles** repo. Each application's config lives in its own top-level folder; the apps so far are **Neovim** (under `neovim/`), **Claude Code** (under `claude-code/`), and **Kitty** (under `kitty/`). The "product" is the configs themselves, consumed by each app at startup — there is no build, test, or lint step. The canonical source of truth is this repo; configs get symlinked into place (Neovim → `~/.config/nvim`, Claude Code → `~/.claude`, Kitty → `~/.config/kitty`).

Each app folder carries a self-contained `sync` script (`./sync` installs the symlinks, `./sync verify` checks them). Installing only runs from the canonical **master** branch — `./sync` refuses on any other branch (e.g. a git worktree) so the live config never gets linked to a checkout that will disappear; `./sync verify` is read-only and works anywhere, and `FORCE=1 ./sync` overrides the guard deliberately. The top-level `Makefile` is the main interface and **auto-discovers** apps by globbing `*/sync`, so adding an app needs no `Makefile` edits.

## Files

- `Makefile` — top-level interface. Auto-discovers each app's `sync` script and exposes `make` (sync all), `make verify` (verify all), `make <app>` (sync one), `make <app>.verify` (verify one). Also carries a standalone `make hooks` target that activates the repo's git hooks (see "Git hooks"); it is **not** a prerequisite of `make`.
- `neovim/init.lua` — the Neovim entry point: sets the leader, requires the config modules, bootstraps lazy.nvim, and auto-imports plugin specs (`import = "plugins"`).
- `neovim/lua/config/options.lua` — editor settings (the `vim.opt.*` lines). `termguicolors` is set here, before the colorscheme loads.
- `neovim/lua/config/keymaps.lua` — every mapping, each defined with `vim.keymap.set` and a `desc`. The `desc` is the single source of truth for discovery — see "Discovering keybindings" below. Do not hand-maintain a separate cheatsheet.
- `neovim/lua/plugins/*.lua` — one file per plugin, each returning a lazy.nvim spec. `import = "plugins"` in `init.lua` loads them all. Current files: `colorscheme.lua` (spring-night), `which-key.lua`, `telescope.lua`.
- `neovim/lazy-lock.json` — lazy.nvim's pinned plugin versions. Commit it whenever it changes.
- `lib/backup.sh` — shared helper sourced by every app's `sync`. Its `repo_backup SRC APP PATH...` moves each displaced path into `backups/<app>/<timestamp>/` (basename kept) and commits just that backup, so backups are version-controlled in one place instead of piling up untracked next to the live config. A failed commit is non-fatal (files are saved either way). `lib/` has no `sync`, so the `Makefile` glob ignores it.
- `backups/` — committed archives of pre-existing config that a `sync` displaced on first install, one `backups/<app>/<timestamp>/` subdir per run (see `backups/README.md`). Written by `lib/backup.sh`; safe to prune once an old config is no longer needed.
- `.githooks/` — tracked, hidden dir holding this repo's git hooks (`pre-merge-commit`, `post-merge`). **Not an app** — it has no `sync`, so the `Makefile`'s `*/sync` glob ignores it (like `lib/`). Activated by `make hooks`, which sets a repo-local `core.hooksPath`. See "Git hooks" for what each hook does.
- `neovim/sync` — install script (relocated from the old root `nvimlink`); symlinks `init.lua`, the `lua/` directory, and `lazy-lock.json` into `~/.config/nvim`. A pre-existing real config is backed up wholesale into `backups/neovim/<timestamp>/` and committed (via `repo_backup`) before linking. `./neovim/sync verify` asserts those paths are still symlinks into this repo (exits non-zero otherwise). To add a synced item, append it to the `ITEMS` list.
- `claude-code/settings.json` — Claude Code global preferences (model, permission allowlist, env, the Notification hook, `extraKnownMarketplaces`, `enabledPlugins`). The Notification hook just runs `$HOME/.claude/hooks/notify.sh` (see below); it carries no inline logic. No secrets — credentials live separately in `~/.claude/.credentials.json`, which is never tracked here.
  - **Plugins are tracked here, not as vendored code.** Two keys make the plugin setup portable: `extraKnownMarketplaces` declares *where* plugins come from (the `anthropics/claude-plugins-official` GitHub marketplace) and `enabledPlugins` declares *which* are on. On a fresh machine Claude Code reads these and offers to install the marketplace + plugins. The `~/.claude/plugins/` files (`known_marketplaces.json`, `installed_plugins.json`, `cache/`, `marketplaces/`, `plugin-catalog-cache.json`) are deliberately **not** tracked — they're machine-specific local state (absolute paths, timestamps, commit SHAs, cloned source) that Claude Code regenerates.
- `claude-code/hooks/notify.sh` — cross-platform desktop-notification script invoked by the `Notification` hook. Reads the hook JSON on stdin and dispatches to the first available notifier (`terminal-notifier` or `osascript` on macOS, `notify-send` on Linux); on a machine with none (headless/SSH, no libnotify) it exits 0 silently. `jq` and the transcript snippet are optional — it degrades instead of failing. The whole `hooks/` dir is symlinked into `~/.claude/hooks`.
- `claude-code/skills/` — user-authored skills, one folder per skill with a `SKILL.md` (currently `commit` and `shortcut-explainer`, the latter answering keybind/shortcut questions by searching each app's config). The whole dir is symlinked, so any skill created later (e.g. via skill-creator) is version-controlled automatically.
- `claude-code/sync` — symlinks `settings.json`, `skills`, and `hooks` into `~/.claude`. **Unlike `neovim/sync`, it links and backs up _per item_, never the whole `~/.claude` dir** — that directory is a mix of tracked config and untracked credentials/session state, so it must not be moved or backed up wholesale. Pre-existing real items are backed up together into `backups/claude-code/<timestamp>/` and committed (via `repo_backup`) before linking; `~/.claude/.credentials.json` is not a tracked item, so it is never moved or committed.
- `kitty/kitty.conf` — the Kitty terminal config, **ported from a KDE Konsole setup** (Konsole's `Profile 1.profile`). It sets the font (Hack 11pt), `tab_bar_edge bottom` (Konsole's bottom tab bar), `background_opacity 0.7` with `background_blur 0` (to match Konsole's translucent window), and the full 16-color ANSI palette plus foreground/background. **The palette is Konsole's Breeze color scheme**, ported verbatim from `~/.local/share/konsole/Breeze.colorscheme` (`color0-7` = Breeze's normal colors, `color8-15` = its `Intense` variants, which Konsole renders for *bold* text). `Profile 1` names no `ColorScheme`, but Konsole's fallback default **is** Breeze — confirmed with an on-screen color picker that caught the exact values Konsole paints (e.g. bold blue `#3daee9` = Breeze `Color4Intense`). A long detour earlier captured the palette via OSC `?` queries instead and got a *different* (built-in `0xB21818`-style) table that Konsole does **not** actually render; that was the wrong layer. The color picker and the scheme file are the ground truth — to re-verify, screen-pick Konsole's output rather than trusting an OSC query (Konsole's OSC-query responses don't match what it paints). Window sizing is left at Kitty's default (`remember_window_size yes`), mirroring Konsole remembering per-screen geometry rather than the profile's fixed row count. Konsole's `default.keytab` was not ported — it is the stock XFree4 binding table that Kitty's defaults already match.
- `kitty/sync` — install script following the **`neovim/sync` whole-directory pattern** (`~/.config/kitty` is dedicated to Kitty, like `~/.config/nvim` is to Neovim), not the claude-code per-item pattern. Symlinks `kitty.conf` into `~/.config/kitty`; a pre-existing real config is backed up wholesale into `backups/kitty/<timestamp>/` and committed (via `repo_backup`) before linking. `./kitty/sync verify` asserts the link is intact. To add a synced item, append it to the `ITEMS` list.

To **add a new app**: create a folder, drop its config files in, and add an executable `sync` script supporting `./sync` and `./sync verify` (use `neovim/sync` as a template). For backups, source `lib/backup.sh` and call `repo_backup "$SRC" <app> <paths>` — don't reinvent the per-app backup logic. The `Makefile` picks the app up automatically.

## Git hooks

Two repo-local git hooks live in the tracked, hidden `.githooks/` dir. Activate
them once per clone with `make hooks`, which sets a repo-local
`core.hooksPath = .githooks` — a **relative** value, so it resolves to each
working tree's own `.githooks/` and one setting in the shared `.git/config`
covers every worktree. This is deliberately **not** wired into `make`, so a plain
`make` never touches your git config. Both hooks **no-op off `master`** (via the
same `git symbolic-ref --short -q HEAD` check the `sync` scripts use), so
feature-branch worktrees merge and pull freely.

- `.githooks/pre-merge-commit` — blocks a merge that would create a merge commit
  on `master` while the working tree has uncommitted **unstaged** changes
  (`git diff-files --quiet`), so unrelated edits aren't folded into the merge.
  Two cases are intentionally not gated here because they can't entangle work:
  git itself already refuses a real merge with **staged** changes, and
  fast-forward merges create no commit. Bypass with `git merge --no-verify`.
- `.githooks/post-merge` — after `master` is updated by a merge/pull, runs `make`
  to re-sync every app (displaced config is archived and committed by
  `repo_backup`, so backups stay tracked). **Skips** when the merge changed only
  `backups/` (or nothing) — e.g. pulling another machine's backup commits. Uses
  `post-merge` only, so any backup commit `make` creates is a plain commit that
  never re-triggers the hook (no loop).

To change or add a hook, edit/add a file in `.githooks/` named after the git hook
event and `chmod +x` it (`core.hooksPath` only runs executable hooks, and the bit
must be committed). `make hooks` need not be re-run.

## Plugin management (lazy.nvim)

Plugins are managed by [lazy.nvim](https://github.com/folke/lazy.nvim), **not** pathogen or vim-plug (both were removed). `init.lua` bootstraps lazy.nvim (clones it to `~/.local/share/nvim/lazy/` on first launch) and calls `require("lazy").setup({ import = "plugins" })`, which loads every spec file under `neovim/lua/plugins/`. No plugin code is vendored in this repo — lazy fetches everything at runtime.

**To add a plugin**: create `neovim/lua/plugins/<name>.lua` returning a lazy spec table, then run `:Lazy sync`, and commit the updated `neovim/lazy-lock.json`. No edit to `init.lua` is needed — `import = "plugins"` picks the file up. Do not reintroduce pathogen/vim-plug or a `bundle/` directory.

**Prefer declaring a plugin's keymaps in its spec's `keys = {}` field with a `desc`** (rather than letting the plugin map them internally on load). lazy registers those as load-trigger stubs at startup, so they appear in which-key and `:Telescope keymaps` even before the plugin loads. See "Discovering keybindings".

The colorscheme spec (`plugins/colorscheme.lua`) is declared with `lazy = false, priority = 1000` so it loads eagerly before other startup; its `config` calls `vim.cmd.colorscheme(...)`. Keep `opt.termguicolors` (in `lua/config/options.lua`, which runs before lazy) ahead of that.

## Conventions

- **Leader** is `\` (`vim.g.mapleader = "\\"`), set at the top of `init.lua` before lazy loads — lazy.nvim requires the leader to be set before it loads.
- Every mapping in `lua/config/keymaps.lua` is defined with `vim.keymap.set(mode, lhs, rhs, { desc = "..." })`. Always include a `desc` — it is what populates the discovery tooling.
- `jk` (insert) is the escape convention; `<Esc>` (terminal) exits terminal mode.
- `<leader>nv` opens the config (`$MYVIMRC`, i.e. `init.lua`). `<leader>rl` re-sources it, but note lazy.nvim does **not** support re-sourcing the config — it prints "Re-sourcing your config is not supported with lazy.nvim". Restart Neovim (or use `:Lazy reload`) to apply changes.

## Discovering keybindings

The `desc` on every mapping is the single source of truth — never hand-maintain a cheatsheet. Two complementary tools read those descriptions:

- **which-key.nvim** (`plugins/which-key.lua`) — press `\` (leader) and pause for a popup of every binding under that prefix, organized into named groups via its `spec` (e.g. `{ "<leader>s", group = "search" }`). Add a `spec` line per new prefix to keep it organized. `<leader>?` shows buffer-local maps.
- **Telescope keymaps** (`plugins/telescope.lua`) — `<leader>sk` (`:Telescope keymaps`) is a fuzzy-searchable index of every registered mapping; `<leader>sh` searches `:help`.

Both enumerate Neovim's live keymap table, so **plugin keybinds appear automatically** with whatever `desc` the plugin set. The one gap is lazy-loaded plugins, whose internal maps don't exist until load — declaring those keys in the spec's `keys = {}` field with a `desc` (see "Plugin management") closes it.

## Install / verify

- Install: `make neovim` (or `make` for every app), then launch `nvim` to trigger first-run plugin install. `make neovim` is equivalent to running `./neovim/sync` directly.
- Verify the link is intact: `make neovim.verify` (or `make verify` for every app) — handy after moving the repo or switching to a branch that lacks these files; re-run `make neovim` to repair.
- Headless smoke test: `nvim --headless +qa` should exit cleanly (the config loads on startup); `nvim --headless "+Lazy! sync" +qa` installs/updates plugins and regenerates `lazy-lock.json` (written through the symlink into `neovim/`).
