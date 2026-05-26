# Claude Code PreToolUse hook for Bash matcher
# Reads stdin JSON, denies dangerous commands (curl/wget/pip install/etc).
# Exit 0 = allow, exit 2 = deny (with stderr message)

$ErrorActionPreference = "Stop"

# stdin から JSON 読み取り
$inputJson = [System.Console]::In.ReadToEnd()
if (-not $inputJson) { exit 0 }

try { $payload = $inputJson | ConvertFrom-Json -ErrorAction Stop }
catch { exit 0 }
$cmd = $payload.tool_input.command
if (-not $cmd) { exit 0 }

# 危険 command パターン (settings.json deny と redundant、深層防御)
$denyPatterns = @(
    @{ Name = "外部通信 (curl)"; Regex = "^\s*curl(\s|$)" },
    @{ Name = "外部通信 (wget)"; Regex = "^\s*wget(\s|$)" },
    @{ Name = "外部通信 (Invoke-WebRequest)"; Regex = "Invoke-WebRequest" },
    @{ Name = "外部通信 (Invoke-RestMethod)"; Regex = "Invoke-RestMethod" },
    @{ Name = "パッケージ install (pip)"; Regex = "^\s*pip(3)?\s+install" },
    @{ Name = "パッケージ install (npm)"; Regex = "^\s*npm\s+install" },
    @{ Name = "環境変数一括表示"; Regex = "^\s*(env|printenv|Get-ChildItem\s+Env:)" },
    @{ Name = "ネスト実行 (powershell/pwsh -Command/-c)"; Regex = "(powershell|pwsh)(\.exe)?\b.*?\s+(-Command|-c)\b" },
    @{ Name = "ネスト実行 (cmd /c)"; Regex = "(cmd|cmd\.exe)\b.*?\s+/[cC]\b" },
    @{ Name = "ネスト実行 (bash -c)"; Regex = "^\s*bash\b.*?\s+-c\b" }
)

foreach ($p in $denyPatterns) {
    if ($cmd -match $p.Regex) {
        [Console]::Error.WriteLine("PreToolUse-DenyDangerous: blocked ($($p.Name))")
        [Console]::Error.WriteLine("  command: $cmd")
        [Console]::Error.WriteLine("  reason: ~/.claude/rules/network-security.md 参照")
        exit 2
    }
}

exit 0
