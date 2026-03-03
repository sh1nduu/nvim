# Neovim Cheatsheet

Leader = `Space`

## Pane (ペイン操作)

| Key | Action |
|---|---|
| `<C-w>h` | 左のペインへ |
| `<C-w>j` | 下のペインへ |
| `<C-w>k` | 上のペインへ |
| `<C-w>l` | 右のペインへ |
| `<C-w>w` | 次のペインへ (循環) |
| `<C-w>v` | 縦分割 |
| `<C-w>s` | 横分割 |
| `<C-w>q` | ペインを閉じる |

## General

| Key | Action |
|---|---|
| `<Leader>v` | init.lua を開く |
| `<Leader>r` | init.lua をリロード |
| `<Leader>t` | 下部にターミナルを開く |
| `<Esc>` (terminal) | ターミナルからノーマルモードに戻る |
| `<Esc><Esc>` | 検索ハイライトを消す |
| `j` / `k` | 折り返し行でも見た目通りに移動 |

## Telescope (検索・ファイル操作)

| Key | Action |
|---|---|
| `<Leader>ff` | ファイル検索 (find_files) |
| `<Leader>fg` | テキスト検索 (live_grep) |
| `<Leader>fb` | ファイルブラウザ (カレントディレクトリ) |
| `<Leader>fr` | 最近使ったファイル (frecency) |
| `q` / `<Esc><Esc>` | Telescope を閉じる (Normal mode) |
| `n` | 新規ファイル作成 (file_browser Normal mode) |

## File Tree / Sidebar

| Key | Action |
|---|---|
| `<Leader>ft` | Neo-tree を開く (ファイルツリー) |
| `<Leader>s` | Sidebar を開閉 |

## LSP (コード操作)

| Key | Action |
|---|---|
| `gd` | 定義へジャンプ |
| `gD` | 宣言へジャンプ |
| `gr` | 参照一覧 |
| `gi` | 実装へジャンプ |
| `K` | ホバー情報を表示 |
| `<C-k>` | シグネチャヘルプ |
| `gf` | コードフォーマット |
| `<Leader>f` | コードフォーマット |
| `<Leader>ca` | コードアクション |
| `<Leader>rn` | リネーム (Lspsaga) |
| `<Leader>D` | 型定義へジャンプ |
| `<Leader>wa` | ワークスペースフォルダ追加 |
| `<Leader>wr` | ワークスペースフォルダ削除 |
| `<Leader>wl` | ワークスペースフォルダ一覧 |

## Diagnostics (エラー表示)

| Key | Action |
|---|---|
| `<Leader>e` | 行のエラー詳細をフロートで表示 |
| `<Leader>q` | エラー一覧 (loclist) |
| `go` | 行のエラー詳細 (Lspsaga) |
| `gj` | 次のエラーへ |
| `gk` | 前のエラーへ |
| `[d` | 前のエラーへ (vim.diagnostic) |
| `]d` | 次のエラーへ (vim.diagnostic) |
| `gx` | コードアクション (Lspsaga) |

## Completion (補完 - nvim-cmp)

| Key | Action |
|---|---|
| `<C-n>` | 次の候補 |
| `<C-p>` | 前の候補 |
| `<CR>` | 候補を確定 |
| `<C-l>` | 補完を手動トリガー |
| `<C-e>` | 補完をキャンセル |
| `<C-b>` / `<C-f>` | ドキュメントをスクロール |

## Test (テスト実行)

| Key | Action |
|---|---|
| `<Leader>tt` | カーソル位置のテストを実行 |
| `<Leader>tf` | 現在のファイルのテストを実行 |
| `<Leader>ts` | テストスイート全体を実行 |
| `<Leader>tl` | 最後のテストを再実行 |

## Cursor Move (カーソル移動)

| Key | Action |
|---|---|
| `f` / `F` / `t` / `T` | Quick-scope でハイライト付きジャンプ |
| `<Leader>h` | Quick-scope のトグル |
| `<Leader>hw` | Hop で単語にジャンプ |
