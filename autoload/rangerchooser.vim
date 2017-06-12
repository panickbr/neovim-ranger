" based on
" https://github.com/Mizuchi/vim-ranger/blob/master/plugin/ranger.vim

function! rangerchooser#RangerJobHandler(job_id, data, event)
  if a:event == 'exit'
    call rangerchooser#FileHandler()
  endif
endfunction

function! rangerchooser#FileHandler()
  let buftoclose = bufnr('%')
  let filetoedit = ' '

  if filereadable(s:temp)
    let filetoedit = system('cat ' . s:temp)
  else
    if exists(':Startify')
      silent! Startify
    endif
  endif

  if filereadable(filetoedit)
    exec 'edit! ' . fnameescape(filetoedit)
    exec 'bd!' . buftoclose
  else
    " Get number of buffers
    " stolem from: http://superuser.com/a/345593
    "
    " Fixes bug with 'No listed buffer'
    " when opening a folder direct from command line
    let bufnuns = len(filter(range(1, bufnr('$')), 'buflisted(v:val)'))
    if bufnuns >= 1
      exec 'bp'
    endif
  endif

  redraw!
endfunction

function! rangerchooser#FormatBuffer()
  setlocal
        \ bufhidden=wipe
        \ nobuflisted
        \ noswapfile
  if exists(':AirlineRefresh')
     silent! AirlineRefresh
  endif
  redraw!
endfunction

function! rangerchooser#RangerChooser(dirname, commanded)
  if isdirectory(a:dirname)
    let s:temp = tempname()
    let s:callbacks = {
          \ 'on_stdout': function('rangerchooser#RangerJobHandler'),
          \ 'on_stderr': function('rangerchooser#RangerJobHandler'),
          \ 'on_exit': function('rangerchooser#RangerJobHandler')
          \}

    if a:commanded == 1
      enew
    endif

    let s:fullfilename = shellescape(s:temp) . ' ' . a:dirname

    if exists(':terminal')
      call termopen('ranger --choosefile=' . s:fullfilename, s:callbacks) | startinsert | call rangerchooser#FormatBuffer()
    else
      call rangerchooser#VanillaRanger()
    endif
  endif
endfunction

function! rangerchooser#VanillaRanger()
  if has("gui_running")
      exec 'silent !xterm -e ranger --choosefile=' . s:fullfilename
  else
      exec 'silent !ranger --choosefile=' . s:fullfilename
  endif

  if !filereadable(s:temp)
      redraw!
      return
  endif

  let name = system('cat ' . s:temp)
  exec 'bd'

  if name == ''
      redraw!
      return
  endif

  exec 'edit ' . fnameescape(name)

  doautocmd BufReadPost
  redraw!

  " exec 'silent !ranger --choosefile=' . s:fullfilename
  " let filename = system('cat ' . s:temp)
  " exec 'bd'

  " if filereadable(s:temp)
  "   exec 'edit!'  . fnameescape(filename)
  " endif
  " redraw!
endfunction

function! rangerchooser#ExplorerWrapper(arg)
  if isdirectory(a:arg)
    call rangerchooser#RangerChooser(a:arg, 1)
  elseif (a:arg == '')
    call rangerchooser#RangerChooser(getcwd(), 1)
  else
  endif
endfunction

