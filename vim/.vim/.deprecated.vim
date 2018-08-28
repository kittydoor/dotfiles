" let mapleader = "\"

" Vim Omnicomplete
" set omnifunc=syntaxcomplete#Complete

" Plugin Syntastic
" Recommended
" set statusline+=%#warningmsg#
" set statusline+=%{SyntasticStatuslineFlag()}
" set statusline+=%*
" 
" let g:syntastic_always_populate_loc_list = 1
" let g:syntastic_auto_loc_list = 1
" let g:syntastic_check_on_open = 1
" let g:syntastic_check_on_wq = 0

" Custom
" let g:syntastic_javascript_checkers = ['eslint']

" ale
" autocmd bufwritepost *.js silent !./node_modules/.bin/standard --fix %
" set autoread

" Generic
" nmap <silent> <A-k> :wincmd k<CR>
" nmap <silent> <A-j> :wincmd j<CR>
" nmap <silent> <A-h> :wincmd h<CR>
" nmap <silent> <A-l> :wincmd l<CR>


"airline start
"let g:airline_powerline_fonts = 1
"let g:airline_theme='solarized'
"let g:airline#extensions#tabline#enabled = 1
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
