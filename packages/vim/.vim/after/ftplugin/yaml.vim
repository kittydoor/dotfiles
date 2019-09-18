" === YAML ===

setlocal softtabstop=2
setlocal shiftwidth=2

setlocal expandtab

autocmd BufWrite *.yml,*.yaml :call DeleteTrailingWhitespace()
