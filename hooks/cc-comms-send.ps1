# cc-comms-send.ps1 — cc-comms-send.sh の Windows 等価版。契約は .sh と同一。
#   secret check(fail-closed) + kind 強制 を通してから commit/push する。
#   metadata = commit + push（allowlist 経由で ask bypass = 自律送信）
#   business = commit のみ（push は raw git push で client 承認を要する）
# 正本 spec: office-tada/docs/superpowers/specs/2026-06-06-cc-client-office-tada-comms-mechanism-design.md
#
# 呼び出し: pwsh -File cc-comms-send.ps1 <msg_file>
# 環境変数:  CC_COMMS_DIR    (default: $HOME/.cc-client-comms)
#            CC_COMMS_REMOTE (default: origin)

$ErrorActionPreference = 'Continue'

$CommsDir    = if ($env:CC_COMMS_DIR)    { $env:CC_COMMS_DIR }    else { Join-Path $HOME '.cc-client-comms' }
$CommsRemote = if ($env:CC_COMMS_REMOTE) { $env:CC_COMMS_REMOTE } else { 'origin' }
$MsgFile     = $args[0]

function Err($m) { [Console]::Error.WriteLine("cc-comms-send: $m") }

# --- fail-closed 前提チェック ---
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Err 'git 不在 (fail-closed: 送信中止)'; exit 1
}
if (-not $MsgFile) {
    Err 'usage: cc-comms-send.ps1 <msg_file>'; exit 1
}
if (-not (Test-Path $MsgFile)) {
    Err "msg ファイルが見つからない: $MsgFile (fail-closed)"; exit 1
}
if (-not (Test-Path (Join-Path $CommsDir '.git'))) {
    Err "comms repo 未初期化: $CommsDir (fail-closed)"; exit 1
}

# --- kind 取得（frontmatter の kind:、先頭 1 件）---
$content   = Get-Content -Raw $MsgFile -ErrorAction Stop
$kindMatch = [regex]::Match($content, '(?m)^kind:\s*(\S+)')
$kind      = if ($kindMatch.Success) { $kindMatch.Groups[1].Value.Trim() } else { '' }

if ($kind -ne 'metadata' -and $kind -ne 'business') {
    Err "kind は metadata|business のみ (取得値='$kind', fail-closed)"; exit 1
}

# --- secret check（fail-closed: 1 件でも検出で中止）---
# 正本 regex: templates/pre-commit.ps1.template（DRY: 変更時は両方同期）
# [regex]::IsMatch の IgnoreCase オプション = .sh の grep -Eiq 相当
$secretRegexes = @(
    'AKIA[0-9A-Z]{16}',
    '-----BEGIN ((RSA|EC|DSA|OPENSSH) )?PRIVATE KEY-----',
    "password\s*=\s*['`"][^'`"\s]{8,}['`"]",
    'ghp_[A-Za-z0-9]{36}',
    'xox[abposr]-[A-Za-z0-9-]{10,}'
)

$reOptions = [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
foreach ($re in $secretRegexes) {
    if ([regex]::IsMatch($content, $re, $reOptions)) {
        Err "secret らしき文字列を検出。送信中止 (pattern: $re)"; exit 1
    }
}

# --- commit（msg_file 限定: inbox 全体 add を避ける）---
$rel = Split-Path $MsgFile -Leaf

Push-Location $CommsDir
try {
    git add -- $MsgFile 2>&1 | Out-Null
    git commit -qm "[cc-comms] send $kind $rel" 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Err 'commit 失敗 (fail-closed)'; exit 1
    }

    # --- kind による push 分岐 ---
    if ($kind -eq 'metadata') {
        $localBranch = git rev-parse --abbrev-ref HEAD 2>$null
        git push -q $CommsRemote "HEAD:${localBranch}" 2>&1 | Out-Null
        $pushRc = $LASTEXITCODE
        if ($pushRc -eq 0) {
            Write-Output "cc-comms-send: metadata 自律送信 完了 ($rel)"
            exit 0
        } else {
            Err 'push 失敗 (commit は済。後で再送可)'; exit 1
        }
    } else {
        # business: commit のみ、push しない
        Err "business を commit しました（未送信）。送信するには client 承認が必要です:"
        Err "  git -C `"$CommsDir`" push $CommsRemote HEAD"
        exit 0
    }
} finally {
    Pop-Location
}
