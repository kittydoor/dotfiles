" === GENERIC ===
set nocompatible
filetype plugin indent on

set number
set ruler
set laststatus=2 " why two?

set tabstop=2
set shiftwidth=2
set expandtab

set textwidth=0
set wrap

set autoread

set undolevels=1000
set history=1000

set nospell
set backspace=eol,start,indent " research if this makes sense

set encoding=utf8
set ffs=unix,dos,mac

set autoindent
set noexpandtab
set smartindent
" set smarttab " deprecated

set shiftwidth=8
set tabstop=8
set softtabstop=8 " what is this compared to the previous?

set noerrorbells
set novisualbell " what is this?

set showmatch

set incsearch
set hlsearch
set ignorecase

set mouse=a

set ttimeoutlen=10

filetype plugin indent on
" syntax enable " Keeps current highlight colors
syntax on " Overwrites current highlight colors
set background=dark
colorscheme solarized
