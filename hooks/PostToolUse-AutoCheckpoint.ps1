# Claude Code PostToolUse hook for Edit|Write matcher
# Auto-checkpoint via git stash (does not move HEAD, does not affect current branch).
# Recovery: `git stash list | grep claude-auto-checkpoint` then `git stash apply stash@{N}`

# hook が落ちて Claude Code session を阻害しないように silently exit
$ErrorActionPreference = "SilentlyContinue"

try {
    # PJ root 検出
    $repoRoot = git rev-parse --show-toplevel 2>$null
    if (-not $repoRoot) { exit 0 }
    Set-Location $repoRoot

    # 変更があるか確認
    $status = git status --porcelain
    if (-not $status) { exit 0 }

    # timestamp 付き auto-checkpoint stash
    $timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
    $msg = "[claude-auto-checkpoint] $timestamp"
    git stash push -u -m $msg --quiet 2>$null
    git stash apply --quiet 2>$null
} catch {
    # 何が起きても session は止めない
}

exit 0
