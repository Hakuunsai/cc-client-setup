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

function Install-ClaudeMd {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)] [string]$ProjectRoot,
        [Parameter(Mandatory=$true)] [string]$HomeRoot,
        [Parameter(Mandatory=$true)] [string]$RepoRoot
    )
    Write-Host "Install-ClaudeMd: $ProjectRoot/CLAUDE.md + $HomeRoot/.claude/CLAUDE.md" -ForegroundColor Cyan

    $srcPath = Join-Path $RepoRoot "templates/CLAUDE.md.template"
    foreach ($destPath in @(
        (Join-Path $ProjectRoot "CLAUDE.md"),
        (Join-Path $HomeRoot ".claude/CLAUDE.md")
    )) {
        $destDir = Split-Path $destPath -Parent
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        Backup-IfExists -Path $destPath
        Copy-Item $srcPath $destPath -Force
        Write-Host "  installed: $destPath" -ForegroundColor Green
    }
}

function Install-GitConventions {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)] [string]$ProjectRoot,
        [Parameter(Mandatory=$true)] [string]$RepoRoot
    )
    Write-Host "Install-GitConventions: $ProjectRoot/.gitignore + .git/hooks/" -ForegroundColor Cyan

    # .gitignore
    $gitignoreDest = Join-Path $ProjectRoot ".gitignore"
    Backup-IfExists -Path $gitignoreDest
    Copy-Item (Join-Path $RepoRoot "templates/gitignore.template") $gitignoreDest -Force
    Write-Host "  installed: $gitignoreDest" -ForegroundColor Green

    # pre-commit.ps1 (実体)
    $hooksDir = Join-Path $ProjectRoot ".git/hooks"
    if (-not (Test-Path $hooksDir)) {
        Write-Warning "  .git/hooks not found at $hooksDir - skipping hook install (run after git init)"
        return
    }
    $ps1Dest = Join-Path $hooksDir "pre-commit.ps1"
    Backup-IfExists -Path $ps1Dest
    Copy-Item (Join-Path $RepoRoot "templates/pre-commit.ps1.template") $ps1Dest -Force
    Write-Host "  installed: $ps1Dest" -ForegroundColor Green

    # pre-commit shim (POSIX shell that invokes pwsh)
    $shimDest = Join-Path $hooksDir "pre-commit"
    Backup-IfExists -Path $shimDest
    $shimContent = "#!/bin/sh`nexec pwsh.exe -File `"`$(git rev-parse --show-toplevel)/.git/hooks/pre-commit.ps1`" `"`$@`"`n"
    Set-Content -Path $shimDest -Value $shimContent -NoNewline -Encoding ascii
    # Git for Windows respects exec bit on hooks even on NTFS via core.filemode=false; chmod is best effort
    if ($IsLinux -or $IsMacOS) {
        chmod +x $shimDest
    }
    Write-Host "  installed: $shimDest" -ForegroundColor Green
}

function Install-SecretaryDir {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)] [string]$ProjectRoot,
        [Parameter(Mandatory=$true)] [string]$RepoRoot
    )
    Write-Host "Install-SecretaryDir: $ProjectRoot/.company/" -ForegroundColor Cyan

    # .company/ + .company/secretary/{todos,notes,inbox}/ 確保
    foreach ($sub in @(".company/secretary/todos", ".company/secretary/notes", ".company/secretary/inbox")) {
        $p = Join-Path $ProjectRoot $sub
        New-Item -ItemType Directory -Path $p -Force | Out-Null
    }

    # .company/CLAUDE.md は新規時のみ配置 (既存中身は touch しない)
    $claudeMdDest = Join-Path $ProjectRoot ".company/CLAUDE.md"
    if (-not (Test-Path $claudeMdDest)) {
        Copy-Item (Join-Path $RepoRoot "templates/company-secretary/CLAUDE.md") $claudeMdDest -Force
        Write-Host "  installed: $claudeMdDest" -ForegroundColor Green
    } else {
        Write-Host "  preserved (existing): $claudeMdDest" -ForegroundColor DarkGray
    }

    # .gitkeep 配置 (idempotent)
    foreach ($sub in @("todos", "notes", "inbox")) {
        $gitkeep = Join-Path $ProjectRoot ".company/secretary/$sub/.gitkeep"
        if (-not (Test-Path $gitkeep)) {
            New-Item -ItemType File -Path $gitkeep -Force | Out-Null
        }
    }
    Write-Host "  ensured: .company/secretary/{todos,notes,inbox}/.gitkeep" -ForegroundColor Green
}

function Initialize-ProjectGit {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)] [string]$ProjectRoot,
        [switch]$Force
    )
    if (-not (Test-Path $ProjectRoot)) {
        if ($Force -or (Read-Host "  Project dir not found: $ProjectRoot - create? [y/N]") -match '^[yY]') {
            New-Item -ItemType Directory -Path $ProjectRoot -Force | Out-Null
            Write-Host "  created: $ProjectRoot" -ForegroundColor Green
        } else {
            throw "Aborted: project dir does not exist."
        }
    }

    $gitDir = Join-Path $ProjectRoot ".git"
    if (Test-Path $gitDir) {
        Write-Host "Initialize-ProjectGit: .git found, skipping" -ForegroundColor DarkGray
        return
    }

    if (-not $Force) {
        $resp = Read-Host "  No .git found at $ProjectRoot - init? [y/N]"
        if ($resp -notmatch '^[yY]') {
            throw "Aborted: .git initialization declined."
        }
    }
    Write-Host "Initialize-ProjectGit: git init in $ProjectRoot" -ForegroundColor Cyan
    Push-Location $ProjectRoot
    try {
        git init -b main -q
        if ($LASTEXITCODE -ne 0 -or -not (Test-Path (Join-Path $ProjectRoot ".git"))) {
            throw "git init failed (exit $LASTEXITCODE) or .git not created at $ProjectRoot"
        }
        Write-Host "  git init -b main: done" -ForegroundColor Green
    } finally {
        Pop-Location
    }
}
