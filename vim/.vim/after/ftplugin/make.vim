" === MAKE ===

setlocal tabstop=8
setlocal shiftwidth=8

setlocal noexpandtab

autocmd BufWrite Makefile :call DeleteTrailingWhitespace()
