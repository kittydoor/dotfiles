" === MARKDOWN ===

setlocal ts=2
setlocal sw=2

setlocal expandtab

autocmd BufWrite *.md :call DeleteTrailingWhitespace()

" grip (from pip) is a good tool for visualizing markdown
" perhaps also use vim-markdown-preview
