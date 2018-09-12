" === UTILS ===


" === FILETYPE SPECIFIC UTILITIES ===

" Delete trailing white space on save, useful for Python and CoffeeScript
function DeleteTrailingWhitespace()
  exe "normal mz"
  %s/\s\+$//e
  exe "normal `z"
endfunc

" === CLIPBOARD ===

if has('unnamedplus')
  if executable("xclip")
    set clipboard=unnamedplus

    function PreserveClipboard()
      call system("xclip -selection clipboard", getreg('+'))
    endfunction

    function PreserveClipboardAndSuspend()
      call PreserveClipboard()
      suspend
    endfunction

    autocmd VimLeave * call PreserveClipboard()
    nnoremap <silent> <c-z> :call PreserveClipboardAndSuspend()<cr>
  
  endif
endif
