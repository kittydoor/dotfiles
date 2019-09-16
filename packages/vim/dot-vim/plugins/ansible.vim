" === ANSIBLE ===

" After two new lines in insert mode, unindent to 0,
" rather than continue keeping indent
let g:ansible_unindent_after_newline = 1

" Default: include until retries delay when only_if become become_user block rescue always notify
" Extra: register always_run changed_when failed_when no_log args vars delegate_to ignore_errors
let g:ansible_extra_keywords_highlight = 1
