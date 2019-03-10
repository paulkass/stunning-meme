augroup initialRubyCompilerGroup
    autocmd!
    autocmd FileType ruby compiler ruby 
augroup END

let mapleader = "\\"

" Common Abbreviations

iabbrev edn end

" This is to have the vim-ruby plugin work

set nocompatible
filetype on
filetype indent on
filetype plugin on

inoremap jk <Esc>
" inoremap pjj :pu<CR> "
set tabstop=4
set shiftwidth=4
set expandtab
set number relativenumber
set nu
colorscheme delek
syntax on

" Opening vimrc commands
nnoremap <leader>ev :vsplit $MYVIMRC<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>

" Vim Split Screen Commands
set splitbelow
set splitright

" Vim Spelling Enabled for Text files

augroup spellingEnabled
    autocmd!
    autocmd BufReadPre,BufNewFile *.txt :setlocal spell spelllang=en_us
augroup END

" Some comment commands
"
" Comment commands mapping to <localleader>c

augroup commentMaps
    autocmd!
    autocmd FileType python,ruby nnoremap <buffer> <localleader>c I#<esc>
    autocmd FileType vim nnoremap <buffer> <localleader>c I"<esc>
augroup END

" Delete till quote commands

nnoremap <localleader>' dt' 
nnoremap <localleader>" dt"

" Some autocommand conveniences
" Python
augroup pythonAbbrevs
    autocmd!
    autocmd FileType python     :iabbrev <buffer> iff if:<left>
    autocmd FileType python     :iabbrev <buffer> ret return
augroup END

" Ruby
augroup rubyAbbrevs
    autocmd!
    autocmd FileType ruby       :iabbrev <buffer> doend do<CR><CR>end<up><space>
augroup END

" Markdown
augroup markdownAbbrevs
    autocmd!
    autocmd FileType markdown   :onoremap ih :<c-u>execute "normal! ?^\\(=\\{2,\\}\\\|-\\{2,\\}\\)$\r:nohlsearch\rkvg_"<cr>
augroup END


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

" Syntastic Commands
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0


" Ruby Variables
let g:rubycomplete_buffer_loading = 1
let g:rubycomplete_classes_in_global = 1
let g:rubycomplete_use_bundler = 1


" inoremap <expr> <Tab> stridx('])}', getline('.')[col('.')-1])==-1 ? "\t" : "\<Right>"

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

