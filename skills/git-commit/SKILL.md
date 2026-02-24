---
name: git-commit
description: Create properly formatted Git commit messages following Conventional Commits standard
---

# Gitコミット操作スキル

コード変更を適切な単位で記録し、意味のあるコミットメッセージを作成することで、追跡可能で理解しやすい変更履歴を構築してください。変更の意図や背景を明確に伝え、将来のデバッグやコードレビュー、リバート作業を容易にします。

## 実行手順

### 0. 事前チェック（pre-commit/CIの失敗を先に潰す）

コミット後にCIが落ちると手戻りが増えるため、可能な範囲でローカルで早期検出します（リポジトリに合わせて選ぶ）。

```bash
# pre-commit が導入されている場合（推奨）
uv run pre-commit run -a

# Makefile がある場合（代表例）
make fmt
make lint
make test

# Node の場合（package.json を確認）
npm test

# Python の場合（pyproject.toml/pytest 設定を確認）
pytest
```

ポイント:

- 「存在するコマンドだけ」を実行する（なければスキップ）
- GitHub Actions上で失敗する処理をできるだけ再現して解消することを目的とする

### 3. コミットメッセージの作成

### Conventional Commits形式

当プロジェクトでは[Conventional Commits](https://www.conventionalcommits.org/)形式を採用します。

**基本ルール**:

1. コミットメッセージは**必ず**英語1行で書く（タイトル行のみ）
2. prefixのあとの`(type)`はつけない
2. タイトルは50文字以内を推奨（最大72文字）
3. タイトルは命令形で書く（動詞の原形で始める）
4. タイトルの最初の文字は小文字（type: の後）
5. タイトル末尾にピリオドは不要

## コミットメッセージの実例

**新機能追加**:

```
feat: add user authentication with JWT
```

**バグ修正**:

```
fix: correct pagination bug in user list
```

**リファクタリング**:

```
refactor: improve database connection handling
```

**ドキュメント更新**:

```
docs: update API specification
```

**パフォーマンス改善**:

```
perf: optimize database queries
```

**テスト追加**:

```
test: add test cases for user authentication
```

**Breaking Change**:

```
feat!: change API response format
```
