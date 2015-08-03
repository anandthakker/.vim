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
set splitbelow
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

set guifont=Inconsolata-dz\ for\ Powerline:h13
set guioptions+=c

syntax on

set background=dark
let base16colorspace=256
colorscheme base16-atelierdune
" http://vim.wikia.com/wiki/Better_colors_for_syntax_highlighting
function! ReverseBackground()
  let Mysyn=&syntax
  if &bg=="light"
  se bg=dark
  else
  se bg=light
  endif
  syn on
  exe "set syntax=" . Mysyn
endfunction
command! ToggleBackground call ReverseBackground()

if exists('+colorcolumn')
  augroup colorcolumn
    autocmd!
    autocmd FileType javascript,python,markdown setlocal colorcolumn=80
  augroup END
endif

augroup python_filetype
    autocmd!
    autocmd FileType python set nowrap
    autocmd FileType python set tabstop=4
    autocmd FileType python set sw=4
augroup END

augroup markdown_filetype
  autocmd!
  autocmd BufNewFile,BufReadPost *.md set filetype=markdown
augroup END


" PLUGIN SETTINGS

" airline
let g:airline_powerline_fonts = 1
let g:airline#extensions#syntastic#enabled = 1

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

" jedi
let g:jedi#show_call_signatures = "2"

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
let g:syntastic_python_checkers = ['pep8']
let g:syntastic_enable_signs = 1
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 0
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
" FindRc() will try to find a .jshintrc/.eslintrc up the current path string
" If it cannot find one it will try looking in the home directory finally it
" will return an empty list indicating jshint should use the defaults.
function! g:FindRc(name, path)
  " Stop searching if we hit the home directory
  if a:path == $HOME
    return 0
  endif

  let l:rc_file = fnamemodify(a:path, ':p') . a:name
  if filereadable(l:rc_file)
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
    let b:syntastic_checkers = ["eslint"]
  endif
endfun

augroup javascript_syntax
  autocmd!
  autocmd FileType javascript call g:setJavascriptChecker()
augroup END


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
" toggle light/dark background
nnoremap <F5> :ToggleBackground<Cr>
