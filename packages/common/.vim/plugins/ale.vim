" === ALE - Asynchronous Lint Engine ===

" Linting
let g:ale_linters = {}
let g:ale_linters['javascript'] = ['eslint']

" Fixing
let g:ale_fixers = {}
let g:ale_fixers['javascript'] = ['eslint']

let g:ale_fix_on_save = 1

" Completion
let g:ale_completion_enabled = 1
let g:ale_python_flake8_options="--ignore=E501"
