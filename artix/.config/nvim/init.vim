" Neovim configuration, by Daniel Wayne Armstrong hello@dwarmstrong.org
"
" == General configuration ==

set nocompatible            " disable compatibility to old-time vi
set showmatch               " show matching brackets.
set ignorecase              " case insensitive matching
set mouse=v                 " middle-click paste with mouse
set hlsearch                " highlight search results
set autoindent              " indent a new line the same amount as the line just typed
set number                  " add line numbers
set wildmode=longest,list   " get bash-like tab completions
set cc=80                   " set colour columns for good coding style
filetype plugin indent on   " allow auto-indenting depending on file type
set tabstop=4               " number of columns occupied by a tab character
set expandtab               " convert tabs to white space
set shiftwidth=4            " width for autoindents
set softtabstop=4           " see multiple spaces as tabstops so <BS> does the right thing

" == Colors ==

syntax on                   " syntax highlighting
" built-in schemes installed in `/usr/share/nvim/runtime/colors`; extra schemes in `~/.config/nvim/colors`
" colorscheme default     " `default` picks up colors defined in `~/.Xresources`
let g:tokyonight_style = "storm"
let g:tokyonight_italic_functions = 1
let g:tokyonight_sidebars = [ "qf", "vista_kind", "terminal", "packer" ]

" Change the "hint" color to the "orange" color, and make the "error" color bright red
let g:tokyonight_colors = {
  \ 'hint': 'orange',
  \ 'error': '#ff0000'
\ }

" Load the colorscheme
colorscheme tokyonight

" == Mode mappings ==

" normal mode map -- `:nnoremap`
" insert mode map -- `:inoremap`

" map leader
let g:mapleader = ','

" toggle spelling - when invoking an Ex command from a map, `<CR>` is added at the end
nnoremap <leader>s :set invspell<CR>

" insert file contents
nnoremap <leader>day :read ~/.config/nvim/_misc/everyday.txt<CR>

" datetime stamp
inoremap <leader>d <C-R>=strftime("%Y-%m-%dT%H:%M")<CR>
