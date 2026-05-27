-- Colorscheme: load eagerly with high priority so it's ready before other
-- startup. termguicolors is set in lua/config/options.lua, which runs first.
return {
  "rhysd/vim-color-spring-night",
  lazy = false,
  priority = 1000,
  config = function()
    vim.cmd.colorscheme("spring-night")
  end,
}
