# VS Code Setup (Windows/WSL2)

このdotfilesリポジトリをWindows上のVS Codeで使用するためのセットアップ手順です。

## 前提条件

- Windows 10/11 + WSL2 (Ubuntu 24.04)
- VS Code (Windows版)
- Git

## セットアップ手順

1. **dotfilesリポジトリをクローン**
   ```bash
   cd ~/git/arapower
   git clone <repository-url> dotfiles
   cd dotfiles
   ```

2. **セットアップスクリプトを実行**
   ```bash
   ./scripts/setup-wsl2.sh
   ```
   
   このスクリプトは以下を実行します：
   - 既存のVS Code設定ファイルをバックアップ
   - Windows用のPowerShellスクリプトを生成 (`C:\Users\user01\setup-vscode-dotfiles.ps1`)

3. **PowerShellスクリプトを管理者として実行**
   
   PowerShellを管理者として開き、以下を実行：
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
   cd C:\Users\user01
   .\setup-vscode-dotfiles.ps1
   ```

4. **VS Codeを再起動**

## セットアップ内容

以下のシンボリックリンクが作成されます：

- `C:\Users\user01\AppData\Roaming\Code\User\settings.json`
  → `\\wsl$\Ubuntu-24.04\home\user01\git\arapower\dotfiles\vscode\settings.json`

- `C:\Users\user01\AppData\Roaming\Code\User\prompts`
  → `\\wsl$\Ubuntu-24.04\home\user01\git\arapower\dotfiles\prompts`

これにより、dotfiles側で設定を編集すると、自動的にVS Codeに反映されます。

## Custom Agents

`prompts/` ディレクトリには以下のCustom Agentが含まれています：

- **Beast mode.agent.md**: 自律的に問題を解決するエージェント
- **PR Review.agent.md**: Pull Requestをレビューするエージェント

VS Code再起動後、GitHub Copilot Chatのエージェントドロップダウンから選択できます。
