" setting
"文字コードをUFT-8に設定
set fenc=utf-8
" バックアップファイルを作らない
set nobackup
" スワップファイルを作らない
set noswapfile
" 編集中のファイルが変更されたら自動で読み直す
set autoread
" バッファが編集中でもその他のファイルを開けるように
set hidden
" 入力中のコマンドをステータスに表示する
set showcmd

filetype plugin indent on

" 見た目系
"カラースキーム変更
syntax on
colorscheme molokai
set t_Co=256

" 行番号を表示
set number
" シンタックスハイライトの有効化
syntax enable
" ハイライト無効になる読み込み時間（ms）の設定(デフォルトは2000)
set redrawtime=10000
" 現在の行を強調表示
set cursorline
"highlight CursorLine ctermbg=darkgray guibg=darkgray
" 現在の行を強調表示（縦）
set cursorcolumn
"highlight CursorColumn ctermbg=darkgray guibg=darkgray
" 行末の1文字先までカーソルを移動できるように
set virtualedit=onemore
" インデントはスマートインデント
set smartindent
" ビープ音を可視化
set visualbell
" 括弧入力時の対応する括弧を表示
set showmatch
" ステータスラインを常に表示
set laststatus=2
" コマンドラインの補完
set wildmode=list:longest
" " 折り返し時に表示行単位での移動できるようにする
" nnoremap j gj
" nnoremap k gk


" Tab系
" 不可視文字を可視化(タブが「▸-」と表示される)
set list listchars=tab:\▸\-
" 行頭以外のTab文字の表示幅（スペースいくつ分）
set tabstop=4
" 行頭でのTab文字の表示幅
set shiftwidth=4


" 検索系
" 検索文字列が小文字の場合は大文字小文字を区別なく検索する
set ignorecase
" 検索文字列に大文字が含まれている場合は区別して検索する
set smartcase
" 検索文字列入力時に順次対象文字列にヒットさせる
set incsearch
" 検索時に最後まで行ったら最初に戻る
set wrapscan
" 検索語をハイライト表示
set hlsearch
" ESC連打でハイライト解除
nmap <Esc><Esc> :nohlsearch<CR><Esc>

" Lispファイル
autocmd FileType lisp setlocal expandtab
" Markdownファイル
autocmd FileType markdown setlocal expandtab
" HTMLファイル
autocmd FileType html setlocal expandtab
" CSSファイル
autocmd FileType css setlocal noexpandtab

" キャッシュファイルの保存ディレクトリ
set directory=~/.vim/tmp
set backupdir=~/.vim/tmp
set undodir=~/.vim/tmp

" ファイラー
" netrwは常にtree view
let g:netrw_liststyle = 3
" netrwで行番号を表示
let g:netrw_bufsettings = 'noma nomod nu nobl nowrap ro'

" 以下のエラーに対処するために設定
" - E363: pattern uses more memory than 'maxmempattern'
set mmp=5000

" BSで削除できるものを指定
" indent  : 行頭の空白
" eol     : 改行
" start   : 挿入モード開始位置より手前の文字
set backspace=indent,eol,start

" Foldingの状態を保持する
autocmd BufWritePost * if expand('%') != '' && &buftype !~ 'nofile' | mkview | endif
autocmd BufRead * if expand('%') != '' && &buftype !~ 'nofile' | silent loadview | endif
set viewoptions-=options

" カスタムコマンド定義
" 指定行番号（複数行の場合は 1,3 の形式で指定）の行をMarkdownのURL修飾にする
command! -nargs=1 Murl :<args>s/..*/\<&\>/

" Markdownの完了タスクを検索する
command! -nargs=0 Mc :/\[[^ ]]

" ファイルの内容をクリップボードにコピー
command! -nargs=0 CCp :call s:CopyFileToClipboard()

function! s:CopyFileToClipboard()
  " pbcopyコマンドが利用可能かどうかをチェック
  let l:pbcopy_available = executable('pbcopy')
  " wl-copyコマンドが利用可能かどうかをチェック
  let l:wlcopy_available = executable('wl-copy')
  " clip.exeコマンドが利用可能かどうかをチェック
  let l:clipexe_available = executable('clip.exe')

  " 実行するコマンドを選択
  if l:pbcopy_available
    let l:command = 'cat "%" | pbcopy'
  elseif l:wlcopy_available
    let l:command = 'cat "%" | wl-copy'
  elseif l:clipexe_available
    let l:command = 'cat "%" | iconv -t utf16 | clip.exe'
  else
    let l:command = 'echo "[ERROR] This command requires either the ''pbcopy'', ''wl-copy'', or ''clip.exe'' command to be available."'
  endif

  " コマンドを実行
  execute '!'.l:command
endfunction

" 指定行番号（複数行の場合は 1,3 の形式で指定）の内容をクリップボードにコピー
command! -nargs=+ SCp :call SedCopy(<f-args>)

function! SedCopy(arg)
  " pbcopyコマンドが利用可能かどうかをチェック
  let l:pbcopy_available = executable('pbcopy')
  " wl-copyコマンドが利用可能かどうかをチェック
  let l:wlcopy_available = executable('wl-copy')
  " clip.exeコマンドが利用可能かどうかをチェック
  let l:clipexe_available = executable('clip.exe')

  " 実行するコマンドを選択
  if l:pbcopy_available
    let l:command = "sed -n '" . a:arg . "p' '%' | pbcopy"
  elseif l:wlcopy_available
    let l:command = "sed -n '" . a:arg . "p' '%' | wl-copy"
  elseif l:clipexe_available
    let l:command = "sed -n '" . a:arg . "p' '%' | iconv -t utf16 | clip.exe"
  else
    let l:command = 'echo "[ERROR] This command requires either the ''pbcopy'', ''wl-copy'', or ''clip.exe'' command to be available."'
  endif

  " コマンドを実行
  execute '!'.l:command
endfunction

" 指定行番号（複数行の場合は 1,3 の形式で指定）の内容を標準出力する
command! -nargs=+ Sp :call SedPrint(<f-args>)

function! SedPrint(arg)
  let command = "!sed -n '" . a:arg . "p' %"
  execute command
endfunction

" ファイルのフルパスをクリップボードにコピー
command! -nargs=0 FFp :call FullFilePath()

function! FullFilePath()
  let filePath = expand('%:p')
  " pbcopyコマンドが利用可能かどうかをチェック
  let l:pbcopy_available = executable('pbcopy')
  " wl-copyコマンドが利用可能かどうかをチェック
  let l:wlcopy_available = executable('wl-copy')
  " clip.exeコマンドが利用可能かどうかをチェック
  let l:clipexe_available = executable('clip.exe')

  " 実行するコマンドを選択
  if l:pbcopy_available
    let l:command = 'echo ' . shellescape(filePath) . ' | pbcopy'
  elseif l:wlcopy_available
    let l:command = 'echo ' . shellescape(filePath) . ' | wl-copy'
  elseif l:clipexe_available
    let l:command = 'cat "%" | iconv -t utf16 | clip.exe'
  else
    let l:command = 'echo "[ERROR] This command requires either the ''pbcopy'', ''wl-copy'', or ''clip.exe'' command to be available."'
  endif

  " コマンドを実行
  execute '!'.l:command
endfunction

" Markdown書式のヘッダーをリストアップする
command! -nargs=0 Mh !grep -nh '^\#\#\#*' "%"

" Copilot
let g:copilot_filetypes = {'*': v:true, 'markdown': v:true}

"llama.vim
let g:llama_config = { 'show_info': 0 }
