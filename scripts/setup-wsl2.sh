#!/usr/bin/env bash
set -euo pipefail

# VS Code dotfiles setup script for WSL2
# This script generates a PowerShell script that must be run as Administrator

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
VSCODE_USER_DIR="/mnt/c/Users/user01/AppData/Roaming/Code/User"
BACKUP_DIR="$DOTFILES_DIR/backup_$(date +%Y%m%d_%H%M%S)"
PS_SCRIPT_PATH="/mnt/c/Users/user01/setup-vscode-dotfiles.ps1"

echo "=== VS Code dotfiles setup for WSL2 ==="
echo "Dotfiles directory: $DOTFILES_DIR"
echo "VS Code User directory: $VSCODE_USER_DIR"
echo ""

# Create backup directory
mkdir -p "$BACKUP_DIR"
echo "Backup directory created: $BACKUP_DIR"
echo ""

# Backup existing files
echo "Backing up existing files..."
if [ -e "$VSCODE_USER_DIR/settings.json" ] && [ ! -L "$VSCODE_USER_DIR/settings.json" ]; then
    echo "  - settings.json"
    mv "$VSCODE_USER_DIR/settings.json" "$BACKUP_DIR/"
fi
if [ -e "$VSCODE_USER_DIR/prompts" ] && [ ! -L "$VSCODE_USER_DIR/prompts" ]; then
    echo "  - prompts/"
    mv "$VSCODE_USER_DIR/prompts" "$BACKUP_DIR/"
fi
echo ""

# Function to convert WSL path to Windows UNC path (\\wsl$\Ubuntu-24.04\...)
wsl_to_windows_path() {
    local wsl_path="$1"
    echo "\\\\wsl\$\\Ubuntu-24.04${wsl_path}"
}

# Generate PowerShell script
echo "Generating PowerShell script..."
cat > "$PS_SCRIPT_PATH" <<'PSEOF'
# VS Code dotfiles setup script for Windows
# This script must be run as Administrator

# Check if running as Administrator
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Error: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Please right-click on PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "=== VS Code Dotfiles Setup ===" -ForegroundColor Cyan
Write-Host ""

PSEOF

# Add settings.json symlink creation
TARGET_WIN=$(wsl_to_windows_path "$DOTFILES_DIR/vscode/settings.json")
LINK_WIN="C:\Users\user01\AppData\Roaming\Code\User\settings.json"
cat >> "$PS_SCRIPT_PATH" <<PSEOF
# Create settings.json symlink
Write-Host "Creating settings.json symlink..." -ForegroundColor Green
\$target = '$TARGET_WIN'
\$link = '$LINK_WIN'
try {
    if (Test-Path \$link) {
        Remove-Item \$link -Force
    }
    New-Item -ItemType SymbolicLink -Path \$link -Target \$target -Force | Out-Null
    Write-Host "  ✓ settings.json linked" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Failed to create settings.json symlink: \$_" -ForegroundColor Red
}

PSEOF

# Add prompts directory junction creation
TARGET_WIN=$(wsl_to_windows_path "$DOTFILES_DIR/prompts")
LINK_WIN="C:\Users\user01\AppData\Roaming\Code\User\prompts"
cat >> "$PS_SCRIPT_PATH" <<PSEOF
# Create prompts directory symlink
Write-Host "Creating prompts directory symlink..." -ForegroundColor Green
$target = '$TARGET_WIN'
$link = '$LINK_WIN'
try {
    if (Test-Path $link) {
        Remove-Item $link -Force -Recurse
    }
    New-Item -ItemType SymbolicLink -Path $link -Target $target -Force | Out-Null
    Write-Host "  ✓ prompts/ linked" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Failed to create prompts symlink: $_" -ForegroundColor Red
}

PSEOF

# Add completion message
cat >> "$PS_SCRIPT_PATH" <<'PSEOF'

Write-Host ""
Write-Host "=== Setup completed! ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Restart VS Code to apply changes." -ForegroundColor Yellow
Write-Host ""
Read-Host "Press Enter to exit"
PSEOF

chmod +x "$PS_SCRIPT_PATH"

echo "✓ PowerShell script generated: C:\Users\user01\setup-vscode-dotfiles.ps1"
echo ""
echo "=== NEXT STEPS ==="
echo ""
echo "1. Open PowerShell as Administrator:"
echo "   - Press Win+X"
echo "   - Select 'Windows PowerShell (Admin)' or 'Terminal (Admin)'"
echo ""
echo "2. Run the following command:"
echo "   cd C:\Users\user01"
echo "   .\setup-vscode-dotfiles.ps1"
echo ""
echo "3. Restart VS Code after the script completes"
echo ""
echo "Backup location: $BACKUP_DIR"
echo ""
