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
  redraw!
endfunction

function s:FormatBuffer()
  setlocal
        \ bufhidden=wipe
        \ nobuflisted
        \ noswapfile
  redraw!
endfunction

function! s:RangerChooser(dirname, commanded)
  let s:temp = tempname()
  let s:callbacks = {
        \ 'on_stdout': function('s:JobHandler'),
        \ 'on_stderr': function('s:JobHandler'),
        \ 'on_exit': function('s:JobHandler')
        \}

  if isdirectory(a:dirname)
    if a:commanded == 1
      enew
    endif
    if exists(':terminal')
      let rangerjob = termopen('ranger --choosefile=' . shellescape(s:temp) . ' ' . a:dirname, s:callbacks) | startinsert | call s:FormatBuffer()
    endif
  endif
endfunction

function s:ExplorerWrapper(arg)
  if isdirectory(a:arg)
    call s:RangerChooser(a:arg, 1)
  else
    call s:RangerChooser(getcwd(), 1)
  endif
endfunction

au BufEnter * silent call s:RangerChooser(expand('<amatch>'), 0)
let g:loaded_netrwPlugin = 'disable'

command! -nargs=? -complete=dir Explore silent call s:ExplorerWrapper('<args>')
