" === UTILS ===


" === FILETYPE SPECIFIC UTILITIES ===

" Delete trailing white space on save, useful for Python and CoffeeScript
function DeleteTrailingWhitespace()
  exe "normal mz"
  %s/\s\+$//e
  exe "normal `z"
endfunc

" === CLIPBOARD ===

" Hack to preserve clipboard on Vim suspend or exit
" (otherwise Ctrl+V will not output anything outside of the terminal)
if has("unnamedplus")
  set clipboard=unnamedplus

  if executable("xclip")
    autocmd VimLeave * call system('echo -n ' . shellescape(getreg('+')) .
      \ ' | xclip -selection clipboard')
  endif
endif

" https://stackoverflow.com/a/48959734/7960554
" TODO: Below doesn't work on suspend for some reason
" if has("unnamedplus")
"   if executable("xclip")
"     set clipboard=unnamedplus
"
"     function PreserveClipboard()
"       call system('echo -n ' . shellescape(getreg('+')) . ' | xclip -selection clipboard')
"     endfunction
"
"     function PreserveClipboardAndSuspend()
"       call PreserveClipboard()
"       suspend
"     endfunction
"
"     autocmd VimLeave * call PreserveClipboard()
"     nnoremap <silent> <c-z> :call PreserveClipboardAndSuspend()<cr>
"     vnoremap <silent> <c-z> :<c-u>call PreserveClipboardAndSuspend()<cr>
"   endif
" endif
