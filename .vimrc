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
set tabstop=4
set sw=4
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

augroup python_filetype
    autocmd!
    autocmd FileType python set nowrap
    autocmd FileType python set tabstop=4
    autocmd FileType python set sw=4
augroup END

augroup markdown_filetype
  autocmd!
  autocmd BufNewFile,BufReadPost *.md set filetype=markdown
  autocmd FileType markdown let delimitMate_expand_space = 0
augroup END

" statusline
set statusline=%<
set statusline+=%(%-f\ %h%r%m\ %{fugitive#statusline()}%)

if has('nvim')
  set statusline+=\ %#Error#%{neomake#statusline#LoclistStatus()}%* " lint errors
endif

set statusline+=%= " boundary btw left and right sides
set statusline+=%-14.(%l,%c%V%) " line,col
set statusline+=%P " percentage through file


" COLORS


"Use 24-bit (true-color) mode in Vim/Neovim when outside tmux.
"If you're using tmux version 2.2 or later, you can remove the outermost $TMUX check and use tmux's 24-bit color support
"(see < http://sunaku.github.io/tmux-24bit-color.html#usage > for more information.)
if (empty($TMUX))
  if (has("nvim"))
  "For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
  let $NVIM_TUI_ENABLE_TRUE_COLOR=1
  endif
  "For Neovim > 0.1.5 and Vim > patch 7.4.1799 < https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162 >
  "Based on Vim patch 7.4.1770 (`guicolors` option) < https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd >
  " < https://github.com/neovim/neovim/wiki/Following-HEAD#20160511 >
  if (has("termguicolors"))
    set termguicolors
  endif
endif

set background=dark
colorscheme one

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
let g:ctrlp_working_path_mode = 'cr'

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
let g:flow#enable = 1

" vim-javascript
let g:javascript_plugin_jsdoc = 1
let g:javascript_plugin_flow = 1

" vim-gitgutter
let g:gitgutter_sign_added = '|'
let g:gitgutter_sign_modified = '|'
let g:gitgutter_sign_removed = '|'
" let g:gitgutter_sign_removed_first_line = '^^'
" let g:gitgutter_sign_modified_removed = 'ww'

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

let g:neomake_cpp_enabled_makers=['clang']
let g:neomake_cpp_clang_args = ["-std=c++14", "-Wextra", "-Wall"]

let g:neomake_python_flake8_args = [ '--ignore', 'E402,E501' ]

" Find local node_modules version of given module if possible
" https://github.com/neomake/neomake/issues/247
function! GetNpmBin(name)
  let l:npm_bin = ''
  let l:cmd = a:name
  if executable('npm-which')
    let l:cmd = split(system('npm-which ' . a:name))[0]
  elseif executable('npm')
    let l:npm_bin = split(system('npm bin'), '\n')[0]
    if strlen(l:npm_bin) && executable(l:npm_bin . '/' . a:name)
      let l:cmd = l:npm_bin . '/' . a:name
    endif
  endif
  return l:cmd
endfunction

function! SetJavascriptMaker()
  let l:pkg = split(system('npm prefix'), '\n')[0] . '/package.json'
  let l:pkg_data = pyeval('json.load(open("' . l:pkg . '"))')
  let l:dev_dependencies = get(l:pkg_data, 'devDependencies', {})
  if has_key(l:dev_dependencies, 'standard')
    let g:neomake_javascript_enabled_makers = ['standard']
    let b:neomake_javascript_standard_exe = GetNpmBin('standard')
  else
    let g:neomake_javascript_enabled_makers = ['eslint']
    let b:neomake_javascript_eslint_exe = GetNpmBin('eslint')
  endif
endfunction

augroup neomake_settings
  if has('nvim')
    autocmd!
    autocmd FileType javascript,javascript.jsx :call SetJavascriptMaker()
    autocmd BufWritePost * Neomake " run neomake on write
  endif
augroup END

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
if has('nvim')
  tnoremap <A-h> <C-\><C-n><C-w>h
  tnoremap <A-j> <C-\><C-n><C-w>j
  tnoremap <A-k> <C-\><C-n><C-w>k
  tnoremap <A-l> <C-\><C-n><C-w>l
endif

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
