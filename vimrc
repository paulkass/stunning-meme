" This is to have the vim-ruby plugin work {{{
augroup initialRubyCompilerGroup
    autocmd!
    autocmd FileType ruby compiler ruby 
augroup END

set nocompatible
set encoding=utf-8
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

let g:pymode = 0
let g:pymode_python = 'python3'
let g:pymode_paths = []
let g:pymode_rope = 1
let g:pymode_rope_rename_bind = '<C-c>rr'

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
syntax on
set equalalways
set backspace=indent,eol,start
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
noremap <leader>F /\v

" Mapping to clear highlights from last search
nnoremap <silent> <leader>C :nohlsearch<cr>

" Mapping to follow abbreviation without including a space afterwards
inoremap <buffer> <leader><space> <C-]>

" Mapping that deletes the line bu leaves you in insert mode at the beginning 
nnoremap <leader>D ^c$

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
    autocmd FileType rust nnoremap <buffer> <localleader>c I//<esc>
augroup END
" }}}

" Some autocommand conveniences {{{
" Python {{{
augroup pythonAbbrevs
    autocmd!
    autocmd FileType python     :iabbrev <buffer> iff if:<left>
    autocmd FileType python     :iabbrev <buffer> ret return
    autocmd FileType python     :inoremap <buffer> <localleader>pr print()<left>
    autocmd FileType python     :iabbrev <buffer> pr print()<left>
augroup END


function <SID>CreatePyDocString()
    " Source of template: https://docs.python-guide.org/writing/documentation/ 
    " We are implying this to be called in normal mode
    let line = line(".")
    execute "normal!" "o\"\"\"\<cr>Summary line.\<cr>\<cr>Extended description of function.\<cr>\<cr>Parameters\<cr>----------\<cr>arg : type\<cr>\tDescription of arg\<cr>\<cr>\<BS>Returns\<cr>-------\<cr>type\<cr>\tDescription of return value\<cr>\<cr>\<BS>\"\"\"\<cr>\<esc>"
    execute line+2
endfunction

augroup pydocGen
    autocmd!
    "autocmd FileType python     :inoremap <buffer> <localleader>doc <Esc>:call <SID>CreatePyDocString()<Cr>
    "autocmd FileType python     :nnoremap <buffer> <localleader>doc :call <SID>CreatePyDocString()<Cr>
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

" Rust {{{
function <SID>AddClosingBrace(line) 
   if v:char == '{' && match(getline(a:line), '\v^.*\a+\s+$') != -1
       let v:char = "{\n\n}"
   endif
endfunction

augroup rustAbbrevs
    autocmd!
    autocmd FileType rust :nnoremap <localleader>e :<c-u>execute "normal! $a;"<cr>
    autocmd FileType rust :iabbrev <buffer> pr println!("");<left><left><left>
    autocmd FileType rust :iabbrev <buffer> ll let<space>=<left><left>
    "autocmd InsertCharPre *.rs :call <SID>AddClosingBrace(line("."))
    autocmd FileType rust :iabbrev <localleader>a ->
    autocmd FileType rust :iabbrev <localleader>m =>,<left>
    autocmd FileType rust :set foldmarker={,}
    " Set the marker to {,} so you can switch to marker fold type if needed
    autocmd FileType rust :set foldmethod=syntax
augroup END
" }}}

" Terraform {{{
augroup tfAbbrevs 
    autocmd!
    autocmd FileType terraform :nnoremap <localleader>sp /\vresource\s*\"aws_sqs_queue\"\s*\"
    autocmd FileType terraform :nnoremap <localleader>sl /\vresource\s*\"aws_lambda_function\"\s*\"
    autocmd FileType terraform :nnoremap <localleader>sn /\vresource\s*\"\w*\"\s*\"
    autocmd FileType terraform :nnoremap <localleader>st /\vresource\s*\"
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
nnoremap <silent> <leader>cn :cnext<CR>
nnoremap <silent> <leader>cp :cprevious<CR>

function <SID>VimGrepSearch(query)
    execute 'vimgrep /\v' . a:query . '/g **/*'
    copen
endfunction

command! -nargs=* Vsearch :call <SID>VimGrepSearch(<q-args>) 
" }}}

" Plugin Specification for vimplug --- {{{
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
                \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Some Markdown Commands --- {{{
"let vim_markdown_preview_github=1
let g:livedown_open = 1
let g:livedown_port = 1337
let g:livedown_browser = "firefox"
nnoremap gm :LivedownToggle<cr>
" }}}

call plug#begin("~/.vim/plugged")

Plug 'tpope/vim-surround'

Plug 'vim-syntastic/syntastic'

Plug 'tmhedberg/SimpylFold'

" Plug 'shime/vim-livedown'

" Plug 'godlygeek/tabular'

Plug 'simnalamburt/vim-mundo'

Plug 'junegunn/vader.vim'

Plug 'vim-airline/vim-airline'

Plug 'Valloric/YouCompleteMe'

" Plug 'python-mode/python-mode', { 'for': 'python', 'branch': 'develop' }

Plug 'jlanzarotta/bufexplorer'

Plug 'junegunn/vader.vim'

" Plug 'kkoomen/vim-doge'

Plug 'rust-lang/rust.vim'

Plug 'preservim/nerdtree'

Plug 'hashivim/vim-terraform'

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

" spring-night
Plug 'rhysd/vim-color-spring-night'

" }}}

call plug#end()
"}}}

" Color Scheme setup {{{
set termguicolors
" Preferred color scheme without add-ons is 'delek'
colorscheme spring-night
"
" For abstract, fix Visual Selection
hi Visual ctermfg=NONE ctermbg=251 cterm=NONE guifg=NONE guibg=#4E2F31 gui=NONE
" }}}

" Mundo Specifications {{{
set undofile
set undodir=~/.vim/undo
nnoremap <leader>mun :MundoToggle<CR>
"}}}

" Syntastic Setup {{{

" let g:syntastic_python_pylint_args = "--function-naming-style='PascalCase' --variable-naming-style='any' --method-naming-style='camelCase' --argument-naming-style='camelCase' --attr-naming-style='camelCase'"

" }}}

" Doge Setup {{{
let g:doge_mapping = "<leader>doc"
let g:doge_doc_standard_python = 'numpy'
" }}}

" {{{ YouCompleteMe Setup
let g:ycm_rust_src_path = '~/.rustup/toolchains/stable-x86_64-apple-darwin/lib/rustlib/src/rust/src'
let g:ycm_global_ycm_extra_conf = '~/stunning_meme/ycm_extra_conf.py'

noremap <silent> <localleader>def :YcmCompleter GoToDefinition<cr>
noremap <silent> <localleader>dec :YcmCompleter GoToDeclaration<cr> 
noremap <silent> <localleader>impl :YcmCompleter GoToImplementation<cr>
noremap <silent> <localleader>ref :YcmCompleter GoToReferences<cr>
noremap <silent> <localleader>type :YcmCompleter GetType<cr>
noremap <silent> <localleader>ydoc :YcmCompleter GetDoc<cr>
noremap <silent> <localleader>fix :YcmCompleter FixIt<cr>
nnoremap <silent> <localleader>rn :YcmCompleter RefactorRename
" }}}

" Rust.vim Settings - {{{
let g:rustc_path = '/home/paul/.cargo/bin/rustc'
" }}}

" NERDTree Bindings - {{{
nnoremap <leader>nto :NERDTreeToggle<CR>
nnoremap <leader>ntf :NERDTreeFocus<CR>
nnoremap <leader>ntm :NERDTreeMirror<CR>
" }}}
