-- Telescope: fuzzy finders. `:Telescope keymaps` (<leader>sk) lists every
-- registered mapping with its description — type "fold" or "search" to filter.
-- This is the scalable "I forgot the key" lookup; it reads the live keymap
-- table, so plugin keybinds show up here automatically too.
--
-- The fzf-native extension compiles a tiny C sorter (build = "make") that
-- makes find_files / live_grep noticeably faster on bigger repos.
-- live_grep itself shells out to ripgrep (`rg`) — install it via the system
-- package manager if it's missing.
return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  cmd = "Telescope",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  keys = {
    { "<leader>sk", "<cmd>Telescope keymaps<cr>",                   desc = "Search keymaps" },
    { "<leader>sh", "<cmd>Telescope help_tags<cr>",                 desc = "Search help" },
    { "<leader>sf", "<cmd>Telescope find_files<cr>",                desc = "Find files" },
    { "<leader>sg", "<cmd>Telescope live_grep<cr>",                 desc = "Live grep (project)" },
    { "<leader>sb", "<cmd>Telescope buffers<cr>",                   desc = "Find buffers" },
    { "<leader>so", "<cmd>Telescope oldfiles<cr>",                  desc = "Recent files" },
    { "<leader>sw", "<cmd>Telescope grep_string<cr>",               desc = "Grep word under cursor" },
    { "<leader>s/", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Fuzzy find in buffer" },
  },
  opts = {
    extensions = { fzf = {} },
  },
  config = function(_, opts)
    require("telescope").setup(opts)
    require("telescope").load_extension("fzf")
  end,
}
