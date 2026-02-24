---
name: shell_technique
description: 生成AIエージェントが自律的に動作するための非インタラクティブなシェルスクリプトテクニック
tools: ['read', 'search', 'execute', 'web']
agent: beast
---

# シェルテクニックプロンプト

**目的**: 生成AIエージェントがターミナル上で自律的にコマンド実行を行う際に必要な、非インタラクティブ志向のシェルスクリプトテクニック

---

## スキルの定義

このスキルは、生成AIエージェントがターミナル上で自律的にコマンド実行を行う際に必要な、非インタラクティブ志向のシェルスクリプトテクニックを提供します。

**重要な原則**:

- インタラクティブな操作を**絶対に避ける**（ユーザー入力待ち、確認プロンプトなど）
- すべての操作は自動化可能な形で実行
- 出力は必ず一時ファイル経由で確認・検証
- エラーハンドリングを明示的に行う

---

## 1. 一時ファイル管理（mktemp）

### 基本原則

- 一時ファイルは**必ず `mktemp` で作成**
- ハードコードされたパス（`/tmp/myfile.txt` など）は**禁止**
- スクリプト終了時にクリーンアップを確実に実行

### コマンド例

```bash
# 一時ファイルを作成
tmpfile=$(mktemp)
echo "Data" > "$tmpfile"

# 一時ディレクトリを作成
tmpdir=$(mktemp -d)
cd "$tmpdir"

# 注意: 一時ファイルは明示的に削除せず、OSのクリーンアップに任せる
# または、同じ一時ファイルを上書きして再利用する

# 複数の一時ファイル（再利用する場合は上書き）
tmpfile1=$(mktemp)
tmpfile2=$(mktemp)
echo "New data" > "$tmpfile1"  # 上書きして再利用
```

### ベストプラクティス

- テンプレート付き: `mktemp /tmp/myapp.XXXXXX`（6つ以上のX）
- サフィックス付き: `mktemp --suffix=.json`（拡張子が必要な場合）
- 一時ディレクトリ: `mktemp -d`（複数ファイルを扱う場合）

---

## 2. 出力の分岐（tee）

### 基本原則

- 長い処理の出力は**一時ファイルに保存しながら**標準出力にも表示
- パイプラインの途中結果を保存する際に使用
- ログ記録と同時に処理を続行したい場合に有効

### コマンド例

```bash
# 一時ファイルに出力しながら標準出力にも表示
tmpfile=$(mktemp)
command | tee "$tmpfile"
# この時点で $tmpfile に結果が保存され、画面にも表示されている

# 複数の出力先（標準出力 + 2つのファイル）
command | tee file1.log file2.log

# 追記モード
command | tee -a existing.log

# 標準出力を抑制したい場合は一時ファイルに保存後、別の一時ファイルで処理
# （注: /dev/null は禁止のため、空の一時ファイルに出力）
tmpout=$(mktemp)
command | tee "$tmpfile" > "$tmpout"
```

### パイプラインでの活用

```bash
tmpfile=$(mktemp)

# パイプラインの途中結果を保存
cat data.txt | tee "$tmpfile"
tmpcount=$(mktemp)
wc -l < "$tmpfile" > "$tmpcount"

# 後で $tmpfile の内容を確認・検証
head -n 5 "$tmpfile"
```

---

## 3. 出力の確認・検証（head/tail/sed/wc）

### 基本原則

- 大量の出力は**一時ファイルに保存してから**確認
- 画面に直接大量のデータを表示しない（トークン消費を避ける）
- `head`/`tail` で範囲を絞ってから確認

### コマンド例

```bash
tmpfile=$(mktemp)

# 大量の出力を一時ファイルに保存
find /large/directory -type f > "$tmpfile"

# 最初の10行を確認
head -n 10 "$tmpfile"

# 最後の10行を確認
tail -n 10 "$tmpfile"

# 特定の行範囲を確認（11行目から20行目）
sed -n '11,20p' "$tmpfile"

# 行数をカウント
wc -l "$tmpfile"

# 特定のパターンを含む行のみ抽出
grep "pattern" "$tmpfile" | head -n 20
```

### 検証フロー例

```bash
tmpfile=$(mktemp)

# ステップ1: 全データを一時ファイルに保存
git log --oneline --all > "$tmpfile"

# ステップ2: 件数確認
echo "Total commits: $(wc -l < "$tmpfile")"

# ステップ3: 最新10件を表示
echo "Latest 10 commits:"
head -n 10 "$tmpfile"

# ステップ4: 特定パターンの有無確認
if grep -q "feat:" "$tmpfile"; then
    echo "Found feature commits"
    grep "feat:" "$tmpfile" | head -n 5
fi
```

---

## 4. 非インタラクティブ化テクニック

### 確認プロンプトの回避

```bash
# ファイル操作は上書きモードで実行（削除は避ける）
# 削除が必要な場合は明示的な確認を取る

# cp の上書き確認を避ける
cp -f source.txt dest.txt

# mv の上書き確認を避ける（名前変更・移動）
mv -f old.txt new.txt

# yes コマンドで自動的に "y" を入力
yes | command_that_asks_confirmation

# あるいは -y オプションを使う（コマンドによる）
apt-get install -y package
```

### バックグラウンド実行の管理

```bash
# バックグラウンドで実行（ただしログを一時ファイルに保存）
tmplog=$(mktemp)
tmperr=$(mktemp)
long_running_command > "$tmplog" 2> "$tmperr" &
pid=$!

# 実行中の確認
if kill -0 "$pid" 2> "$tmperr"; then
    echo "Process is running (PID: $pid)"
fi

# 完了待ち
wait "$pid"
exit_code=$?

# ログ確認
head -n 20 "$tmplog"
```

---

## 5. パイプラインとリダイレクト

### ストリーム処理の最適化

```bash
# 複数の処理を一度に実行（find では -exec を使わない）
# xargsも避け、whileループで処理
tmpfile=$(mktemp)
find . -name "*.txt" > "$tmpfile"
while IFS= read -r file; do
    wc -l "$file"
done < "$tmpfile"

# 大量ファイルの一括処理（並列処理が必要な場合はGNU parallelを検討）
tmpfile=$(mktemp)
find . -name "*.log" > "$tmpfile"
while IFS= read -r file; do
    gzip "$file"
done < "$tmpfile"

# エラー出力も一時ファイルに保存
tmpout=$(mktemp)
tmperr=$(mktemp)
trap 'rm -f "$tmpout" "$tmperr"' EXIT

command > "$tmpout" 2> "$tmperr"

if [ -s "$tmperr" ]; then
    echo "Errors occurred:"
    head -n 20 "$tmperr"
fi
```

### 標準出力と標準エラー出力の分離

```bash
tmpout=$(mktemp)
tmperr=$(mktemp)

# 標準出力と標準エラー出力を別ファイルに保存
command > "$tmpout" 2> "$tmperr"

# 両方の件数を確認
echo "stdout lines: $(wc -l < "$tmpout")"
echo "stderr lines: $(wc -l < "$tmperr")"

# エラーがあれば最初の10行を表示
if [ -s "$tmperr" ]; then
    echo "First 10 errors:"
    head -n 10 "$tmperr"
fi
```

---

## 6. 条件分岐とエラーハンドリング

### 非インタラクティブな条件判定

```bash
# ファイル存在チェック
if [ -f "file.txt" ]; then
    echo "File exists"
else
    echo "File does not exist"
fi

# コマンド成功判定
tmpcheck=$(mktemp)
if type git > "$tmpcheck" 2>&1; then
    echo "git is installed"
fi

# 終了コードによる分岐
tmpfile=$(mktemp)
if grep "pattern" file.txt > "$tmpfile" 2>&1; then
    echo "Pattern found: $(wc -l < "$tmpfile") matches"
else
    echo "Pattern not found"
fi
```

### set によるエラーハンドリング

```bash
# エラー発生時に即座にスクリプトを終了
set -e

# 未定義変数の使用をエラーとする
set -u

# パイプラインの途中でエラーが起きても検知
set -o pipefail

# 組み合わせ（推奨）
set -euo pipefail

# 特定の箇所だけエラーを無視
set +e
command_that_may_fail
exit_code=$?
set -e

if [ $exit_code -ne 0 ]; then
    echo "Command failed with code $exit_code"
fi
```

---

## 7. ループ処理（自律動作向け）

### while read ループ

```bash
tmpfile=$(mktemp)

# ファイルリストを一時ファイルに保存
find . -name "*.txt" > "$tmpfile"

# 1行ずつ処理
while IFS= read -r file; do
    echo "Processing: $file"
    # 各ファイルに対する処理
    wc -l "$file"
done < "$tmpfile"
```

### for ループ（配列経由）

```bash
# find の結果を配列に格納（ファイル名にスペースが含まれる場合に安全）
tmpfile=$(mktemp)
find . -name "*.txt" -print0 > "$tmpfile"

while IFS= read -r -d '' file; do
    echo "Processing: $file"
done < "$tmpfile"
```

---

## 8. 並列処理（注意）

### 基本的なループ処理

```bash
# xargsは意図しないコマンド実行のリスクがあるため避ける
# 代わりにwhileループで順次処理
tmpfile=$(mktemp)
find . -name "*.txt" > "$tmpfile"
while IFS= read -r file; do
    wc -l "$file" > "${file}.count"
done < "$tmpfile"

# 並列処理が必要な場合はGNU parallelの使用を検討
# ただし、コマンド構築には十分注意すること
```

---

## 9. JSON/YAML処理（安全な方法）

### Python を使った JSON 処理（推奨）

```bash
# jqはチューリング完全なため、生成AIが使用すると意図しない処理のリスクあり
# 代わりにPythonの標準ライブラリを使用（明示的なスクリプトで制御可能）

tmpfile=$(mktemp --suffix=.json)

# JSONファイルから特定のキーを抽出
python3 -c '
import json
with open("'"$tmpfile"'", "r") as f:
    data = json.load(f)
    for item in data.get("items", []):
        if item.get("status") == "active":
            print(json.dumps(item))
' > filtered.json

# 配列の長さを確認
python3 -c '
import json
with open("'"$tmpfile"'", "r") as f:
    data = json.load(f)
    print("Total items:", len(data))
'
```

### grep/sed による限定的な抽出（キー名が明確な場合）

```bash
# シンプルなキー抽出（JSON構造が単純な場合のみ）
grep '"name"' data.json > names.txt

# sedでキー値を抽出（ただし複雑なJSONには不向き）
sed -n 's/.*"id": *"\([^"]*\)".*/\1/p' data.json
```

---

## 10. Git 操作（非インタラクティブ）

### 自動化向け Git コマンド

```bash
# ページャーを無効化（インタラクティブ表示を回避）
git --no-pager log --oneline -n 20

# 一時ファイルに保存してから確認
tmpfile=$(mktemp)
git --no-pager diff > "$tmpfile"
head -n 50 "$tmpfile"

# 変更のあるファイル一覧
git --no-pager diff --name-only

# コミットメッセージをファイル経由で指定
echo "feat: add new feature" > /tmp/commit-msg.txt
git commit -F /tmp/commit-msg.txt
```

---

## 11. その他の有用テクニック

### コマンド存在確認

```bash
# コマンドが利用可能か確認
tmpcheck=$(mktemp)
if type jq > "$tmpcheck" 2>&1; then
    echo "jq is available"
else
    echo "jq is not installed"
    exit 1
fi
```

### プロセス置換

```bash
# 2つのコマンドの出力を比較
diff <(ls dir1) <(ls dir2)

# 複数のソースから集約
cat <(echo "Source 1") <(echo "Source 2") > combined.txt
```

### Here-document（非インタラクティブな複数行入力）

```bash
# 複数行のデータを一時ファイルに書き込む
tmpfile=$(mktemp)
cat > "$tmpfile" <<'EOF'
Line 1
Line 2
Line 3
EOF

# ここで $tmpfile を使った処理を実行
head "$tmpfile"
```

---

## 12. デバッグ・トレース

### スクリプトのトレース

```bash
# コマンドを実行前に表示
set -x

# トレースを一時的に無効化
set +x

# 関数単位でトレース
debug_function() {
    set -x
    # デバッグしたいコマンド
    set +x
}
```

### ドライラン（実行せず表示のみ）

```bash
# find の結果を確認してから実行
tmpfile=$(mktemp)
find . -name "*.bak" > "$tmpfile"
echo "Will delete $(wc -l < "$tmpfile") files"
head -n 10 "$tmpfile"

# 確認後に実行
while IFS= read -r file; do
    rm -f "$file"
done < "$tmpfile"
```

---

## 13. パフォーマンス最適化

### 大量データの効率的処理

```bash
# 行数だけカウント（全行読み込まない）
wc -l < large_file.txt

# 最初のN行だけ処理（パイプではなくファイル経由）
tmpfile=$(mktemp)
head -n 1000 large_file.txt > "$tmpfile"
grep "pattern" "$tmpfile"

# ディスク容量を節約（圧縮しながら保存）
command | gzip > output.gz

# 後で解凍して確認
zcat output.gz | head -n 20
```

---

## 適用ガイドライン

### このスキルを使うべき場面

- ターミナルでコマンドを実行する際
- 大量の出力を扱う場合
- 複数ステップの処理で途中結果を保存・検証したい場合
- バックグラウンド処理を管理する場合

### 避けるべきパターン

- ❌ ハードコードされた `/tmp/myfile.txt` などのパス
- ❌ `cat large_file.txt` のような大量出力の直接表示
- ❌ `rm -i`、`mv -i` などのインタラクティブオプション
- ❌ `less`、`more`、`vim` などの対話的ツール
- ❌ `find ... -exec` の使用（xargsを優先）

### 推奨パターン

- ✅ `mktemp` で一時ファイルを作成
- ✅ `tee` で保存と表示を同時実行
- ✅ `head`/`tail` で出力を制限してから確認
- ✅ `set -euo pipefail` でエラーハンドリング
- ✅ `trap` でクリーンアップを確実に実行
- ✅ `find ... -print0 | xargs -0` で安全なファイル処理

---

## 関連プロンプト

- [Git操作](git_operations.prompt.md): Git コマンドの非インタラクティブ実行
- [調査](research.prompt.md): 調査時のコマンド活用
- [調査・確認](investigation_check.prompt.md): 調査結果の確認・検証

---

## 参考情報

- [GNU Coreutils Manual - mktemp](https://www.gnu.org/software/coreutils/manual/html_node/mktemp-invocation.html)
- [GNU Coreutils Manual - tee](https://www.gnu.org/software/coreutils/manual/html_node/tee-invocation.html)
- [Bash Reference Manual - Shell Commands](https://www.gnu.org/software/bash/manual/html_node/Shell-Commands.html)
