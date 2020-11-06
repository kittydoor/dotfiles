" === PLUGINS ===
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/bundle')
Plug 'junegunn/vim-plug'  " self register

" Plug 'altercation/vim-colors-solarized'  " Color Scheme

Plug 'mattn/emmet-vim'  " HTML generation
Plug 'tpope/vim-surround'  " Surrounding elements (, {, <, '...

Plug 'tpope/vim-abolish'  " case preserving utilities

" Language Server Protocol
Plug 'w0rp/ale'  " Async linting and LSP

Plug 'scrooloose/nerdtree'  " File Navigation

" === Language Specific ===
" Ansible
Plug 'pearofducks/ansible-vim'  " Ansible yaml, hosts, and .j2 files
" Javascript
Plug 'pangloss/vim-javascript'  " React and Javascript

" === Unused ===
" Plug 'Vimjas/vim-python-pep8-indent'  " TODO: is this important?
" Plug 'tpope/vim-sensible'  " core.vim instead
" Plug 'vim-scripts/a.vim'  " Currently not used
" Plug 'neoclide/coc.nvim'  " Seems like a promising completion LSP solution
" Plug 'ervandew/supertab'  " Replaced by YCM
" Plug 'vim-syntastic/syntastic'  " Using make lint instead
" Plug 'davidhalter/jedi-vim'  " Replaced by YCM
" Plug 'ctrlpvim/ctrlp.vim'  " Fuzzy file searcher, NERDTree for now
call plug#end()
