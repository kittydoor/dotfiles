" === MARKDOWN ===

setlocal softtabstop=2
setlocal shiftwidth=2

setlocal expandtab

autocmd BufWrite *.md :call DeleteTrailingWhitespace()

" grip (from pip) is a good tool for visualizing markdown
" perhaps also use vim-markdown-preview
