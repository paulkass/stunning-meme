autocmd FileType ruby compiler ruby 

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

" Some autocommand conveniences
" Python
autocmd FileType python     :iabbrev <buffer> iff if:<left>
autocmd FileType python     :iabbrev <buffer> ret return

" Ruby
autocmd FileType ruby       :iabbrev <buffer> doend do<CR><CR>end<up><space>

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

