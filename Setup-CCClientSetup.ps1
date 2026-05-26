<#
.SYNOPSIS
    cc-client-setup Phase 1 MVP bootstrap script.

.DESCRIPTION
    クライアント PC (Windows native) に Claude Code 環境構築 kit を冪等配置する。
    詳細は ./docs/installation.md 参照。

.PARAMETER ProjectPath
    対象 PJ の絶対パス (例: C:\path\to\client-app)。
    .git 不在ならば git init を提案、dir 不在ならば作成を提案。
.EXAMPLE
    pwsh -File .\Setup-CCClientSetup.ps1 -ProjectPath C:\path\to\client-app

.NOTES
    Version: 0.1.0
    Repository: Hakuunsai/cc-client-setup (private)
#>

[CmdletBinding()]
param(
    [string]$ProjectPath = $null
)

$ErrorActionPreference = "Stop"

# --- 冪等性 helper ---

function Backup-IfExists {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path
    )
    if (Test-Path $Path) {
        $timestamp = (Get-Date).ToString("yyyyMMddTHHmmss")
        $backupPath = "$Path.bak.$timestamp"
        Move-Item $Path $backupPath -Force
        Write-Host "  backed up: $Path -> $backupPath" -ForegroundColor DarkGray
    }
}

function Install-ClaudeCodeRules {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)] [string]$HomeRoot,
        [Parameter(Mandatory=$true)] [string]$RepoRoot
    )
    Write-Host "Install-ClaudeCodeRules: $HomeRoot/.claude/rules/" -ForegroundColor Cyan
    $destDir = Join-Path $HomeRoot ".claude/rules"
    New-Item -ItemType Directory -Path $destDir -Force | Out-Null

    $srcDir = Join-Path $RepoRoot "templates/claude-rules"
    foreach ($file in @("security-essentials.md", "forbidden-files.md", "network-security.md")) {
        $srcPath = Join-Path $srcDir $file
        $destPath = Join-Path $destDir $file
        Backup-IfExists -Path $destPath
        Copy-Item $srcPath $destPath -Force
        Write-Host "  installed: $destPath" -ForegroundColor Green
    }
}

function Install-ClaudeCodeSettings {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)] [string]$HomeRoot,
        [Parameter(Mandatory=$true)] [string]$RepoRoot,
        [Parameter(Mandatory=$true)] [string]$UserName
    )
    Write-Host "Install-ClaudeCodeSettings: $HomeRoot/.claude/settings.json (USER=$UserName)" -ForegroundColor Cyan
    $destDir = Join-Path $HomeRoot ".claude"
    New-Item -ItemType Directory -Path $destDir -Force | Out-Null

    $srcPath = Join-Path $RepoRoot "templates/settings.json.template"
    $destPath = Join-Path $destDir "settings.json"
    Backup-IfExists -Path $destPath

    $content = Get-Content $srcPath -Raw
    $content = $content -replace "<USER>", $UserName
    Set-Content -Path $destPath -Value $content -NoNewline
    Write-Host "  installed: $destPath" -ForegroundColor Green
}

function Install-ClaudeCodeHooks {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)] [string]$HomeRoot,
        [Parameter(Mandatory=$true)] [string]$RepoRoot
    )
    Write-Host "Install-ClaudeCodeHooks: $HomeRoot/.claude/hooks/" -ForegroundColor Cyan
    $destDir = Join-Path $HomeRoot ".claude/hooks"
    New-Item -ItemType Directory -Path $destDir -Force | Out-Null

    $srcDir = Join-Path $RepoRoot "hooks"
    foreach ($file in @("PreToolUse-DenyDangerous.ps1", "PostToolUse-AutoCheckpoint.ps1")) {
        $srcPath = Join-Path $srcDir $file
        $destPath = Join-Path $destDir $file
        Backup-IfExists -Path $destPath
        Copy-Item $srcPath $destPath -Force
        Write-Host "  installed: $destPath" -ForegroundColor Green
    }
}
