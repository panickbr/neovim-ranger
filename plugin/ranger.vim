" based on
" https://github.com/Mizuchi/vim-ranger/blob/master/plugin/ranger.vim

function! s:RangerJobHandler(job_id, data, event)
  if a:event == 'exit'
    call s:FileHandler()
  endif
endfunction

function! s:FileHandler()
  let buftoclose = bufnr('%')
  let filetoedit = ' '

  if filereadable(s:temp)
    let filetoedit = system('cat ' . s:temp)
  endif

  exec 'bd!' . buftoclose

  if filereadable(filetoedit)
    exec 'edit! ' . fnameescape(filetoedit)
  endif

  redraw!
endfunction

function! s:FormatBuffer()
  setlocal
        \ bufhidden=wipe
        \ nobuflisted
        \ noswapfile
  if exists(':AirlineRefresh')
    AirlineRefresh
  endif
  redraw!
endfunction

function! s:RangerChooser(dirname, commanded)
  if isdirectory(a:dirname)
    let s:temp = tempname()
    let s:callbacks = {
          \ 'on_stdout': function('s:RangerJobHandler'),
          \ 'on_stderr': function('s:RangerJobHandler'),
          \ 'on_exit': function('s:RangerJobHandler')
          \}

    if a:commanded == 1
      enew
    endif

    let s:fullfilename = shellescape(s:temp) . ' ' . a:dirname

    if exists(':terminal')
      call termopen('ranger --choosefile=' . s:fullfilename, s:callbacks) | startinsert | call s:FormatBuffer()
    else
      call s:VanillaRanger()
    endif
  endif
endfunction

function! s:VanillaRanger()
  exec 'silent !ranger --choosefile=' . s:fullfilename
  let filename = system('cat ' . s:temp)

  if filereadable(s:temp)
    exec 'edit ' . fnameescape(filename)
  else
    exec 'bd'
  endif
  redraw!
endfunction

function! s:ExplorerWrapper(arg)
  if isdirectory(a:arg)
    call s:RangerChooser(a:arg, 1)
  elseif (a:arg == '')
    call s:RangerChooser(getcwd(), 1)
  else
  endif
endfunction

let g:loaded_netrwPlugin = 'disable'
au BufEnter * silent call s:RangerChooser(expand('<amatch>'), 0)

command! -nargs=? -bar -complete=dir Explore silent call s:ExplorerWrapper('<args>')
