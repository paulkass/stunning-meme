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

" Pathogen {{{
execute pathogen#infect() 
" }}}
let mapleader = "\\"

" Common Abbreviations {{{
iabbrev edn end
iabbrev thigns things
iabbrev shoulnd should
iabbrev imporve improve
"}}}

" Basic Setup {{{
inoremap jk <Esc>
set tabstop=4
set shiftwidth=4
set expandtab
set number relativenumber
set nu
set backspace=indent,eol,start
syntax on
set equalalways
" }}}

" Search Options {{{
set incsearch
set hlsearch
"}}}

" Personal Mapping Conveniences {{{
"
" Vim Opening Commands {{{
nnoremap <leader>ev :vsplit $MYVIMRC<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>

" Opens last Buffer in new window
nnoremap <leader>dv :execute "vsplit ".bufname("#")<CR>
"}}}

" Folding opening commands
nnoremap <leader>z za
nnoremap <leader>Z zA

" Trailing Whitespace Highlight {{{
highlight trailingWhitespaceGroup ctermbg=DarkMagenta guibg=DarkMagenta
nnoremap <leader>w :match trailingWhitespaceGroup /\s\+$/<cr>
nnoremap <leader>W :match none<cr>
" }}}

" Mapping to do search with very magic regex
nnoremap <leader>F /\v

" Mapping to clear highlights from last search
nnoremap <leader>c :nohlsearch

" Mapping to follow abbreviation without including a space afterwards
inoremap <buffer> <leader><space> <C-]>

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
    autocmd FileType java nnoremap <buffer> <localleader>c I//<esc>
augroup END
" }}}

" Some autocommand conveniences {{{
" Python {{{
augroup pythonAbbrevs
    autocmd!
    autocmd FileType python     :iabbrev <buffer> iff if:<left>
    autocmd FileType python     :iabbrev <buffer> elff elif:<left>
    autocmd FileType python     :iabbrev <buffer> ret return
    autocmd FileType python     :iabbrev <buffer> pr print()<left>
    autocmd FileType python     :iabbrev <buffer> deff def():<left><left><left>
    autocmd FileType python     :iabbrev <buffer> forr for:<left>
    autocmd FileType python     :iabbrev <buffer> imp import
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

" Javascript {{{
augroup javascriptAbbrevs
    autocmd!
    autocmd FileType javascript :nnoremap <localleader>f :<c-u>execute "normal! mqA;\e`q"<cr>
augroup END
" }}}

" Java {{{
augroup javaAbbrevs
    autocmd!

    autocmd FileType java :nnoremap <localleader>f :<c-u>execute "normal! mqA;\e`q"<cr>
augroup END
" }}}

" Vim {{{
augroup vimAbbrevs
    autocmd!
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
    autocmd FileType python setlocal foldlevelstart=1
    "}}}
augroup END
"}}}

" Statusline Commands {{{
set statusline=%f " name of file
set statusline+=,\ Line:\ %l " line number
set statusline+=/%-7L " Total lines
set statusline+=%< " Cutoff mark
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
set statusline+=%=
set statusline+=%y
"}}}

" Grep Search commands {{{
"nnoremap <leader>g :silent execute \"grep! -R \" . shellescape(expand("<cWORD>")) . \" .\"<cr>:copen 5<cr> 
nnoremap <silent> <leader>cn :cnext<CR>
nnoremap <silent> <leader>cp :cprevious<CR>
" }}}

"{{{
nnoremap gm :LivedownToggle<cr>
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

Plug 'tmhedberg/SimpylFold'

Plug 'shime/vim-livedown'

Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'

Plug 'simnalamburt/vim-mundo'

Plug 'junegunn/vader.vim'

Plug 'justinmk/vim-gtfo'

Plug 'tpope/vim-fugitive'

Plug 'tmsvg/pear-tree'

" Various Colorschemes {{{

" neuromancer
Plug 'Zabanaa/neuromancer.vim'

" camouflage
Plug 'srushti/my.vim'

" dank-neon
Plug 'DankNeon/vim'

" cosmic_latte
Plug 'nightsense/cosmic_latte'

" allomancer
Plug 'Nequo/vim-allomancer'

" fantasy
Plug 'szorfein/fantasy.vim'

" abstract
Plug 'jdsimcoe/abstract.vim'

" }}}

call plug#end()
"}}}

" Color Scheme setup {{{
set termguicolors
" Preferred color scheme without add-ons is 'delek'
colorscheme abstract 

" For abstract, fix Visual Selection
hi Visual ctermfg=NONE ctermbg=251 cterm=NONE guifg=NONE guibg=#4E2F31 gui=NONE
" }}}

" Mundo Specifications {{{
set undofile
set undodir=~/.vim/undo
nnoremap <leader>mun :MundoToggle<CR>
"}}}

" Pear Tree Configuration {{{
let g:pear_tree_smart_openers = 1
let g:pear_tree_smart_closers = 1
let g:pear_tree_smart_backspace = 1
" }}}  


