-- nvim-web-devicons: filetype glyphs used by neo-tree (sidebar) and telescope
-- (file/buffer pickers). Defaults are good once a Nerd Font is present;
-- kitty/kitty.conf pins `font_family Hack Nerd Font` so the glyphs render.
--
-- Loaded lazily — neo-tree and telescope declare it as a dependency, so it
-- only loads when one of those activates.
return {
  "nvim-tree/nvim-web-devicons",
  lazy = true,
  opts = {},
}
