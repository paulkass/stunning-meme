-- LSP: native Neovim language-server integration. Python is handled by
-- BasedPyright for navigation, references, rename, hover, and symbol search.
--
-- This uses the current Neovim 0.11+ LSP API. The repo setup installs upstream
-- stable Neovim so Debian/Ubuntu's older apt package does not constrain the
-- config. On older Neovim, skip these plugins rather than breaking startup.
local has_modern_lsp = function()
  return vim.fn.has("nvim-0.11") == 1
end

return {
  {
    "mason-org/mason-lspconfig.nvim",
    cond = has_modern_lsp,
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      ensure_installed = { "basedpyright" },
      automatic_enable = { "basedpyright" },
    },
    config = function(_, opts)
      require("mason").setup()
      require("mason-lspconfig").setup(opts)
    end,
  },
}
