# stunning-meme

Personal Neovim configuration.

Plain Vimscript `init.vim` with plugins managed by
[lazy.nvim](https://github.com/folke/lazy.nvim). lazy.nvim bootstraps itself
and installs plugins into `~/.local/share/nvim/lazy/`, so no plugin code is
vendored here.

## Layout

- `init.vim` — settings, mappings, and the lazy.nvim plugin spec.
- `lazy-lock.json` — pinned plugin versions.
- `nvimlink` — install script.

## Install

Symlink this repo into `~/.config/nvim`:

```sh
./nvimlink
```

An existing real `~/.config/nvim` is backed up first. Then launch `nvim` —
lazy.nvim bootstraps and installs the plugins on first start.

On a fresh machine you can instead clone this repo straight into place:

```sh
git clone <url> ~/.config/nvim
```

## Adding a plugin

Add a spec entry to the `require("lazy").setup({ ... })` table in `init.vim`,
then run `:Lazy sync` and commit the updated `lazy-lock.json`.
