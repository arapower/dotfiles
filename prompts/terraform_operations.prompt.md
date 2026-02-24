---
name: terraform_operations
description: Terraform/Terragruntを安全かつ効率的に使用するためのコマンド集
tools: ['execute', 'read', 'search', 'web']
agent: beast
---

# Terraform/Terragrunt操作プロンプト

**目的**: 生成AIエージェントがTerraform/Terragruntでインフラストラクチャをコード管理する際の、非インタラクティブ志向のコマンドパターン

---

## スキルの定義

このスキルは、生成AIエージェントがTerraform/Terragruntでインフラストラクチャをコード管理する際の、非インタラクティブ志向のコマンドパターンを提供します。

**重要な原則**:

- インタラクティブな承認を**絶対に避ける** → `-auto-approve` は慎重に使用
- plan結果は必ずファイルに保存して確認
- state操作は極力避ける（危険性が高い）
- 環境変数でクレデンシャルを管理

**⚠️ 重大な警告 - Terraform/Terragruntのパイプ処理禁止**:

- **terraform/terragruntの実行結果をパイプで繋いでhead/more/less/tail等に渡すのは絶対に禁止**
- 理由: パイプの先で処理が中断されると、**ロックファイルが残り続けてプロダクト全体に支障が出る**
- 必ず一度ファイルに出力してから、そのファイルに対してhead/tail等を実行すること

```bash
# ❌ 絶対にやってはいけない例
terraform plan | head -n 50  # パイプラインが中断されるとロックが残る
terragrunt apply | more       # 同様に危険

# ✅ 正しい方法
tmpfile=$(mktemp)
terraform plan > "$tmpfile" 2>&1
head -n 50 "$tmpfile"  # ファイルに対してならOK
```

---

## 1. Terraform 基本操作

### 初期化（terraform init）

```bash
# 基本的な初期化
terraform init

# バックエンド再設定
terraform init -reconfigure

# プラグインのアップグレード
terraform init -upgrade

# 一時ファイルにログを出力
tmplog=$(mktemp)
terraform init > "$tmplog" 2>&1
cat "$tmplog"
```

### フォーマット（terraform fmt）

```bash
# カレントディレクトリのフォーマット
terraform fmt

# 再帰的にフォーマット
terraform fmt -recursive

# 差分を確認（変更せずチェックのみ）
terraform fmt -check -recursive

# フォーマットが必要なファイル一覧
terraform fmt -check -recursive -diff
```

### 検証（terraform validate）

```bash
# 構文チェック
terraform validate

# JSON形式で出力
terraform validate -json

# 検証結果を一時ファイルに保存
tmpfile=$(mktemp --suffix=.json)
terraform validate -json > "$tmpfile"
python3 -c "
import json
with open('$tmpfile') as f:
    result = json.load(f)
    if result['valid']:
        print('✓ Validation passed')
    else:
        print('✗ Validation failed')
        for diag in result.get('diagnostics', []):
            print(f\"  {diag['severity']}: {diag['summary']}\")
"
```

---

## 2. Plan（計画）

### 基本的なplan

```bash
# planを実行して結果を確認
terraform plan

# plan結果を一時ファイルに保存
tmpfile=$(mktemp)
terraform plan -out="$tmpfile"

# plan結果を人間が読める形式で表示
terraform show "$tmpfile"

# plan結果をJSON形式で保存
tmpjson=$(mktemp --suffix=.json)
terraform show -json "$tmpfile" > "$tmpjson"

# リソース変更の統計を確認
python3 -c "
import json
with open('$tmpjson') as f:
    data = json.load(f)
    changes = data.get('resource_changes', [])
    create = sum(1 for c in changes if 'create' in c.get('change', {}).get('actions', []))
    update = sum(1 for c in changes if 'update' in c.get('change', {}).get('actions', []))
    delete = sum(1 for c in changes if 'delete' in c.get('change', {}).get('actions', []))
    print(f'Create: {create}, Update: {update}, Delete: {delete}')
"
```

### 特定リソースのみplan

```bash
# 特定リソースのみ対象
terraform plan -target=aws_instance.example

# 複数リソースを指定
terraform plan \
  -target=aws_instance.web \
  -target=aws_security_group.web
```

### 変数の指定

```bash
# コマンドラインで変数を指定
terraform plan -var="instance_type=t2.micro"

# 変数ファイルを指定
terraform plan -var-file="production.tfvars"

# 環境変数から取得
export TF_VAR_instance_type="t2.micro"
terraform plan
```

---

## 3. Apply（適用）

### 基本的なapply

```bash
# plan結果を適用（承認が必要）
terraform apply

# 自動承認（本番環境では非推奨）
# 注意: -auto-approve は慎重に使用すること
terraform apply -auto-approve

# plan済みの結果を適用（承認不要）
tmpplan=$(mktemp)
terraform plan -out="$tmpplan"
# planを確認してから...
terraform apply "$tmpplan"
```

### 特定リソースのみapply

```bash
# 特定リソースのみ適用
terraform apply -target=aws_instance.example -auto-approve
```

---

## 4. Destroy（削除）

### 基本的なdestroy

```bash
# 全リソースを削除（承認が必要）
terraform destroy

# 自動承認（非常に危険）
# 注意: 本番環境では絶対に使用しないこと
terraform destroy -auto-approve

# plan形式で削除内容を確認
terraform plan -destroy
```

### 特定リソースのみdestroy

```bash
# 特定リソースのみ削除
terraform destroy -target=aws_instance.test -auto-approve
```

---

## 5. State（状態管理）

### state確認

```bash
# state内のリソース一覧
terraform state list

# 特定リソースの詳細表示
terraform state show aws_instance.example

# state全体をJSON形式で出力
tmpfile=$(mktemp --suffix=.json)
terraform show -json > "$tmpfile"
```

### stateの操作（危険・慎重に）

```bash
# リソースを別名に変更
terraform state mv aws_instance.old aws_instance.new

# リソースをstateから削除（実際のリソースは削除されない）
terraform state rm aws_instance.example

# リソースをインポート
terraform import aws_instance.example i-1234567890abcdef0

# stateのバックアップ
terraform state pull > state_backup.json
```

---

## 6. Workspace（環境管理）

### workspace操作

```bash
# workspace一覧
terraform workspace list

# 新しいworkspaceを作成
terraform workspace new staging

# workspaceを切り替え
terraform workspace select production

# 現在のworkspace名を取得
terraform workspace show
```

---

## 7. Graph（依存関係）

```bash
# 依存関係をDOT形式で出力
terraform graph > graph.dot

# 視覚化（Graphviz必要）
# terraform graph | dot -Tpng > graph.png
```

---

## 8. Output（出力値）

```bash
# すべてのoutputを表示
terraform output

# 特定のoutputを取得
terraform output instance_ip

# JSON形式で出力
tmpfile=$(mktemp --suffix=.json)
terraform output -json > "$tmpfile"

# Pythonで特定の値を抽出
python3 -c "
import json
with open('$tmpfile') as f:
    data = json.load(f)
    print('Instance IP:', data['instance_ip']['value'])
"
```

---

## 9. Import（既存リソースの取り込み）

```bash
# 既存リソースをstateに取り込む
terraform import aws_instance.example i-1234567890abcdef0

# 複数リソースのインポート（一時ファイル経由）
tmpfile=$(mktemp)
cat > "$tmpfile" <<'EOF'
aws_instance.web1:i-111111111
aws_instance.web2:i-222222222
aws_instance.db:i-333333333
EOF

while IFS=: read -r resource id; do
    echo "Importing $resource..."
    terraform import "$resource" "$id"
done < "$tmpfile"
```

---

## 10. Taint/Untaint（リソースの再作成マーク）

```bash
# リソースに再作成フラグを立てる
terraform taint aws_instance.example

# 再作成フラグを解除
terraform untaint aws_instance.example

# taintされたリソースの一覧（間接的に確認）
terraform plan
```

---

## 11. Providers（プロバイダー管理）

```bash
# 使用中のプロバイダー一覧
terraform providers

# プロバイダーのスキーマを表示
terraform providers schema -json > providers_schema.json

# プロバイダーのロック
terraform providers lock
```

---

## 12. Terragrunt 基本操作

### 初期化

```bash
# Terragrunt経由でterraform init
terragrunt init

# 全モジュールを初期化
terragrunt run-all init
```

### Plan/Apply

```bash
# Terragrunt経由でplan
terragrunt plan

# Terragrunt経由でapply
terragrunt apply

# 全モジュールに対して実行
terragrunt run-all plan
terragrunt run-all apply -auto-approve  # 注意: 本番では非推奨
```

### 依存関係の実行

```bash
# 依存関係を含めてapply
terragrunt apply-all

# 依存関係を含めてdestroy
terragrunt destroy-all
```

### Outputの取得

```bash
# Terragrunt経由でoutput
terragrunt output

# JSON形式
terragrunt output -json
```

### グラフの生成

```bash
# モジュール間の依存関係をグラフ化
terragrunt graph-dependencies
```

---

## 13. 環境変数の管理

### AWS認証情報

```bash
# 環境変数で認証情報を設定
export AWS_ACCESS_KEY_ID="AKIAXXXXXXXXXXXXXXXX"
export AWS_SECRET_ACCESS_KEY="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
export AWS_DEFAULT_REGION="ap-northeast-1"

# AWS CLIプロファイル使用
export AWS_PROFILE="production"

# terraform実行
terraform plan
```

### Terraform変数

```bash
# 環境変数でterraform変数を設定
export TF_VAR_instance_type="t2.micro"
export TF_VAR_environment="production"

# terraform実行
terraform plan
```

### Terraformログレベル

```bash
# ログレベルを設定（TRACE, DEBUG, INFO, WARN, ERROR）
export TF_LOG="DEBUG"
export TF_LOG_PATH="terraform.log"

terraform apply
```

---

## 14. TFLint（静的解析）

```bash
# 基本的なlint
tflint

# 初期化（プラグインインストール）
tflint --init

# 再帰的にlint
tflint --recursive

# 特定のフォーマットで出力
tflint --format=json > tflint_result.json

# エラーのみ表示
tflint --minimum-failure-severity=error
```

---

## 15. セキュリティチェック

### Checkov

```bash
# ディレクトリをスキャン
checkov -d .

# 特定のチェックのみ実行
checkov -d . --check CKV_AWS_23

# JSON形式で出力
tmpfile=$(mktemp --suffix=.json)
checkov -d . -o json > "$tmpfile"

# Pythonで結果を解析
python3 -c "
import json
with open('$tmpfile') as f:
    data = json.load(f)
    summary = data['summary']
    print(f\"Passed: {summary['passed']}, Failed: {summary['failed']}\")
"
```

### Trivy

```bash
# Terraformコードをスキャン
trivy config .

# 重大度を指定
trivy config --severity HIGH,CRITICAL .

# JSON形式で出力
trivy config --format json -o trivy_result.json .
```

---

## 16. 実践的なワークフロー

### パターン1: 安全なapply

```bash
#!/bin/bash
set -euo pipefail

# ステップ1: フォーマットチェック
echo "=== Format Check ==="
if ! terraform fmt -check -recursive; then
    echo "Format errors found. Run 'terraform fmt -recursive' to fix."
    exit 1
fi

# ステップ2: 検証
echo "=== Validation ==="
terraform validate

# ステップ3: plan
echo "=== Planning ==="
tmpplan=$(mktemp)
terraform plan -out="$tmpplan"

# ステップ4: planの統計を確認
tmpjson=$(mktemp --suffix=.json)
terraform show -json "$tmpplan" > "$tmpjson"
python3 -c "
import json
with open('$tmpjson') as f:
    data = json.load(f)
    changes = data.get('resource_changes', [])
    for change in changes:
        addr = change['address']
        actions = change['change']['actions']
        print(f'{addr}: {actions}')
"

# ステップ5: 承認待ち（自動化の場合はスキップ）
echo "Review the plan above. Press Enter to apply or Ctrl+C to cancel."
# read -r  # インタラクティブ操作は避ける

# ステップ6: apply
echo "=== Applying ==="
terraform apply "$tmpplan"
```

### パターン2: CI/CD向けの完全自動化

```bash
#!/bin/bash
set -euo pipefail

# 環境変数チェック
if [ -z "${TF_VAR_environment:-}" ]; then
    echo "Error: TF_VAR_environment is not set"
    exit 1
fi

# フォーマット・検証
terraform fmt -check -recursive
terraform validate

# plan
tmpplan=$(mktemp)
terraform plan -out="$tmpplan"

# planが変更なしの場合はスキップ
tmpjson=$(mktemp --suffix=.json)
terraform show -json "$tmpplan" > "$tmpjson"
has_changes=$(python3 -c "
import json
with open('$tmpjson') as f:
    data = json.load(f)
    print('yes' if data.get('resource_changes') else 'no')
")

if [ "$has_changes" = "no" ]; then
    echo "No changes detected. Skipping apply."
    exit 0
fi

# apply（自動承認）
terraform apply "$tmpplan"
```

### パターン3: Terragruntマルチ環境管理

```bash
#!/bin/bash
set -euo pipefail

ENVIRONMENT=${1:-dev}
cd "environments/$ENVIRONMENT"

# 初期化
terragrunt init

# plan
terragrunt plan

# apply（承認が必要）
terragrunt apply

# outputを取得
tmpfile=$(mktemp --suffix=.json)
terragrunt output -json > "$tmpfile"
echo "Outputs saved to $tmpfile"
```

---

## 17. トラブルシューティング

### Lock解除

```bash
# stateのlockを強制解除（慎重に）
terraform force-unlock <LOCK_ID>
```

### キャッシュクリア

```bash
# .terraformディレクトリを削除して再初期化
# 注意: rmコマンドは避けるべきだが、ここでは例外的に記載
# 実際には手動で削除するか、上書き可能な方法を検討
[ -d .terraform ] && mv .terraform .terraform.backup
terraform init
```

### プロバイダーキャッシュ

```bash
# プロバイダーのキャッシュをクリア
export TF_PLUGIN_CACHE_DIR=""
terraform init -upgrade
```

---

## ベストプラクティス

### DO（推奨）

- ✅ plan結果を必ずファイルに保存して確認
- ✅ apply前にplan済みファイルを使用
- ✅ 環境変数で認証情報を管理
- ✅ terraform fmt を常に実行
- ✅ terraform validate で構文チェック
- ✅ workspaceで環境を分離
- ✅ stateはリモートバックエンドに保存（S3, GCS等）
- ✅ .terraform.lock.hcl をバージョン管理

### DON'T（避けるべき）

- ❌ -auto-approve を本番環境で使用
- ❌ stateファイルを手動で編集
- ❌ terraform destroy -auto-approve を本番環境で実行
- ❌ 認証情報をコードにハードコード
- ❌ stateファイルをバージョン管理に含める
- ❌ 複数人で同時に同じstateを操作

---

## 関連プロンプト

- [シェルテクニック](shell_technique.prompt.md): シェルコマンドテクニック
- [調査](research.prompt.md): セキュリティツールの調査
- [Git操作](git_operations.prompt.md): Terraform設定のバージョン管理

---

## 参考情報

- [Terraform Documentation](https://www.terraform.io/docs)
- [Terragrunt Documentation](https://terragrunt.gruntwork.io/docs/)
- [TFLint Documentation](https://github.com/terraform-linters/tflint)
- [Checkov Documentation](https://www.checkov.io/)
