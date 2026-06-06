#!/usr/bin/env bash
# Claude Code PreToolUse hook for Bash matcher (Linux variant).
# Reads stdin JSON, denies dangerous commands. Exit 0 = allow, exit 2 = deny (stderr).
# settings.json deny の深層防御 (redundant)。jq で .tool_input.command を抽出。
# jq 不在/parse 失敗時は exit 0 (allow) にフェイルオープン (一次防御=settings deny が残る)。

set +e

input_json="$(cat)"
[ -z "$input_json" ] && exit 0

if ! command -v jq >/dev/null 2>&1; then
  echo "PreToolUse-DenyDangerous: jq not found, skipping deep-defense check (settings.json deny still active)" >&2
  exit 0
fi

cmd="$(printf '%s' "$input_json" | jq -r '.tool_input.command // empty' 2>/dev/null)"
[ -z "$cmd" ] && exit 0

deny() {
  echo "PreToolUse-DenyDangerous: blocked ($1)" >&2
  echo "  command: $cmd" >&2
  echo "  reason: ~/.claude/rules/network-security.md 参照" >&2
  exit 2
}

has() { printf '%s' "$cmd" | grep -Eq "$1"; }

# 危険 command パターン (PowerShell 版と等価、Linux で意味のあるもの)
has '^[[:space:]]*curl([[:space:]]|$)'           && deny "外部通信 (curl)"
has '^[[:space:]]*wget([[:space:]]|$)'           && deny "外部通信 (wget)"
has '^[[:space:]]*pip3?[[:space:]]+install'      && deny "パッケージ install (pip)"
has '^[[:space:]]*npm[[:space:]]+install'        && deny "パッケージ install (npm)"
has '^[[:space:]]*(env|printenv)([[:space:]]|$)' && deny "環境変数一括表示"

# ネスト実行: 起動コマンドが bash/sh かつ -c フラグを含む (2 条件、単一 regex の取りこぼし回避)
if has '^[[:space:]]*(bash|sh)([[:space:]]|$)' && has '(^|[[:space:]])-c([[:space:]]|$)'; then
  deny "ネスト実行 (bash/sh -c)"
fi

exit 0
