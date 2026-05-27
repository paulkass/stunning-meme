-- which-key: press <leader> (\) and pause to see every binding under it, read
-- automatically from each mapping's `desc`. The `spec` below only names the
-- prefix groups so the popup stays organized as the config grows — add a line
-- per new prefix, e.g. { "<leader>g", group = "git" }.
--
-- Icons are disabled on purpose: which-key v3 prepends Nerd Font glyphs (before
-- each mapping via `icons.mappings`, and for special keys like Esc via
-- `icons.keys`). We don't assume a Nerd Font, so those render as tofu boxes on a
-- plain terminal. `mappings = false` drops the per-mapping icons; the `keys`
-- table is overridden with plain-text labels (omitted entries would keep their
-- glyph default, so override the full set). Leave it this way for portability.
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    icons = {
      mappings = false,
      keys = {
        Up = "<Up> ", Down = "<Down> ", Left = "<Left> ", Right = "<Right> ",
        C = "<C-…> ", M = "<M-…> ", D = "<D-…> ", S = "<S-…> ",
        CR = "<CR> ", Esc = "<Esc> ", ScrollWheelDown = "<ScrollWheelDown> ",
        ScrollWheelUp = "<ScrollWheelUp> ", NL = "<NL> ", BS = "<BS> ",
        Space = "<Space> ", Tab = "<Tab> ",
        F1 = "<F1>", F2 = "<F2>", F3 = "<F3>", F4 = "<F4>", F5 = "<F5>", F6 = "<F6>",
        F7 = "<F7>", F8 = "<F8>", F9 = "<F9>", F10 = "<F10>", F11 = "<F11>", F12 = "<F12>",
      },
    },
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
