let g:loaded_netrwPlugin = 'disable'

augroup RangerExplorer
  au!
  au BufEnter * silent call rangerchooser#RangerChooser(expand('<amatch>'), 0)
augroup END

command! -nargs=? -bar -complete=dir Explore silent call rangerchooser#ExplorerWrapper('<args>')
