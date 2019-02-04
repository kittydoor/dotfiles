" === JAVA ===

setlocal tabstop=4
setlocal shiftwidth=4

setlocal noexpandtab

autocmd BufWrite *.java :call DeleteTrailingWhitespace()

setlocal equalprg=astyle\ --style=java\ -n\ -s4
