" === YAML ===

setlocal ts=2
setlocal sw=2

setlocal expandtab

autocmd BufWrite *.yml,*.yaml :call DeleteTrailingWhitespace()
