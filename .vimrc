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
set autochdir

filetype plugin on
filetype indent on

set autoindent
set tabstop=2
set sw=2
set expandtab

if has("gui_running")
  " http://vim.wikia.com/wiki/Maximize_or_set_initial_window_size
  " GUI is running or is about to start.
  " Maximize gvim window (for an alternative on Windows, see simalt below).
  set lines=999 columns=999
  set guifont=M+_1m_light:h14
  set guioptions+=c
endif

if has('nvim')
  let $NVIM_TUI_ENABLE_TRUE_COLOR=1
  let $NVIM_TUI_ENABLE_CURSOR_SHAPE=1

  augroup check_changes
    autocmd!
    autocmd BufEnter,FocusGained * checktime
  augroup END
endif

syntax on

set background=dark
colorscheme base16-atelierforest
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

" statusline
set statusline=%<
set statusline+=%(%-f\ %h%r%m\ %{fugitive#statusline()}%)
set statusline+=\ %#Error#%{neomake#statusline#LoclistStatus()}%* " lint errors
set statusline+=%= " boundary btw left and right sides
set statusline+=%-14.(%l,%c%V%) " line,col
set statusline+=%P " percentage through file


" PLUGIN SETTINGS


" supertab
let g:SuperTabDefaultCompletionType = "context"

" delimitMate
let delimitMate_expand_space = 1
let delimitMate_expand_cr = 2

" gist
let g:gist_clip_command = 'pbcopy'
let g:gist_detect_filetype = 1
let g:gist_post_private = 1

" ctrlp
let g:ctrlp_extensions = ['line', 'funky']

" jsx
let g:jsx_ext_required = 0

" jedi
let g:jedi#show_call_signatures = 0
let g:jedi#popup_on_dot = 0

" tern
" make sure we use the same node version that was used to install the tern server
let g:tern#command = [$NVM_DIR . '/versions/io.js/v2.5.0/bin/node', $HOME . '/.vim/bundle/tern_for_vim/node_modules/tern/bin/tern', '--no-port-file']
let g:tern#is_show_argument_hints_enabled = 0

" vim-flow
let g:flow#enable = 0

" The Silver Searcher
if executable('ag')
  " Use ag with ack.vim
  let g:ackprg = 'ag --nogroup --nocolor --column'
  " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
  " ag is fast enough that CtrlP doesn't need to cache
  let g:ctrlp_use_caching = 0
endif


" Neomake
" set neomake to prefer local eslint
" https://github.com/neomake/neomake/issues/247
function! NeomakeESlintChecker()
  let l:npm_bin = ''
  let l:eslint = 'eslint'
  if executable('npm-which')
    let l:eslint = split(system('npm-which eslint'))[0]
  elseif executable('npm')
    let l:npm_bin = split(system('npm bin'), '\n')[0]
    if strlen(l:npm_bin) && executable(l:npm_bin . '/eslint')
      let l:eslint = l:npm_bin . '/eslint'
    endif
  endif
  let b:neomake_javascript_eslint_exe = l:eslint
endfunction

augroup neomake_settings
  autocmd!
  autocmd FileType javascript,javascript.jsx :call NeomakeESlintChecker()
  autocmd BufWritePost * Neomake " run neomake on write
augroup END

let g:neomake_javascript_enabled_makers = ['eslint']
let g:neomake_python_pep8_args = [ '--ignore', 'E402' ]
" color the errors
let g:neomake_error_sign = {
    \ 'text': '✖',
    \ 'texthl': 'ErrorMsg',
    \ }
let g:neomake_warning_sign = {
  \ 'text': '✹',
  \ 'texthl': 'ErrorMsg',
  \ }


" COMMANDS


function! g:Curl(url)
  normal ggdG
  silent !clear
  let l:foo = ":read !curl -s " . a:url . " | jq ."
  set filetype=json
  execute foo
endfunction
command! -nargs=1 Curl call g:Curl(<f-args>)


" KEY BINDINGS


" window navigation
tnoremap <A-h> <C-\><C-n><C-w>h
tnoremap <A-j> <C-\><C-n><C-w>j
tnoremap <A-k> <C-\><C-n><C-w>k
tnoremap <A-l> <C-\><C-n><C-w>l
nnoremap <A-h> <C-w>h
nnoremap <A-j> <C-w>j
nnoremap <A-k> <C-w>k
nnoremap <A-l> <C-w>l
" use jk to leave insert mode
inoremap jk <esc>
" \<space> to clear search highlight
nnoremap <Leader><space> :nohlsearch<cr>
" \s to initiate search and replace for word under cursor
nnoremap <Leader>s :%s/\<<C-r><C-w>\>/
" \r to replace the last yanked(deleted/changed) word with last inserted text
" e.g.: cursor on a word, ciwNewWord<esc>, \r to repeat the change across the
" whole file
nnoremap <Leader>r :%s/\<<c-r>"\>/<c-r>./g
" and \S for a full code search
nnoremap <Leader>S :Ack! <C-r><C-w>
" \a for Ack
nnoremap <Leader>a :Ack! 
" \fu for function list
nnoremap <Leader>fu :CtrlPFunky<Cr>
" \fU narrow the list down with a word under cursor
nnoremap <Leader>fU :execute 'CtrlPFunky ' . expand('<cword>')<Cr>
" \b for buffers
nnoremap <Leader>b :CtrlPBuffer<Cr>
" toggle light/dark background
nnoremap <F5> :ToggleBackground<Cr>
" http://vim.wikia.com/wiki/Selecting_your_pasted_text
nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'
" code semantics
augroup tern_mappings
  autocmd!
  autocmd FileType javascript nnoremap <Leader>d :TernDoc<Cr>
  autocmd FileType javascript nnoremap <Leader>t :TernType<Cr>
augroup END
