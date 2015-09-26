" based on
"
" https://github.com/Mizuchi/vim-ranger/blob/master/plugin/ranger.vim

function s:JobHandler(job_id, data, event)
  if a:event == 'stdout'
    " echo 'stdout: ' . join(a:data)
  elseif a:event == 'stderr'
    " echo 'stderr: ' . join(a:data)
  else
    echo 'quit'
    call s:FileHandler(a:data)
  endif
endfunction

function s:FileHandler(data)
  if filereadable(s:temp)
    let buftoclose = bufnr('%')
    exec 'bd!' . buftoclose
    let filetoedit = system('cat ' . s:temp)
    exec 'edit ' . fnameescape(filetoedit)
    redraw!
  endif
endfunction

function! RangerChooser(dirname)
  let s:temp = tempname()

  let s:callbacks = {
        \ 'on_stdout': function('s:JobHandler'),
        \ 'on_stderr': function('s:JobHandler'),
        \ 'on_exit': function('s:JobHandler')
        \}

  if isdirectory(a:dirname)
    if exists(':terminal')
      " execute 'silent term ranger --choosefile=' . shellescape(temp) . ' ' . a:dirname
      enew
      let rangerjob = termopen('ranger --choosefile=' . shellescape(s:temp) . ' ' . a:dirname, s:callbacks) | file ranger-chooser | redraw! | startinsert
    else
      execute 'silent !ranger --choosefile=' . shellescape(s:temp) . ' ' . a:dirname
    endif

    " if filereadable(temp)
    "   let filetoedit = system('cat ' . temp)
    "   exec 'edit ' . fnameescape(filetoedit)
    "   filetype detect
    " endif
  endif
endfunction
