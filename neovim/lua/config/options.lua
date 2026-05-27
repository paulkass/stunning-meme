-- Editor settings (the old Vimscript `set` lines).
-- termguicolors is set here, before lazy loads the colorscheme.
local opt = vim.opt

opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true

opt.number = true
opt.relativenumber = true

opt.equalalways = true

-- Disable modelines: they let arbitrary files set editor options (a security
-- risk) and cause spurious E518 errors on files whose contents merely look
-- like a modeline (e.g. JSON/prose containing "ex:" or "vim:").
opt.modeline = false

opt.splitbelow = true
opt.splitright = true

opt.termguicolors = true
