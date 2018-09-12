" === PLUGINS === 
set nocompatible " required
filetype off     " required

let iCanHazVundle=1
let vundle_readme=expand('~/.vim/bundle/Vundle.vim/README.md')
if !filereadable(vundle_readme)
  echo "Installing Vundle..."
  echo ""
  silent !mkdir -p ~/.vim/bundle
  silent !git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
  let iCanHazVundle=0
endif

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'

" Color Scheme
Plugin 'altercation/vim-colors-solarized'

" === AutoCompletion ===
" General Autocomplete
Plugin 'Valloric/YouCompleteMe'
" HTML generation
Plugin 'mattn/emmet-vim'

" === Python ===
Plugin 'Vimjas/vim-python-pep8-indent' " Fixed python indentation

" === File Navigation ===
Plugin 'scrooloose/nerdtree'
" Plugin 'vim-scripts/a.vim' " Currently not used

" === Unused ===
" Plugin 'ervandew/supertab' " Replaced by YCM
" Plugin 'vim-syntastic/syntastic' " Using make lint instead
" Plugin 'davidhalter/jedi-vim' " Replaced by YCM
" Plugin 'ctrlpvim/ctrlp.vim' " Fuzzy file searcher, NERDTree for now
" Plugin 'w0rp/ale' " Async linting and LSP ?
" TODO: Perhaps implement python-language-server + LSP?

call vundle#end()

if iCanHazVundle == 0
  echo "Installing Bundles"
  :PluginInstall
endif

filetype plugin indent on
