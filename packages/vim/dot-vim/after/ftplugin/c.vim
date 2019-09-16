" === C ===

setlocal softtabstop=8
setlocal shiftwidth=8

setlocal expandtab

autocmd BufWrite *.c :call DeleteTrailingWhitespace()

setlocal equalprg=astyle\ --style=linux\ -s8

let c_comment_strings=1  " TODO: Is this the right way to let variables in ftplugin?
