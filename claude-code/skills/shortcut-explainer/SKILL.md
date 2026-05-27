---
name: shortcut-explainer
description: Find and explain keyboard shortcuts / keybinds in this dotfiles repo's app configs. Use this skill whenever the user asks about a shortcut — "what's the keybind for X", "how do I X in nvim", "is there a shortcut for X", "what does <leader>z do", "can I do X in <app>", "which key Y is bound to" — even when they don't say "shortcut" or "keybind" outright. It searches each configured app's source of truth (Neovim keymaps, and the live Claude Code keybindings) and reports the binding, what it does, and where it's defined. It only *finds and explains existing* shortcuts — it does NOT rebind or customize Claude Code's own keys (that's the keybindings-help skill) and it does not author new mappings.
---

# Shortcut Explainer

Answer the user's shortcut questions by **searching this dotfiles repo's configs**, then
report the binding, what it does, and the file it lives in.

The reason this is a skill and not a memorized list: this repo's whole philosophy is that
the `desc` on each mapping is the **single source of truth** — there is deliberately no
hand-maintained cheatsheet (see CLAUDE.md, "Discovering keybindings"). A static list baked
into this skill would rot the moment a mapping changes. **So always read the source files
fresh on every question.** Never answer from memory or from a cached list.

## Find the dotfiles repo

This skill is symlinked from the repo into `~/.claude/skills/shortcut-explainer`, so
resolving its real path gives you the repo root:

```bash
repo=$(cd "$(dirname "$(readlink -f ~/.claude/skills/shortcut-explainer/SKILL.md)")/../../.." && pwd)
```

If that doesn't resolve, fall back to the directory containing both `neovim/` and
`claude-code/` (search up from the current dir, or ask the user where their dotfiles live).

## Generic discovery procedure (app-agnostic)

The repo configures several apps and **more will be added over time**, each with its own
config and possibly its own keybindings. Don't hardwire to today's apps — discover them:

1. **Find the apps.** They're the top-level folders that carry a `sync` script — the same
   set the `Makefile` auto-discovers via its `*/sync` glob:
   ```bash
   ls -d "$repo"/*/sync 2>/dev/null   # each match's parent dir is an app
   ```
2. **Locate that app's binding source.** Look inside the app's folder for where shortcuts
   are declared and grep for binding-like patterns. Don't assume a format — infer it from
   the files present (Lua `keymap`/`keys`, JSON/YAML `key`/`bind`/`shortcut`, an rc/conf
   `map`/`bind` line, etc.):
   ```bash
   rg -i -n 'keymap|keybind|\bbind\b|\bmap\b|shortcut|\bkeys\b' "$repo/<app>"
   ```
3. **Search and report** for the user's specific question — see "Answer playbook" below.

The "Known sources" section accelerates the common cases, but it is **not** the whole
universe: if the user asks about an app not listed there, run the procedure above. Only add
a note to "Known sources" later if an app's binding location turns out to be non-obvious.

## Known sources today

A worked-example shortcut for the apps that exist right now — extend by discovery, above.

### Neovim (`neovim/`)
- **Base maps:** `neovim/lua/config/keymaps.lua` — each line maps via a local
  `map(...)` alias for `vim.keymap.set(mode, lhs, rhs, { desc = "…" })`. The `desc` is the
  answer text (don't grep for the function name; grep the `desc` text or the `lhs`).
- **Plugin maps:** `neovim/lua/plugins/*.lua` — declared in each lazy.nvim spec's
  `keys = { { "<lhs>", …, desc = "…" } }` field.
- **Prefix groups:** `neovim/lua/plugins/which-key.lua` `opts.spec` — names a leader
  prefix (e.g. `{ "<leader>s", group = "search" }`), useful for "what's under `<leader>s`?"
- **Leader is `\`** (`vim.g.mapleader = "\\"`), so `<leader>z` is typed `\z`.

### Claude Code
Claude Code's keybinds are **not** tracked in this repo. Read the live user config:
```bash
cat ~/.claude/keybindings.json 2>/dev/null
```
Report any remap found there. If the action isn't remapped, it uses the Claude Code
default. *Customizing* CC keys is the **keybindings-help** skill's job — not this one;
hand off for "rebind / change / remap" requests.

## Answer playbook

- **"What's the keybind for `<action>`?"** — grep the action's keywords against the `desc`
  strings / binding labels across the located sources, e.g.
  `rg -i -n '<keyword>' "$repo/neovim/lua"`. Report every match.
- **"What does `<key>` do?"** — grep the literal `lhs`, e.g.
  `rg -n -- '<leader>z' "$repo/neovim/lua"` or `rg -n -- 'jk' "$repo/neovim/lua"`.
- **"Is `<X>` possible / is there a shortcut for X?"** — search; if nothing is mapped, say
  so plainly and offer the fallbacks below. **Never fabricate a binding.**
- **Claude Code shortcut** — read `~/.claude/keybindings.json`; if the action isn't there,
  state it's the Claude Code default.

## Answer format

Report each match as `` `key` `` — what it does *(mode, `file:path`)*. Use a compact table
when several match. Always cite the source file so the user can verify or edit it.

Example:
> `` `<leader>z` `` — toggle fold under cursor *(normal, `neovim/lua/config/keymaps.lua`)*

## Coverage honesty + live fallbacks

The repo source only contains bindings that are **declared there**. An app's built-in or
plugin-internal default maps that aren't written into the config won't appear — so when the
config can't answer, don't guess. Point the user at that app's own live discovery:

- **Neovim:** `<leader>sk` (`:Telescope keymaps`) fuzzy-searches every *live* mapping;
  press `\` and pause for the which-key popup; `<leader>sh` (`:Telescope help_tags`) and
  `:help` cover built-in behavior. These read Neovim's live keymap table, so they see
  plugin defaults the repo source doesn't.
- **Claude Code:** the **keybindings-help** skill and the live `~/.claude/keybindings.json`.

## When NOT to use this skill

- **Rebinding / customizing Claude Code keys** ("rebind ctrl+s", "change the submit key")
  → that's **keybindings-help**.
- **Authoring a new Neovim mapping** → that's an edit to `neovim/lua/config/keymaps.lua`
  (with a `desc`). You can explain how, but this skill's job is *finding and explaining*
  existing shortcuts, not creating them.

**Cardinal rule:** read the source files fresh every time. Do not maintain a static list of
bindings inside this skill — the `desc` in the config is the single source of truth.
