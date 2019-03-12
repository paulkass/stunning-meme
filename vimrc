" This is to have the vim-ruby plugin work {{{
augroup initialRubyCompilerGroup
    autocmd!
    autocmd FileType ruby compiler ruby 
augroup END

set nocompatible
filetype on
filetype indent on
filetype plugin on

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 0
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" Ruby Variables
let g:rubycomplete_buffer_loading = 1
let g:rubycomplete_classes_in_global = 1
let g:rubycomplete_use_bundler = 1
"}}}

let mapleader = "\\"

" Common Abbreviations {{{
iabbrev edn end
iabbrev thigns things
iabbrev shoulnd should
"}}}

" Basic Setup {{{
inoremap jk <Esc>
set tabstop=4
set shiftwidth=4
set expandtab
set number relativenumber
set nu
colorscheme delek
syntax on
"}}}

" Personal Mapping Conveniences {{{
"
" Vim Opening Commands {{{
nnoremap <leader>ev :vsplit $MYVIMRC<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>
"}}}

" Folding opening commands
nnoremap <leader>z za
nnoremap <leader>Z zA

"}}}

" Vim Split Screen Commands {{{
set splitbelow
set splitright
" }}}

" Vim Spelling Enabled for Text files {{{
augroup spellingEnabled
    autocmd!
    autocmd BufReadPre,BufNewFile *.txt :setlocal spell spelllang=en_us
    autocmd FileType help :setlocal nospell
augroup END
" }}}

" Some comment commands {{{
"
" Comment commands mapping to <localleader>c 
augroup commentMaps
    autocmd!
    autocmd FileType python,ruby nnoremap <buffer> <localleader>c I#<esc>
    autocmd FileType vim nnoremap <buffer> <localleader>c I"<esc>
augroup END
" }}}

" Delete till quote commands {{{
nnoremap <localleader>' dt' 
nnoremap <localleader>" dt"
"}}}

" Some autocommand conveniences {{{
" Python {{{
augroup pythonAbbrevs
    autocmd!
    autocmd FileType python     :iabbrev <buffer> iff if:<left>
    autocmd FileType python     :iabbrev <buffer> ret return
augroup END
" }}}

" Ruby {{{
augroup rubyAbbrevs
    autocmd!
    autocmd FileType ruby       :iabbrev <buffer> doend do<CR><CR>end<up><space>
augroup END
" }}}

" Markdown {{{
augroup markdownAbbrevs
    autocmd!
    autocmd FileType markdown   :onoremap ih :<c-u>execute "normal! ?^\\(=\\{2,\\}\\\|-\\{2,\\}\\)$\r:nohlsearch\rkvg_"<cr>
augroup END
" }}}
" autocommand convenience end }}}

" Operator Mappings {{{
" Some Mappings for selecting first and last parentheses
onoremap <silent> IP :<c-u>normal! f(vi(<CR>
onoremap <silent> OP :<c-u>normal! f(va(<CR>
onoremap <silent> LP :<c-u>normal! F)va(<CR>

" Mappings for curly braces
onoremap <silent> IB :<c-u>normal! f}vi{<CR>
onoremap <silent> OB :<c-u>normal! f}va{<CR>
onoremap <silent> LB :<c-u>normal! F{va}<CR>

" Operator Mapping for inside next email
onoremap <silent> in@ :<c-u>execute "normal! /\\s\\S\\+@\\S\\+\\.\\S\\{2,3\\}\r:nohlsearch\rvawol"<cr>
"}}}

" Code Folding ---- {{{
augroup code_folding
    autocmd!
    autocmd FileType vim setlocal foldmethod=marker
    autocmd FileType vim setlocal foldlevelstart=1
    
    "Ruby {{{
    autocmd FileType ruby setlocal foldmethod=syntax
    autocmd FileType ruby setlocal foldlevelstart=3
    "}}}
    
    "Python {{{
    autocmd FileType python setlocal foldmethod=indent
    autocmd FileType python setlocal foldlevelstart=0
    "}}}
augroup END
"}}}

" Statusline Commands {{{
set statusline=%t " name of file
set statusline+=,\ Line:\ %l " line number
set statusline+=/%-7L " Total lines
set statusline+=%< " Cutoff mark
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
set statusline+=%=
set statusline+=%y
"}}}

" Plugin Specification for vimplug --- {{{
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
                \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

let vim_markdown_preview_github=1

call plug#begin("~/.vim/plugged")

Plug 'tpope/vim-surround'

Plug 'JamshedVesuna/vim-markdown-preview'

Plug 'vim-ruby/vim-ruby'

Plug 'vim-syntastic/syntastic'

call plug#end()
"}}}
