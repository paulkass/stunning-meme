-- which-key: press <leader> (\) and pause to see every binding under it, read
-- automatically from each mapping's `desc`. The `spec` below only names the
-- prefix groups so the popup stays organized as the config grows — add a line
-- per new prefix, e.g. { "<leader>g", group = "git" }.
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    spec = {
      { "<leader>s", group = "search" },
    },
  },
  keys = {
    {
      "<leader>?",
      function() require("which-key").show({ global = false }) end,
      desc = "Show buffer-local keymaps",
    },
  },
}
