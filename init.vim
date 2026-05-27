
set nocompatible
set encoding=utf-8
set tabstop=4
set shiftwidth=4
filetype on
filetype indent on
filetype plugin on

let mapleader="\\"

inoremap jk <Esc>
set tabstop=4
set expandtab
set number relativenumber
set nu
syntax on
set equalalways
set backspace=indent,eol,start

" Disable modelines: they let arbitrary files set editor options (a security
" risk) and cause spurious E518 errors on files whose contents merely look
" like a modeline (e.g. JSON/prose containing "ex:" or "vim:").
set nomodeline

nnoremap <leader>z za
nnoremap <leader>Z zA

noremap <leader>F /\v

nnoremap <silent> <leader>C :nohlsearch<cr>

nnoremap <silent> <leader>nv :vsp ~/.config/nvim/init.vim<cr>
nnoremap <silent> <leader>rl :source ~/.config/nvim/init.vim<cr>

tnoremap <silent> <Esc> <C-\><C-n>

set splitbelow
set splitright

set termguicolors

" Plugins are managed by lazy.nvim. To add a plugin, add a spec entry to the
" require("lazy").setup({ ... }) table below, then run :Lazy sync and commit
" the updated lazy-lock.json.
lua << EOF
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- colorscheme: load eagerly with high priority so it's ready immediately
  { "rhysd/vim-color-spring-night", lazy = false, priority = 1000 },
})

vim.cmd.colorscheme("spring-night")
EOF
