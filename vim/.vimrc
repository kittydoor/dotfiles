set nocompatible
filetype off

let iCanHazVundle=1
let vundle_readme=expand('~/.vim/bundle/vundle/README.md')
if !filereadable(vundle_readme)
  echo "Installing Vundle..."
  echo ""
  silent !mkdir -p ~/.vim/bundle
  silent !git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/vundle
  let iCanHazVundle=0
endif

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'

" Plugin 'ervandew/supertab'
Plugin 'vim-syntastic/syntastic'
Plugin 'davidhalter/jedi-vim'

call vundle#end()

if iCanHazVundle == 0
  echo "Installing Bundles"
  :BundleInstall
endif

filetype plugin indent on
" Vundle End, everything before this is Vundle setup"

" nmap <silent> <A-k> :wincmd k<CR>
" nmap <silent> <A-j> :wincmd j<CR>
" nmap <silent> <A-h> :wincmd h<CR>
" nmap <silent> <A-l> :wincmd l<CR>

set number
set ruler
set laststatus=2 " why two?

set textwidth=0
set wrap

set autoread

set undolevels=1000
set history=1000

set nospell
set backspace=eol,start,indent " research if this makes sense

filetype plugin indent on
syntax enable
colorscheme desert
set background=dark

set encoding=utf8
set ffs=unix,dos,mac

set autoindent
set noexpandtab
set smartindent
set smarttab

set shiftwidth=8
set tabstop=8
set softtabstop=8 " what is this compared to the previous?

set noerrorbells
set novisualbell " what is this?

set showmatch

set incsearch
set hlsearch
set ignorecase

"airline start
set ttimeoutlen=10
let g:airline_powerline_fonts = 1
let g:airline_theme='solarized'
let g:airline#extensions#tabline#enabled = 1
"airline end

" let g:powerline_pycmd="py3"

" set so=5
" set wildmenu
" set wildignore=*.o,*~,*.pyc
" set cmdheight=1
" set hid
" set tm=500
" set t_vb=
" set lazyredraw
" set smartcase
" set whichwrap+=<,>,h,l
" set statusline=\ %{HasPaste()}%F%m%r%h\ %w\ \ CWD:\ %r%{getcwd()}%h\ \ \ Line:\ %l " do I want this or different?
" Delete trailing white space on save, useful for Python and CoffeeScript ;)
"func! DeleteTrailingWS()
"  exe "normal mz"
"  %s/\s\+$//ge
"  exe "normal `z"
"endfunc
"autocmd BufWrite *.py :call DeleteTrailingWS()
"autocmd BufWrite *.coffee :call DeleteTrailingWS()

set ts=2
set sw=2
set expandtab
