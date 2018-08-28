" === MARKDOWN ===

setlocal ts=2
setlocal sw=2

setlocal expandtab

autocmd BufWrite *.md :call DeleteTrailingWhitespace()
