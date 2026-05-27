-- Neovim entry point. Modular Lua config; see lua/ for the pieces.
--
-- Layout:
--   lua/config/options.lua   editor settings (the old `set` lines)
--   lua/config/keymaps.lua   every mapping, each carrying a `desc`
--   lua/plugins/*.lua        one file per plugin, auto-imported by lazy below
--
-- The `desc` on each mapping is the single source of truth for the which-key
-- popup and the `:Telescope keymaps` fuzzy finder — there is no separate
-- cheatsheet to maintain.

-- Leader must be set before lazy.nvim loads.
vim.g.mapleader = "\\"
vim.g.maplocalleader = "\\"

require("config.options")
require("config.keymaps")

-- Bootstrap lazy.nvim (clones it on first launch).
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- `import = "plugins"` loads every spec file under lua/plugins/. Adding a
-- plugin is just dropping a new file there.
require("lazy").setup({ import = "plugins" })
