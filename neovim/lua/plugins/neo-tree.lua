-- Neo-tree: sidebar file explorer. <leader>e toggles, <leader>E reveals the
-- current buffer's file in the tree. Lazy-loaded on those keys and on the
-- `Neotree` command, so startup stays fast.
--
-- Keybinds are declared in the spec's `keys = {}` so lazy.nvim registers them
-- as load-trigger stubs at startup — they appear in which-key and
-- `:Telescope keymaps` before neo-tree itself has loaded.
return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  cmd = "Neotree",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  keys = {
    { "<leader>e",  "<cmd>Neotree toggle<cr>",                       desc = "Toggle file explorer" },
    { "<leader>E",  "<cmd>Neotree reveal<cr>",                       desc = "Reveal current file in explorer" },
    { "<leader>eb", "<cmd>Neotree toggle source=buffers<cr>",        desc = "Toggle buffer list (explorer)" },
    { "<leader>eg", "<cmd>Neotree toggle source=git_status<cr>",     desc = "Toggle git status (explorer)" },
  },
  opts = {
    close_if_last_window = true,
    filesystem = {
      follow_current_file = { enabled = true },
      use_libuv_file_watcher = true,
      window = {
        mappings = {
          ["F"] = "clear_filter",
        },
      },
      filtered_items = {
        hide_dotfiles = false,
        hide_gitignored = true,
      },
    },
    window = {
      position = "left",
      width = 32,
    },
  },
}
