" vim: nowrap foldmethod=marker foldlevel=0

" Plugins {{{ install vim-plug if not installed
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall
endif

call plug#begin()

" Colorschemes
Plug 'arcticicestudio/nord-vim'

" Utils
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-repeat'
Plug 'itchyny/lightline.vim'
Plug 'maximbaz/lightline-trailing-whitespace'
Plug 'preservim/nerdtree'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'justinmk/vim-sneak'
Plug 'airblade/vim-gitgutter'
Plug 'APZelos/blamer.nvim'
Plug 'dense-analysis/ale'
Plug 'maximbaz/lightline-ale'
Plug 'prabirshrestha/asyncomplete.vim'

" C#
Plug 'OmniSharp/omnisharp-vim'
Plug 'nickspoons/vim-sharpenup'

call plug#end()
" }}}

" base config
let mapleader = ","
set hidden
set ruler              " show the cursor position all the time
set undofile           " keep an undo file (undo changes after closing)
set noswapfile         " do not write swap files
set listchars=tab:▸\ ,trail:·,extends:#,nbsp:·,eol:¬
set list!              " show invisible characters by default
set clipboard+=unnamedplus " always use clipboard
set pastetoggle=<F2>
set completeopt-=preview  " disable preview for completion
set scrolloff=1        " nr of lines to keep above and below cursor
set splitbelow         " new window split below


" Colorscheme and highlighting {{{
" set Vim-specific sequences for RGB colors
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

if (has("termguicolors"))
  set termguicolors
endif

colorscheme nord

syntax on
set showmatch          " highlight matching [{()}]
set cursorline         " highlight current line

" highlighting strings inside comments.
let c_comment_strings=1

" underline misspelled words
hi! SpellBad cterm=NONE,undercurl term=NONE,undercurl ctermfg=NONE ctermbg=NONE guisp=DarkRed

" transparent background
hi! Normal guibg=NONE ctermbg=NONE
hi! SignColumn guibg=NONE ctermbg=NONE
hi! CursorColumn guibg=NONE ctermbg=NONE
hi! LineNr guibg=NONE ctermbg=NONE
hi! CursorLineNr guibg=NONE ctermbg=NONE
" }}}

" fugitive settings {{{
" easy navigate in git history
au User fugitive
  \ if fugitive#buffer().type() =~# '^\%(tree\|blob\)$' |
  \   nmap <buffer> .. :edit %:h<CR> |
  \ endif
au BufReadPost fugitive://* set bufhidden=delete
" }}}

" vim-sneak settings {{{
let g:sneak#s_next = 1
" }}}

" gitgutter settings {{{
let g:gitgutter_terminal_reports_focus=0
set updatetime=100
" make sure we update the gutter on write, commits etc
au BufWritePost * GitGutter
" }}}

" blamer settings {{{
let g:blamer_enabled = 1
let g:blamer_relative_time = 1
let g:blamer_date_format = '%y-%m-%d'
" }}}

" lightline settings {{{
let g:lightline#trailing_whitespace#indicator='•'
let g:sharpenup_statusline_opts = { 'Highlight': 0 }
let g:lightline = {
      \ 'colorscheme': 'nord',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste'],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ]
      \           ],
      \   'right': [ [ 'trailing', 'lineinfo' ],
      \              [ 'percent' ],
      \              [ 'sharpenup', 'fileformat', 'fileencoding', 'filetype' ]
      \            ],
      \ },
      \ 'component_expand': {
      \   'gitbranch': 'fugitive#head',
      \   'trailing': 'lightline#trailing_whitespace#component',
      \   'sharpenup': 'sharpenup#statusline#Build'
      \ },
      \ 'component_type': {
      \   'trailing': 'warning'
      \ },
      \ }

" Use unicode chars for ale indicators in the statusline
let g:lightline#ale#indicator_checking = "\uf110 "
let g:lightline#ale#indicator_infos = "\uf129 "
let g:lightline#ale#indicator_warnings = "\uf071 "
let g:lightline#ale#indicator_errors = "\uf05e "
let g:lightline#ale#indicator_ok = "\uf00c "

augroup lightline_integration
  autocmd!
  autocmd User OmniSharpStarted,OmniSharpReady,OmniSharpStopped call lightline#update()
augroup END
" }}}

" ale {{{
let g:ale_sign_error = '•'
let g:ale_sign_warning = '•'
let g:ale_sign_info = '·'
let g:ale_sign_style_error = '·'
let g:ale_sign_style_warning = '·'

let g:ale_linters = { 'cs': ['OmniSharp'] }
" }}}

" asyncomplete: {{{
let g:asyncomplete_auto_popup = 0
let g:asyncomplete_auto_completeopt = 0
" }}}

" vim-sharpenup {{{
let g:sharpenup_map_prefix = ','
" }}}

" OmniSharp: {{{
let g:OmniSharp_popup_position = 'peek'
let g:OmniSharp_popup_options = {
  \ 'winhl': 'Normal:NormalFloat'
  \}
let g:OmniSharp_popup_mappings = {
  \ 'sigNext': '<C-n>',
  \ 'sigPrev': '<C-p>',
  \ 'pageDown': ['<C-f>', '<PageDown>'],
  \ 'pageUp': ['<C-b>', '<PageUp>']
  \}

" if using ultisnips
" let g:OmniSharp_want_snippet = 1

let g:OmniSharp_highlight_groups = {
  \ 'ExcludedCode': 'NonText'
  \}
" }}}

" Functions {{{
" strip trailing whitespaces (mapped to <leader><BS>)
function! StripTrailingWhitespaces()
  " preparation save last search, and cursor position.
  let _s=@/
  let l = line(".")
  let c = col(".")
  " do the business:
  %s/\s\+$//e
  " clean up: restore previous search history, and cursor position
  let @/=_s
  call cursor(l, c)
endfunc

" use 2 spaces for indenting
function! TabstyleSpaces()
  set softtabstop=2 " when hitting <BS>, pretend like a tab is removed, even if spaces
  set shiftwidth=2  " number of spaces to use for autoindenting
  set tabstop=2     " a tab is two spaces
  set expandtab     " expand tabs by default
  set shiftround    " use multiple of shiftwidth when indenting with '<' and '>'
endfunc
command! -nargs=* Tspaces call TabstyleSpaces()

" using 4 column tabs for indenting
function! TabstyleTabs()
  set softtabstop=4
  set shiftwidth=4
  set tabstop=4
  set noexpandtab
  set noshiftround
endfunc
command! -nargs=* Ttabs call TabstyleTabs()

call TabstyleTabs() " default to tabs (I'm more of for spaces but .NET is tab)
" }}}

" Key mappings
" leave insert mode easy
map <C-c> <Esc>
inoremap jk <Esc>

" write with W also
command! W w

" don't use Ex mode, use Q for formatting
noremap Q gq

" remove highlight from search and turn of spelling, simply no highlights
nnoremap <leader><space> :exe "nohlsearch \| set nospell"<CR>

" stripe whitespaces
map <leader><BS> :call StripTrailingWhitespaces()<CR>

" toggle invisibles
map <leader>i :set list!<CR>

" select text just pasted
noremap gV `[v`]

" move to beginning/end of line
nnoremap B ^
nnoremap E $

" easy jumping with Swedish keyboard layout
map <C-h> <C-t>
map <C-l> <C-]>

" tag completion on Swedish keyboard is a pain
imap <C-x><C-m> <C-x><C-]>

" easy buffer jumping
nmap bn :bn<CR>
nmap bp :bp<CR>

" jump between current and last buffer/file
nmap <leader><leader> <C-^>

" bubble single lines (using tpope/vim-unimpaired)
nmap <C-k> [e
nmap <C-j> ]e

" bubble multiple lines (using tpope/vim-unimpaired)
vmap <C-k> [egv
vmap <C-j> ]egv

map <leader>n :NERDTreeToggle<CR>

" fzf
map <leader>f :Files<CR>
map <leader>gf :GFiles<CR>
map <leader>b :Buffers<CR>
map <leader>a :Ag

" File types {{{
filetype plugin indent on

augroup vimrcEx
  au!

  " text files set 'textwidth' to 78 characters.
  au FileType text setlocal textwidth=78

  " when editing a file, always jump to the last known cursor position.
  au BufReadPost *
    \ if line("'\"") >= 1 && line("'\"") <= line("$") |
    \   execute "normal! g`\"" |
    \ endif

augroup END

augroup fileconf
  au!
  au BufRead,BufNewFile *.psql set ft=sql
augroup END
" }}}
