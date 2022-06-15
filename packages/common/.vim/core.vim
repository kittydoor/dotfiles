" === CORE ===

set nocompatible
filetype plugin indent on

" Sensible Configuration (modified)
"""""""""""""""""""""""""""""""""""
" TODO: Look into this more, nvim compatibility, defaults.vim etc.
" https://github.com/tpope/vim-sensible
set autoindent  " keep indent on newline
set backspace=indent,eol,start  " sensible backspace

" https://github.com/tpope/vim-sensible/issues/51
" if using ctags it is redundant,
" and potentially slow in big projects
set complete-=i  " ^N - Disables scanning included files
set smarttab  " shiftwidth at beginning of line rather than ts or sts

set nrformats-=octal " disable ^A ^X on octal numbers 007 -> 010

" nvim behaves differently
if !has('nvim') && &ttimeoutlen == -1
  set ttimeout
  set ttimeoutlen=100
endif

set incsearch
" Use <C-L> to clear the highlighting of :set hlsearch.
nnoremap <silent> <C-L> :nohlsearch<C-R>=has('diff')?'<Bar>diffupdate':''<CR><CR><C-L>

set laststatus=2  " status line always on
set ruler  " show line and column number
set wildmenu
" set wildmode=stuff

" if !&scrolloff  " TODO: What does & mean, default?
set scrolloff=1  " offset N lines when scrolling for context
set sidescrolloff=5  " offset N lines when scrollig sideways
set display+=lastline  " show as much of last line, and suffic with @@@

if &encoding ==# 'latin1' && has('gui_running')
  set encoding=utf-8  " TODO: Why not always set?
endif

set showbreak=>\   " show breaks as > followed by spaces
set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+
set list  " enable listchars

set formatoptions+=j  " delete comment token when joining lines

if has('path_extra')
  setglobal tags-=./tags tags-=./tags; tags^=./tags;  " search tags prioritizing local
endif

set autoread  " if file changes, read into vim

set history=1000  " cmdline history
set tabpagemax=50  " amount of tab pages you can open at once

" handy for plugins to store data
set viminfo^=!  " keeps all UPPERCASE or WITH_UNDERSCORES variable state
set sessionoptions-=options  " don't remember options on mksession, always use vimrc

" Allow color schemes to do bright colors without forcing bold.
if &t_Co == 8 && $TERM !~# '^linux\|^Eterm'
  set t_Co=16
endif

inoremap <C-U> <C-G>u<C-U>  " C-G breaks undo so that inserted text is a separate undo

" Not in Sensible.vim
"""""""""""""""""""""

" Disable arrow keys (because it's a bad habit)
nnoremap <Left> <nop>
nnoremap <Up> <nop>
nnoremap <Right> <nop>
nnoremap <Down> <nop>
inoremap <Left> <nop>
inoremap <Up> <nop>
inoremap <Right> <nop>
inoremap <Down> <nop>
vnoremap <Left> <nop>
vnoremap <Up> <nop>
vnoremap <Right> <nop>
vnoremap <Down> <nop>

" From defaults.vim, disable Q to ex mode, instead format
map Q gq
" TODO: Maybe also get last known cursor position and :DiffOrig

" https://stackoverflow.com/a/33380495
if !exists("g:syntax_on")
    syntax enable
endif

set number relativenumber  " show relative numbers, except for current line

set nospell  " TODO: Inspect this more

" set ffs=unix,dos,mac  " TODO: Is this useful?

set showmatch  " when a bracket is inserted, blink the matching one

set hlsearch  " show all matches on search, C-L disables
set ignorecase  " ignore case in searches

set mouse=a  " enable mouse

set path=**  " search all dirs in current dir

" set lazyredraw  " makes large macros work much faster
set background=dark
