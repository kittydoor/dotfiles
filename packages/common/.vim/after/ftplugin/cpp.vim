" === C ===

setlocal softtabstop=4
setlocal shiftwidth=4

setlocal expandtab

autocmd BufWrite *.cpp :call DeleteTrailingWhitespace()
