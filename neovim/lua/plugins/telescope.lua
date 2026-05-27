-- Telescope: fuzzy finders. `:Telescope keymaps` (<leader>sk) lists every
-- registered mapping with its description — type "fold" or "search" to filter.
-- This is the scalable "I forgot the key" lookup; it reads the live keymap
-- table, so plugin keybinds show up here automatically too.
return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = "Telescope",
  keys = {
    { "<leader>sk", "<cmd>Telescope keymaps<cr>", desc = "Search keymaps" },
    { "<leader>sh", "<cmd>Telescope help_tags<cr>", desc = "Search help" },
  },
  opts = {},
}
