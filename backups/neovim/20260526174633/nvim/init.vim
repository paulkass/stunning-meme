
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

nnoremap <leader>z za
nnoremap <leader>Z zA

noremap <leader>F /\v

nnoremap <silent> <leader>C :nohlsearch<cr>

nnoremap <silent> <leader>nv :vsp ~/.config/nvim/init.vim<cr>
nnoremap <silent> <leader>rl :source ~/.config/nvim/init.vim<cr>

tnoremap <silent> <Esc> <C-\><C-n>

set splitbelow
set splitright

execute pathogen#infect()

set termguicolors
colorscheme spring-night
"colorscheme colors-wal

