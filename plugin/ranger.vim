" based on
" https://github.com/Mizuchi/vim-ranger/blob/master/plugin/ranger.vim

function s:JobHandler(job_id, data, event)
  if a:event == 'exit'
    call s:FileHandler()
  endif
endfunction

function s:FileHandler()
  let buftoclose = bufnr('%')
  if filereadable(s:temp)
    let filetoedit = system('cat ' . s:temp)
    exec 'edit ' . fnameescape(filetoedit)
  else
    exec 'bd!' . buftoclose
  endif
endfunction

function s:FormatBuffer()
  setlocal
        \ bufhidden=wipe
        \ nobuflisted
  " if empty(&statusline)
  "   setlocal statusline=\ ranger
  " endif
  noswapfile
  redraw!
  startinsert
endfunction

function! s:RangerChooser(dirname)
  let s:temp = tempname()

  let s:callbacks = {
        \ 'on_stdout': function('s:JobHandler'),
        \ 'on_stderr': function('s:JobHandler'),
        \ 'on_exit': function('s:JobHandler')
        \}

  if isdirectory(a:dirname)
    if exists(':terminal')
      let rangerjob = termopen('ranger --choosefile=' . shellescape(s:temp) . ' ' . a:dirname, s:callbacks) | call s:FormatBuffer()
    else
    endif
  endif
endfunction

au BufEnter * silent call s:RangerChooser(expand('<amatch>'))
let g:loaded_netrwPlugin = 'disable'
