---
name: git-automation
description: Execute non-interactive Git commands for AI agent automation with pagers disabled
---

# Git自動化操作スキル

**目的**: 生成AIエージェントがGitリポジトリ上で自律的に作業を行うための、非インタラクティブ志向のコマンドパターン

**重要な原則**:

- ページャー（less/more）を**絶対に起動しない** → `--no-pager` 必須
- コミットメッセージはファイル経由 → `-F` オプション使用
- 大量出力は一時ファイル経由で確認
- リポジトリごとにコミットやリリース関連のドキュメントがある可能性があるため、事前に確認する

## 参照ドキュメント

このスキルは以下のドキュメントと併せて使用することで、より効果的に活用できます：

- [シェルテクニック](references/shell_technique.md) - 非インタラクティブなシェルスクリプトテクニック

## 参考情報

- [Git Documentation](https://git-scm.com/docs)
- [Conventional Commits](https://www.conventionalcommits.org/)
