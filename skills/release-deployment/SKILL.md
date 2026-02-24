---
name: release-deployment
description: Execute release and deployment with proper versioning and CI/CD automation
---

# リリース・デプロイ操作スキル

**目的**: 生成AIエージェントがリリースとデプロイを自律的かつ安全に実行するための、汎用的な原則とベストプラクティス

**重要な原則**:

- **必ず事前確認**: 作業開始前にリポジトリ固有のドキュメント（`docs/release_guide.md`、`docs/deployment.md`、`CHANGELOG.md`、`Makefile`等）を確認する
- **リリース前チェック**: CI/CDパイプライン成功、ドキュメント更新、バージョン整合性を確認する
- **環境別デプロイ**: 認証方式（AWS OIDC、GCP Workload Identity、GitHub App）と環境分離戦略を理解する
- **ロールバック手順**: タグ削除やリリース取り消しの手順を事前に把握する
