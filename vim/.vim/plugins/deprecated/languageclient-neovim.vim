" === LANGUAGECLIENT-NEOVIM ===

" Required for operations modifying multiple buffers like rename.
set hidden

" \ 'rust': ['~/.cargo/bin/rustup', 'run', 'stable', 'rls'],
" \ 'javascript': ['/usr/local/bin/javascript-typescript-stdio'],
" \ 'javascript.jsx': ['tcp://127.0.0.1:2089'],
let g:LanguageClient_serverCommands = {
    \ 'python': ['python', '-m', 'pyls'],
    \ }

nmap <F5> :call LanguageClient_contextMenu()<CR>
" Or map each action separately
nmap <silent> K :call LanguageClient#textDocument_hover()<CR>
nmap <silent> gd :call LanguageClient#textDocument_definition()<CR>
imap <silent> <F2> <C-O>:call LanguageClient#textDocument_rename()<CR>
