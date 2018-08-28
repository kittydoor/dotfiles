" === PYTHON ===

setlocal ts=4
setlocal sw=4

setlocal expandtab

highlight OverLength ctermbg=red ctermfg=white guibg=#592929
match OverLength /\%80v.\+/

autocmd BufWrite *.py :call DeleteTrailingWhitespace()
