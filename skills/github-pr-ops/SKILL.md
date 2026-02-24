---
name: github-pr-ops
description: Operate gh command (GitHub CLI) and API for pull request review comments
---

# GitHub PR操作スキル

**目的**: 生成AIエージェントがGitHub上でPRレビューを自律的に行うための、GitHub CLIおよびAPIの非インタラクティブ操作パターン

---

## スキルの定義

このスキルは、GitHub CLIとAPIを使用して、プルリクエストのレビューコメント、インラインコメント、イシュー管理を自律的に行うためのコマンドパターンを提供します。

**重要な原則**:

- PR作成前に**必ずユーザー確認**を求める
- インラインコメント投稿前に**必ずユーザー確認**を求める
- ユーザー確認は投稿内容を./tmpディレクトリ内にファイル出力して行う
- JSON出力はPythonで処理（jqは限定的に使用）
- `-F` オプションは数値フィールド、`-f` は文字列フィールド

---

## PRコメント操作

### コメント種別の明示

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

## GitHub API（gh api）

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

## PRのインラインコメント取得

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

## PRの特定行にインラインコメントを追加

### 複数行範囲指定コメント

```bash
# 複数行にまたがるコメント（start_line〜lineの範囲）
comment_file=$(mktemp)
cat > "$comment_file" <<'EOF'
この関数は複雑すぎます。以下の対応を検討してください：

1. 小さな関数に分割
2. 早期リターンでネストを減らす
3. 変数名を明確にする
EOF

# ユーザー承認後に実行
commit_sha=$(gh api repos/{owner}/{repo}/pulls/{pull_number} --jq '.head.sha')
comment_body=$(cat "$comment_file")

# 以下のコマンドをユーザー承認後に実行：
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
```

### パラメータ詳細

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

---

## 参考情報

- [GitHub CLI Manual](https://cli.github.com/manual/)
- [GitHub REST API - Pull Request Review Comments](https://docs.github.com/en/rest/pulls/comments)
- [GitHub REST API - Issues](https://docs.github.com/en/rest/issues)
