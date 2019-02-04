" === PLUGINS === 
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/bundle')
Plug 'junegunn/vim-plug'  " self register


Plug 'altercation/vim-colors-solarized'  " Color Scheme

Plug 'mattn/emmet-vim'  " HTML generation

" Language Server Protocol
" which plugin is best for this?

Plug 'scrooloose/nerdtree'  " File Navigation

" === Unused ===
" Plug 'Vimjas/vim-python-pep8-indent'  " TODO: is this important?
" Plug 'tpope/vim-sensible'  " core.vim instead
" Plug 'vim-scripts/a.vim'  " Currently not used
" Plug 'ervandew/supertab'  " Replaced by YCM
" Plug 'vim-syntastic/syntastic'  " Using make lint instead
" Plug 'davidhalter/jedi-vim'  " Replaced by YCM
" Plug 'ctrlpvim/ctrlp.vim'  " Fuzzy file searcher, NERDTree for now
" Plug 'w0rp/ale'  " Async linting and LSP ?
call plug#end()
