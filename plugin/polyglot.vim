" =============================================================================
" Description: Count makeup of a project and display the results on
"               a scratch buffer.
" File: polyglot.vim
" Author: Vanessa McHale <vamchale@gmail.com>
" Version: 0.1.0
if exists('g:__POLYGLOT_VIM__')
    finish
endif
let g:__POLYGLOT_VIM__ = 1

let g:polyglot_buf_name = 'Polyglot'

if !exists('g:polyglot_buf_size')
    let g:polyglot_buf_size = 13
endif

" Mark a buffer as scratch
function! s:ScratchMarkBuffer()
    setlocal buftype=nofile
    setlocal bufhidden=wipe
    setlocal noswapfile
    setlocal buflisted
    setlocal nonumber
    setlocal statusline=%F
    setlocal nofoldenable
    setlocal foldcolumn=0
    setlocal wrap
    setlocal linebreak
    setlocal nolist
endfunction

" Return the number of visual lines in the buffer
fun! s:CountVisualLines()
    let initcursor = getpos('.')
    call cursor(1,1)
    let i = 0
    let previouspos = [-1,-1,-1,-1]
    " keep moving cursor down one visual line until it stops moving position
    while previouspos != getpos('.')
        let i += 1
        " store current cursor position BEFORE moving cursor
        let previouspos = getpos('.')
        normal! gj
    endwhile
    " restore cursor position
    call setpos('.', initcursor)
    return i
endfunction

fun! s:PolyglotGotoWin() "{{{
    let bufnum = bufnr( g:polyglot_buf_name )
    if bufnum >= 0
        let win_num = bufwinnr( bufnum )
        " Will return negative for already deleted window
        exe win_num . 'wincmd w'
        return 0
    endif
    return -1
endfunction "}}}

" Close polyglot Buffer
fun! PolyglotClose() "{{{
    let last_buffer = bufnr('%')
    if s:PolyglotGotoWin() >= 0
        close
    endif
    let win_num = bufwinnr( last_buffer )
    exe win_num . 'wincmd w'
endfunction "}}}

" Open a scratch buffer or reuse the previous one
fun! PolyglotGet() "{{{
    let last_buffer = bufnr('%')

    if s:PolyglotGotoWin() < 0
        new
        exe 'file ' . g:polyglot_buf_name
        setl modifiable
    else
        setl modifiable
        execute 'normal! ggVGd'
    endif

    call s:ScratchMarkBuffer()

    execute '.!polyglot | ac -s'
    setl nomodifiable
    
    let size = s:CountVisualLines()

    if size > g:polyglot_buf_size
        let size = g:polyglot_buf_size
    endif

    execute 'resize ' . size

    nnoremap <silent> <buffer> q <esc>:close<cr>

endfunction "}}}

command! Polyglot call PolyglotGet()

nmap <silent> co :Polyglot<CR>
