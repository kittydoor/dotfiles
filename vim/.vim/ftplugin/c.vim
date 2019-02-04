" === C ===

setlocal softtabstop=8
setlocal shiftwidth=8

setlocal expandtab

autocmd BufWrite *.c :call DeleteTrailingWhitespace()

setlocal equalprg=astyle\ --style=linux\ -s8
