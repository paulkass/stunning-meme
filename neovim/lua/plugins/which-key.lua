-- which-key: press <leader> (\) and pause to see every binding under it, read
-- automatically from each mapping's `desc`. The `spec` below only names the
-- prefix groups so the popup stays organized as the config grows — add a line
-- per new prefix, e.g. { "<leader>g", group = "git" }.
--
-- Nerd Font icons are enabled: kitty/kitty.conf pins `font_family Hack Nerd
-- Font`, so which-key's default per-mapping glyphs and special-key icons
-- (Esc, <CR>, modifier prefixes, etc.) render correctly. If this config is
-- ever used on a terminal without a Nerd Font, set `icons.mappings = false`
-- and override `icons.keys` with plain-text labels.
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    -- How long to pause on a prefix before the popup appears. which-key's
    -- default is 200ms; we lengthen it so the popup only shows up once you've
    -- clearly paused and forgotten the next key, not on every quick chord.
    -- Keep the function form so plugin-triggered popups (ctx.plugin, e.g.
    -- <leader>?) still open instantly at 0ms.
    delay = function(ctx)
      return ctx.plugin and 0 or 1000
    end,
    spec = {
      { "<leader>s", group = "search" },
      { "<leader>e", group = "explorer" },
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
