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


" 見た目系
" 行番号を表示
set number
" 現在の行を強調表示
set cursorline
" 現在の行を強調表示（縦）
set cursorcolumn
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
" シンタックスハイライトの有効化
syntax enable


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

"カラースキーム変更
syntax on
colorscheme molokai
set t_Co=256

" Lispファイル
autocmd FileType lisp setlocal expandtab
" Markdownファイル
autocmd FileType markdown setlocal expandtab
" HTMLファイル
autocmd FileType html setlocal expandtab
" CSSファイル
autocmd FileType css setlocal noexpandtab

syntax on
colorscheme molokai
set t_Co=256

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
