" === UTILS ===


" === FILETYPE SPECIFIC UTILITIES ===

" Delete trailing white space on save, useful for Python and CoffeeScript
function DeleteTrailingWhitespace()
  exe "normal mz"
  %s/\s\+$//e
  exe "normal `z"
endfunc

" === CLIPBOARD ===

" Wayland hack until clipboard properly implemented in Vim
if !empty($WAYLAND_DISPLAY)
  " Wayland
  vnoremap "+y y:call system("wl-copy", @")<cr>
  nnoremap "+p :let @"=substitute(system("wl-paste --no-newline"), '<C-v><C-m>', '', 'g',)<cr>p
  nnoremap "*p :let @"=substitute(system("wl-paste --no-newline --primary"), '<C-v><C-m>', '', 'g')<cr>p
elseif has("unnamedplus")
  " X11
  " Treat unnamed as + register
  set clipboard=unnamedplus
  if executable("xclip")
    " Hack to preserve clipboard on Vim suspend or exit
    " (otherwise Ctrl+V will not output anything outside of the terminal)
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
