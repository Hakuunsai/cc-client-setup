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
    [Parameter(Mandatory=$true)]
    [string]$ProjectPath
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
