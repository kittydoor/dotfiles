" === PYTHON ===

setlocal softtabstop=4
setlocal shiftwidth=4

setlocal expandtab

autocmd BufWrite *.py :call DeleteTrailingWhitespace()

" === A) Highlight Excess Characters ===
highlight OverLength ctermbg=red ctermfg=white guibg=#592929
match OverLength /\%80v.\+/

" === B) Automatically Wrap Long Lines ===
" setlocal textwidth=79
" setlocal linebreak

