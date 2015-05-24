execute pathogen#infect()


" VIM SETTINGS


set nocompatible
set nowritebackup
set noswapfile
set nobackup

set vb
set ruler
set nostartofline
set number
set showcmd
set selectmode=mouse
set splitright
set wildmode=longest,list,full
set wildmenu
set wildignore+=node_modules
set laststatus=2

filetype plugin on
filetype indent on

set autoindent
set tabstop=2
set sw=2
set expandtab

syntax on
autocmd BufNewFile,BufReadPost *.md set filetype=markdown

colorscheme solarized
call togglebg#map("<F5>")


" PLUGIN SETTINGS


" supertab
let g:SuperTabDefaultCompletionType = "context"

" ultisnips
let g:UltiSnipsExpandTrigger="<tab>"

" delimitMate
let delimitMate_expand_space = 1
let delimitMate_expand_cr = 2

" gist
let g:gist_clip_command = 'pbcopy'
let g:gist_detect_filetype = 1
let g:gist_post_private = 1

" ctrlp
let g:ctrlp_extensions = ['line', 'funky']

" The Silver Searcher
if executable('ag')
  " Use ag with ack.vim
  let g:ackprg = 'ag --nogroup --nocolor --column'
  " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
  " ag is fast enough that CtrlP doesn't need to cache
  let g:ctrlp_use_caching = 0
endif

" syntastic
let g:syntastic_enable_signs = 1
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 0
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
" FindRc() will try to find a .jshintrc up the current path string
" If it cannot find one it will try looking in the home directory
" finally it will return an empty list indicating jshint should use
" the defaults.
function! g:FindRc(name, path)
  let l:jshintrc_file = fnamemodify(a:path, ':p') . a:name
  if filereadable(l:jshintrc_file)
    return 1
  elseif len(a:path) > 1
    return g:FindRc(a:name, fnamemodify(a:path, ":h"))
  else
    return 0
  endif
endfun

function! g:setJavascriptChecker()
  if g:FindRc('.eslintrc', expand('%:p:h'))
    let b:syntastic_checkers = ['eslint']
  elseif g:FindRc('.jshintrc', expand('%:p:h'))
    let b:syntastic_checkers = ["jshint"]
  else
    let b:syntastic_checkers = ["standard"]
  endif
endfun

autocmd FileType javascript call g:setJavascriptChecker()

" up the font size
set guifont=Menlo\ Regular:h13

" vimrc segment for syntastic- and fugitive-enabled statusline
" from https://github.com/spf13/spf13-vim/blob/master/.vimrc
if has('statusline')
  set laststatus=2
  " Broken down into easily includeable segments
  set statusline=%<%f\    " Filename
  set statusline+=%w%h " Options
  set statusline+=%{fugitive#statusline()} "  Git Hotness
  set statusline+=\ %y            " filetype
  set statusline+=\ [%{getcwd()}]          " current dir
  set statusline+=%#warningmsg#
  set statusline+=%{SyntasticStatuslineFlag()}
  set statusline+=%*
  let g:syntastic_enable_signs=1
  set statusline+=%=%-14.(%l,%c%V%)\ %p%%  " Right aligned file nav info
endif



" KEY BINDINGS


" use jk to leave insert mode
inoremap jk <esc>
" \s to initiate search and replace for word under cursor
nnoremap <Leader>s :%s/\<<C-r><C-w>\>/
" \r to replace the last yanked(deleted/changed) word with last inserted text
" e.g.: cursor on a word, ciwNewWord<esc>, \r to repeat the change across the
" whole file
nnoremap <Leader>r :%s/\<<c-r>"\>/<c-r>./g
" and \S for a full code search
nnoremap <Leader>S :Ack <C-r><C-w>
" \a for Ack
nnoremap <Leader>a :Ack
" \fu for function list
nnoremap <Leader>fu :CtrlPFunky<Cr>
" \fU narrow the list down with a word under cursor
nnoremap <Leader>fU :execute 'CtrlPFunky ' . expand('<cword>')<Cr>
