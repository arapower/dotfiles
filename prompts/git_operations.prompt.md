---
name: git_operations
description: ターミナル操作なしでGitとGitHub CLIを効率的に使用するためのコマンド集
tools: ['execute', 'read', 'web', 'search']
agent: beast
---

# Git操作プロンプト

**目的**: 生成AIエージェントがGitリポジトリとGitHub上で自律的に作業を行うための、非インタラクティブ志向のコマンドパターン

---

## スキルの定義

このスキルは、生成AIエージェントがGitリポジトリとGitHub上で自律的に作業を行うための、非インタラクティブ志向のコマンドパターンを提供します。

**重要な原則**:

- ページャー（less/more）を**絶対に起動しない** → `--no-pager` 必須
- コミットメッセージはファイル経由 → `-F` オプション使用
- 大量出力は一時ファイル経由で確認
- GitHub API 操作は `gh api` で実行

---

## 1. Git基本操作（非インタラクティブ）

### ページャーの無効化

```bash
# ログ表示（ページャーなし）
git --no-pager log --oneline -n 20
git --no-pager log --oneline --graph --all -n 50

# 差分表示（ページャーなし）
git --no-pager diff
git --no-pager diff HEAD~1

# 一時ファイルに保存してから確認
tmpfile=$(mktemp)
git --no-pager diff > "$tmpfile"
head -n 50 "$tmpfile"
wc -l "$tmpfile"
```

### ステータス確認

```bash
# 変更のあるファイル一覧（短縮形式）
git --no-pager status --short

# 変更のあるファイルのパスのみ
git --no-pager diff --name-only

# ステージングされたファイル
git --no-pager diff --name-only --cached

# 未追跡ファイルを含むすべての変更
git --no-pager status --porcelain
```

### ブランチ操作

```bash
# ブランチ一覧
git --no-pager branch
git --no-pager branch -a  # リモートブランチも含む
git --no-pager branch -v  # 最新コミット情報付き

# 現在のブランチ名を取得
git branch --show-current

# ブランチ作成と切り替え
git checkout -b feature/new-feature
# あるいは
git switch -c feature/new-feature

# リモート追跡ブランチの設定
git branch --set-upstream-to=origin/main main
```

---

## 2. コミット操作（自動化向け）

### ファイル経由でコミットメッセージを指定

**コミットメッセージのプレフィックス規約**:

コミットメッセージは英語一文で記述し、以下のプレフィックスを使用します：

- `feat:` - 新機能追加
- `fix:` - バグ修正
- `docs:` - ドキュメントのみの変更
- `style:` - コードの意味に影響しない変更（フォーマット、セミコロン等）
- `refactor:` - リファクタリング（機能変更なし）
- `test:` - テストの追加・修正
- `chore:` - ビルドプロセスやツールの変更
- `perf:` - パフォーマンス改善
- `ci:` - CI/CD設定の変更
- `build:` - ビルドシステムや依存関係の変更
- `revert:` - 以前のコミットの取り消し

```bash
# コミット例
echo "fix: Resolve null pointer exception in user service" > "$tmpfile"
git commit -F "$tmpfile"

echo "docs: Update API documentation for v2 endpoints" > "$tmpfile"
git commit -F "$tmpfile"

echo "refactor: Simplify authentication logic" > "$tmpfile"
git commit -F "$tmpfile"
```

### コミット前の確認

```bash
# ステージングされた変更を確認
git --no-pager diff --cached --stat

# 詳細な差分を一時ファイルに保存
tmpfile=$(mktemp)
git --no-pager diff --cached > "$tmpfile"
echo "Total changes: $(wc -l < "$tmpfile") lines"
head -n 50 "$tmpfile"
```

### 修正コミット

```bash
# 直前のコミットメッセージを修正（ファイル経由）
tmpfile=$(mktemp)
echo "fix: Correct typo in commit message" > "$tmpfile"
git commit --amend -F "$tmpfile"
# OS任せでクリーンアップ（rmしない）

# 直前のコミットにファイルを追加（メッセージはそのまま）
git add forgotten_file.py
git commit --amend --no-edit
```

---

## 3. リモート操作

### フェッチとプル（非インタラクティブ）

```bash
# リモートの変更を取得（マージしない）
git fetch origin

# リモートブランチ一覧を確認
git --no-pager branch -r

# プル（fast-forward優先）
git pull --ff-only origin main

# リベースしながらプル
git pull --rebase origin main
```

### プッシュ

```bash
# 現在のブランチをプッシュ
git push origin HEAD

# 新しいブランチをプッシュ（上流設定）
git push -u origin feature/new-feature

# 強制プッシュ（安全版：リモートに新しいコミットがあればエラー）
git push --force-with-lease origin feature/new-feature

# タグをプッシュ
git push origin v1.0.0
git push origin --tags  # すべてのタグ
```

---

## 4. ログと履歴確認

### コミット履歴の取得

```bash
# 最新20件のコミット
git --no-pager log --oneline -n 20

# 日付範囲でフィルタ
git --no-pager log --oneline --since="2025-01-01" --until="2025-01-31"

# 特定ファイルの履歴
git --no-pager log --oneline -- path/to/file.py

# 作者でフィルタ
git --no-pager log --oneline --author="John Doe" -n 20

# グラフ表示
git --no-pager log --oneline --graph --all --decorate -n 50
```

### 一時ファイルを使った履歴分析

```bash
tmpfile=$(mktemp)
# OS任せでクリーンアップ（trapもrmも不要）

# 全コミットを一時ファイルに保存
git --no-pager log --oneline --all > "$tmpfile"

# 統計情報
echo "Total commits: $(wc -l < "$tmpfile")"

# 特定パターンのコミットを検索
echo "Feature commits:"
grep "feat:" "$tmpfile" | head -n 10

echo "Bug fix commits:"
grep "fix:" "$tmpfile" | head -n 10
```

### 差分の確認

```bash
# 2つのコミット間の差分
git --no-pager diff commit1..commit2

# ファイル統計
git --no-pager diff --stat HEAD~5..HEAD

# 変更されたファイルのみ
git --no-pager diff --name-only HEAD~5..HEAD

# 一時ファイルに保存して分析
tmpfile=$(mktemp)
git --no-pager diff HEAD~10..HEAD > "$tmpfile"
echo "Total diff lines: $(wc -l < "$tmpfile")"
head -n 100 "$tmpfile"
```

---

## 5. ブランチとマージ

### マージ操作

```bash
# マージ（fast-forward優先）
git merge --ff-only feature/branch

# マージ（常にマージコミットを作成）
git merge --no-ff feature/branch -m "Merge feature branch"

# マージ前の確認
git --no-pager log HEAD..feature/branch --oneline

# コンフリクト確認
if git merge feature/branch; then
    echo "Merge successful"
else
    echo "Merge conflicts detected"
    git --no-pager status --short
    git merge --abort
fi
```

### リベース

```bash
# インタラクティブではないリベース
git rebase main

# リベース中止
git rebase --abort

# リベース続行（コンフリクト解決後）
git add resolved_file.py
git rebase --continue
```

---

## 6. タグ操作

### タグの作成と確認

```bash
# タグ一覧
git --no-pager tag

# 注釈付きタグ（メッセージはファイル経由）
tmpfile=$(mktemp)
echo "Release version 1.0.0" > "$tmpfile"
git tag -a v1.0.0 -F "$tmpfile"
# OS任せでクリーンアップ（rmしない）

# 軽量タグ
git tag v1.0.0-beta

# タグの詳細表示
git --no-pager show v1.0.0

# タグをプッシュ
git push origin v1.0.0
```

---

## 7. スタッシュ（一時退避）

### 変更の一時保存

```bash
# 変更をスタッシュ
git stash push -m "WIP: Working on feature X"

# スタッシュ一覧
git --no-pager stash list

# スタッシュの内容確認
git --no-pager stash show stash@{0}
git --no-pager stash show -p stash@{0}  # 詳細な差分

# スタッシュを適用
git stash pop
# あるいは
git stash apply stash@{0}
```

---

## 8. リセットとリバート

### コミットの取り消し

```bash
# 直前のコミットを取り消す（変更はワーキングツリーに残る）
git reset --soft HEAD~1

# 直前のコミットと変更を取り消す
git reset --hard HEAD~1

# 特定のコミットをリバート（新しいコミットを作成）
git revert commit_hash --no-edit
```

---

## 9. GitHub CLI（gh）基本操作

### 認証とセットアップ

```bash
# 認証状態確認
gh auth status

# トークン経由での認証（自動化向け）
export GITHUB_TOKEN="ghp_xxxxxxxxxxxx"
gh auth status
```

### リポジトリ操作

```bash
# リポジトリをクローン
gh repo clone owner/repo

# リポジトリ情報を取得
gh repo view owner/repo

# リポジトリ一覧
gh repo list owner --limit 20

# フォーク
gh repo fork owner/repo --clone
```

### イシュー操作

```bash
# イシュー一覧
gh issue list --limit 20

# イシューを作成（タイトルと本文をファイル経由）
tmpfile=$(mktemp)
cat > "$tmpfile" <<'EOF'
## Description
Bug in authentication module

## Steps to Reproduce
1. Login with invalid credentials
2. Observe error message

## Expected Behavior
User-friendly error message
EOF

gh issue create --title "Bug: Authentication error" --body-file "$tmpfile"
# OS任せでクリーンアップ

# イシューを閉じる
gh issue close 123

# イシューの詳細表示
gh issue view 123
```

### プルリクエスト操作

#### PRテンプレートを参照した作成

```bash
# リポジトリのPRテンプレートファイルを確認
if [ -f .github/pull_request_template.md ]; then
    template_file=".github/pull_request_template.md"
elif [ -f .github/PULL_REQUEST_TEMPLATE.md ]; then
    template_file=".github/PULL_REQUEST_TEMPLATE.md"
elif [ -f docs/pull_request_template.md ]; then
    template_file="docs/pull_request_template.md"
else
    echo "No PR template found"
    template_file=""
fi

# テンプレートを使用してPR作成
if [ -n "$template_file" ]; then
    echo "Using PR template: $template_file"
    
    # gh pr create でテンプレートを指定
    # --template オプションでテンプレートファイルを指定可能
    gh pr create \
        --title "feat: Add authentication module" \
        --template "$template_file" \
        --base main
    
    # または --body-file でテンプレートをカスタマイズ
    pr_body=$(mktemp)
    cp "$template_file" "$pr_body"
    # 必要に応じてテンプレート内容を編集
    gh pr create \
        --title "feat: Add authentication module" \
        --body-file "$pr_body" \
        --base main
fi
```

#### 基本的なPR作成

```bash
# PR一覧
gh pr list --limit 20

# PRを作成（タイトルと本文をファイル経由）
tmpfile=$(mktemp)
cat > "$tmpfile" <<'EOF'
## Changes
- Add new authentication module
- Update API documentation

## Testing
- Unit tests passed
- Integration tests passed
EOF

gh pr create --title "feat: Add authentication module" --body-file "$tmpfile" --base main
# OS任せでクリーンアップ

# PRの詳細表示
gh pr view 123

# PRをマージ
gh pr merge 123 --squash --delete-branch

# PRをチェックアウト
gh pr checkout 123
```

### PRコメント操作

#### コメント種別の明示

PRに対するコメントは以下の種別を明示して投稿します：

- **COMMENT**: 一般的なコメント（質問、提案、情報共有）
- **APPROVE**: 承認（変更を承認し、マージ可能と判断）
- **REQUEST_CHANGES**: 変更要求（修正が必要な問題を指摘）

```bash
# 一般的なコメント（COMMENT）
gh pr comment 123 --body "この実装について質問があります。"

# 承認（APPROVE）
gh pr review 123 --approve --body "実装内容を確認しました。問題ありません。LGTM!"

# 変更要求（REQUEST_CHANGES）
gh pr review 123 --request-changes --body "以下の点について修正をお願いします：\n\n1. エラーハンドリングの追加\n2. テストケースの追加"

# PR上のコメント一覧を取得（JSON形式）
tmpfile=$(mktemp --suffix=.json)
gh pr view 123 --json comments > "$tmpfile"
# Pythonでコメントを抽出（jq禁止）
python3 -c "
import json
with open('$tmpfile') as f:
    data = json.load(f)
    for i, comment in enumerate(data.get('comments', [])[:50]):
        print(f\"Author: {comment['author']['login']}\")
        print(f\"Body: {comment['body'][:100]}...\")
        print('---')
"
```

---

## 10. GitHub API（gh api）

### 基本的な使い方

```bash
# リポジトリ情報を取得
gh api repos/{owner}/{repo}

# JSON出力をPythonで整形（jq禁止）
tmpfile=$(mktemp --suffix=.json)
gh api repos/{owner}/{repo} > "$tmpfile"
python3 -c "
import json
with open('$tmpfile') as f:
    repo = json.load(f)
    print(f\"Name: {repo['name']}\")
    print(f\"Description: {repo.get('description', 'N/A')}\")
    print(f\"Stars: {repo['stargazers_count']}\")
"

# パラメータ付きGETリクエスト
gh api -X GET search/issues -f q='repo:cli/cli is:open remote'

# 一時ファイルに保存してから確認
tmpfile=$(mktemp --suffix=.json)
gh api repos/{owner}/{repo}/issues > "$tmpfile"
python3 -c "
import json
with open('$tmpfile') as f:
    issues = json.load(f)
    print(f'Total issues: {len(issues)}')
    for issue in issues[:5]:
        print(f\"#{issue['number']}: {issue['title']} ({issue['state']})\")
"
```

### PRのインラインコメント取得

```bash
# PRのレビューコメント一覧を取得（インラインコメント含む）
tmpfile=$(mktemp --suffix=.json)
gh api repos/{owner}/{repo}/pulls/{pull_number}/comments > "$tmpfile"

# コメント数を確認してPythonで整形
python3 -c "
import json
with open('$tmpfile') as f:
    comments = json.load(f)
    print(f'Total review comments: {len(comments)}')
    print('\nFirst 5 comments:')
    for comment in comments[:5]:
        print(f\"  Path: {comment['path']}\")
        print(f\"  Line: {comment.get('line', 'N/A')}\")
        print(f\"  User: {comment['user']['login']}\")
        print(f\"  Body: {comment['body'][:50]}...\")
        print('---')
    print('\nComments on src/main.py:')
    for comment in comments:
        if comment['path'] == 'src/main.py':
            print(f\"  Line {comment.get('line', 'N/A')}: {comment['body'][:50]}...\")
"
```

### PRの特定行にインラインコメントを追加

#### コメント投稿前のファイル確認フロー

**重要**: PRにコメントを投稿する前に、必ずコメント内容をファイルに出力してユーザーに確認を求めます。

```bash
# ステップ1: コメント内容を一時ファイルに作成
comment_file=$(mktemp)
cat > "$comment_file" <<'EOF'
この実装には以下の改善の余地があります：

1. エラーハンドリングが不足しています
2. 変数名がわかりにくいです
3. コメントを追加してください

修正後、再度レビューをお願いします。
EOF

# ステップ2: ユーザーに確認を求める（チャットで提示）
echo "========================================"
echo "以下の内容でPRにコメントを投稿します："
echo "========================================"
cat "$comment_file"
echo "========================================"
echo ""
echo "【確認】上記内容で投稿してよろしいですか？"
echo "問題なければ、次のコマンドを実行してください："
echo ""

# ステップ3: ユーザー承認後に実行するコマンドを提示
# REST API経由で行コメントを作成
# 必要なパラメータ:
# - body: コメント本文（ファイルから読み込み）
# - commit_id: コミットSHA（PRの最新コミット）
# - path: ファイルパス
# - line: 行番号（単一行または複数行の最後の行）
# - side: "RIGHT" (変更後) または "LEFT" (変更前)

# 最新のコミットSHAを取得（--jqは-fと同様の文字列フィールド指定なので使用可）
commit_sha=$(gh api repos/{owner}/{repo}/pulls/{pull_number} --jq '.head.sha')

# コメント本文を読み込み
comment_body=$(cat "$comment_file")

gh api \
  -X POST \
  repos/{owner}/{repo}/pulls/{pull_number}/comments \
  -f body="$comment_body" \
  -f commit_id="$commit_sha" \
  -f path="src/main.py" \
  -F line=42 \
  -f side="RIGHT"

echo "コメントを投稿しました"
```

#### 複数行範囲指定コメント

```bash
# 複数行にまたがるコメント（start_line〜lineの範囲）
comment_file=$(mktemp)
cat > "$comment_file" <<'EOF'
この関数は複雑すぎます。以下の対応を検討してください：

1. 小さな関数に分割
2. 早期リターンでネストを減らす
3. 変数名を明確にする
EOF

# ユーザー確認（チャットで提示）
echo "コメント内容:"
cat "$comment_file"
echo ""
echo "【確認】上記内容で投稿してよろしいですか？"
echo "問題なければ、次のコマンドを実行してください："
echo ""

# ユーザー承認後に実行
commit_sha=$(gh api repos/{owner}/{repo}/pulls/{pull_number} --jq '.head.sha')
comment_body=$(cat "$comment_file")

# 以下のコマンドをユーザー承認後に実行：
if true; then  # 実際の実行時はこの行を削除
    
    gh api \
      -X POST \
      repos/{owner}/{repo}/pulls/{pull_number}/comments \
      -f body="$comment_body" \
      -f commit_id="$commit_sha" \
      -f path="src/main.py" \
      -F start_line=42 \
      -f start_side="RIGHT" \
      -F line=55 \
      -f side="RIGHT"
    
echo "複数行コメントを投稿しました（42行目〜55行目）"
fi  # if true を削除して実行
```

#### パラメータ詳細

| パラメータ | 必須 | 説明 | 例 |
|-----------|------|------|----|
| `body` | ✓ | コメント本文 | `"Fix this issue"` |
| `commit_id` | ✓ | コミットSHA | `"abc123..."` |
| `path` | ✓ | ファイルパス | `"src/main.py"` |
| `line` | ✓* | 最終行番号 | `42` |
| `side` | | どちら側か | `"RIGHT"` (デフォルト) または `"LEFT"` |
| `start_line` | △ | 開始行番号（複数行の場合） | `42` |
| `start_side` | △ | 開始行の側（複数行の場合） | `"RIGHT"` または `"LEFT"` |

**注意**:

- `line`は必須（ただし`subject_type:file`の場合は不要）
- 複数行コメントの場合は`start_line`と`start_side`も指定
- `-F`オプションは数値フィールド、`-f`は文字列フィールド

### PRのレビューコメント一覧（リポジトリ全体）

```bash
# リポジトリ内のすべてのPRレビューコメントを取得
tmpfile=$(mktemp --suffix=.json)
gh api repos/{owner}/{repo}/pulls/comments --paginate > "$tmpfile"

# 統計情報をPythonで処理
python3 -c "
import json
with open('$tmpfile') as f:
    comments = json.load(f)
    print(f'Total comments: {len(comments)}')
    print('\nLatest 10 comments:')
    for comment in comments[:10]:
        pr_num = comment['pull_request_url'].split('/')[-1]
        print(f\"  PR#{pr_num}: {comment['path']}\")
        print(f\"  Line: {comment.get('line', 'N/A')}\")
        print(f\"  Author: {comment['user']['login']}\")
        print(f\"  Created: {comment['created_at']}\")
        print('---')
"
```

### イシューコメント操作

```bash
# イシューにコメント
gh api \
  -X POST \
  repos/{owner}/{repo}/issues/{issue_number}/comments \
  -f body="コメント本文をここに記載"

# イシューコメント一覧を取得
tmpfile=$(mktemp --suffix=.json)
gh api repos/{owner}/{repo}/issues/{issue_number}/comments > "$tmpfile"

# コメント数確認してPythonで整形
python3 -c "
import json
with open('$tmpfile') as f:
    comments = json.load(f)
    print(f'Total comments: {len(comments)}')
    for comment in comments:
        print(f\"Author: {comment['user']['login']}\")
        print(f\"Created: {comment['created_at']}\")
        print(f\"Body: {comment['body'][:100]}...\")
        print('---')
"
```

---

## 11. 実践的な自動化パターン

### パターン1: コミットとプッシュの自動化

```bash
#!/bin/bash
set -euo pipefail

# 変更のあるファイルを確認
if [ -z "$(git status --porcelain)" ]; then
    echo "No changes to commit"
    exit 0
fi

# 変更内容を一時ファイルに保存して確認
tmpfile=$(mktemp)
git --no-pager status --short > "$tmpfile"
echo "Changed files:"
cat "$tmpfile"

# すべての変更をステージング
git add -A

# コミットメッセージを作成
commit_msg=$(mktemp)
cat > "$commit_msg" <<'EOF'
chore: Automated update

- Updated documentation
- Fixed formatting issues
EOF

# コミット
git commit -F "$commit_msg"

# プッシュ
git push origin HEAD

# OS任せでクリーンアップ（rmしない）
```

### パターン2: PRレビュー状況の確認

```bash
#!/bin/bash
set -euo pipefail

# PR情報を取得
tmpfile=$(mktemp --suffix=.json)
# OS任せでクリーンアップ

gh api repos/{owner}/{repo}/pulls/{pull_number} > "$tmpfile"

# 基本情報を表示
echo "PR Title: $(jq -r '.title' "$tmpfile")"
echo "State: $(jq -r '.state' "$tmpfile")"
echo "Author: $(jq -r '.user.login' "$tmpfile")"

# レビューコメント数を取得
comments_file=$(mktemp --suffix=.json)
gh api repos/{owner}/{repo}/pulls/{pull_number}/comments > "$comments_file"
echo "Review comments: $(python3 -c "import json,sys; data=json.load(sys.stdin); print(len(data))" < "$comments_file")"

# 未解決のコメントがあるか確認
echo "First 5 comments:"
python3 -c "import json,sys; data=json.load(sys.stdin); [print(f\"Path: {c.get('path','')}, Line: {c.get('line','')}, Body: {c.get('body','')[:100]}\") for c in data[:5]]" < "$comments_file"
# OS任せでクリーンアップ（rmしない）
```

### パターン3: ブランチの同期確認

```bash
#!/bin/bash
set -euo pipefail

# リモートの最新情報を取得
git fetch origin

# ローカルとリモートの差分を確認
LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse @{u})
BASE=$(git merge-base @ @{u})

if [ "$LOCAL" = "$REMOTE" ]; then
    echo "Up-to-date"
elif [ "$LOCAL" = "$BASE" ]; then
    echo "Need to pull"
    git pull --ff-only
elif [ "$REMOTE" = "$BASE" ]; then
    echo "Need to push"
    git push origin HEAD
else
    echo "Diverged - manual intervention required"
    git --no-pager log --oneline @{u}..@ | head -n 10
    git --no-pager log --oneline @..@{u} | head -n 10
fi
```

---

## 適用ガイドライン

### このスキルを使うべき場面

- Git リポジトリでの作業
- GitHub 上での PR/Issue 操作
- コミット履歴の調査
- リモートリポジトリとの同期

### 避けるべきパターン

- ❌ `git log` を `--no-pager` なしで実行（ページャーが起動）
- ❌ `git commit -m "message"` で長いメッセージ（ファイル経由を推奨）
- ❌ `git merge` の前に確認なし
- ❌ `git push -f` （`--force-with-lease` を使用）
- ❌ gh api で `-F` と `-f` を混同（数値は `-F`、文字列は `-f`）

### 推奨パターン

- ✅ すべての `git log`/`git diff` に `--no-pager`
- ✅ コミットメッセージは一時ファイル経由（`-F`）
- ✅ 大量出力は一時ファイルに保存してから `head`/`jq` で確認
- ✅ `gh api` の結果は JSON ファイルに保存してから `jq` で処理
- ✅ インラインコメントは必須パラメータを確認（commit_id, path, line, side）

---

## gh api インラインコメントの必須パラメータ

### 単一行コメント

| パラメータ | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| body | string | ✅ | コメント本文 |
| commit_id | string | ✅ | コミットSHA |
| path | string | ✅ | ファイルの相対パス |
| line | integer | ✅ | 行番号 |
| side | string | - | "RIGHT" (デフォルト) または "LEFT" |

### 複数行コメント

| パラメータ | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| body | string | ✅ | コメント本文 |
| commit_id | string | ✅ | コミットSHA |
| path | string | ✅ | ファイルの相対パス |
| start_line | integer | ✅ | 開始行番号 |
| start_side | string | - | "RIGHT" (デフォルト) または "LEFT" |
| line | integer | ✅ | 終了行番号 |
| side | string | - | "RIGHT" (デフォルト) または "LEFT" |

**注意**:

- `-F` オプションは整数値に使用（例: `-F line=42`）
- `-f` オプションは文字列値に使用（例: `-f body="コメント"`）
- `{owner}`、`{repo}`、`{pull_number}` はプレースホルダー（実際の値に置き換える）

---

## 参考情報

- [Git Documentation](https://git-scm.com/docs)
- [GitHub CLI Manual](https://cli.github.com/manual/)
- [GitHub REST API - Pull Request Review Comments](https://docs.github.com/en/rest/pulls/comments)

---

## 関連プロンプト

- [シェルテクニック](shell_technique.prompt.md): シェルスクリプトの基本テクニック
- [PRコメント](pr_comment.prompt.md): PR コメントのベストプラクティス
- [調査・確認](investigation_check.prompt.md): 変更内容の調査・検証
