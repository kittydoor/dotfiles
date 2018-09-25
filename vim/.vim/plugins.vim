" === PLUGINS === 
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/bundle')

Plug 'junegunn/vim-plug'

" Color Scheme
Plug 'altercation/vim-colors-solarized'

" === AutoCompletion ===
" General Autocomplete
Plug 'Valloric/YouCompleteMe', {
    \ 'do': './install.py',
    \ }

" HTML generation
Plug 'mattn/emmet-vim'

" Language Server Protocol
Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }

" === Python ===
Plug 'Vimjas/vim-python-pep8-indent' " Fixed python indentation

" === File Navigation ===
Plug 'scrooloose/nerdtree'

" === Unused ===
" Plug 'vim-scripts/a.vim' " Currently not used
" Plug 'ervandew/supertab' " Replaced by YCM
" Plug 'vim-syntastic/syntastic' " Using make lint instead
" Plug 'davidhalter/jedi-vim' " Replaced by YCM
" Plug 'ctrlpvim/ctrlp.vim' " Fuzzy file searcher, NERDTree for now
" Plug 'w0rp/ale' " Async linting and LSP ?
" TODO: Perhaps implement python-language-server + LSP?
call plug#end()
