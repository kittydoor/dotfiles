" === PLUGINS === 
let iCanHazPlugins=1
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  " autocmd VimEnter * PlugInstall | source $MYVIMRC
  let iCanHazPlugins=0
endif

call plug#begin('~/.vim/bundle')

Plug 'junegunn/vim-plug'
Plug 'tpope/vim-sensible'

" Color Scheme
Plug 'altercation/vim-colors-solarized'

" === AutoCompletion ===
" General Autocomplete
function! BuildYCM(info)
  " info is a dictionary with 3 fields
  " - name:   name of the plugin
  " - status: 'installed', 'updated', or 'unchanged'
  " - force:  set on PlugInstall! or PlugUpdate!
  if a:info.status == 'installed' || a:info.force
    !./install.py
  endif
endfunction
" Plug 'Valloric/YouCompleteMe', { 'do': function('BuildYCM') }

" HTML generation
Plug 'mattn/emmet-vim'

" === Language Server Protocol ===
Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }

" === Auto-Completion ===
Plug 'ervandew/supertab'

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

if iCanHazPlugins == 0
  echo "Installing Plugins"
  :PlugInstall
endif
