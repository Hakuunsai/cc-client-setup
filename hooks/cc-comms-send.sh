#!/usr/bin/env bash
# cc-comms-send.sh — client→owner 連絡送信。
#   secret check(fail-closed) + kind 強制 を通してから commit/push する。
#   metadata = commit + push（allowlist 経由で ask bypass=自律送信）
#   business = commit のみ（push は raw git push で client 承認を要する）
# 正本 spec: office-tada/docs/superpowers/specs/2026-06-06-cc-client-office-tada-comms-mechanism-design.md
set +e

CC_COMMS_DIR="${CC_COMMS_DIR:-$HOME/.cc-client-comms}"
CC_COMMS_REMOTE="${CC_COMMS_REMOTE:-origin}"
msg_file="$1"

err() { echo "cc-comms-send: $1" >&2; }

# --- fail-closed 前提チェック ---
command -v grep >/dev/null 2>&1 || { err "grep 不在 (fail-closed: 送信中止)"; exit 1; }
command -v git  >/dev/null 2>&1 || { err "git 不在 (fail-closed: 送信中止)"; exit 1; }
[ -n "$msg_file" ] || { err "usage: cc-comms-send.sh <msg_file>"; exit 1; }
[ -f "$msg_file" ] || { err "msg ファイルが見つからない: $msg_file (fail-closed)"; exit 1; }
[ -d "$CC_COMMS_DIR/.git" ] || { err "comms repo 未初期化: $CC_COMMS_DIR (fail-closed)"; exit 1; }

# --- kind 取得（frontmatter の kind:）---
# frontmatter に kind 行が複数あれば先頭を採用
kind="$(grep -m1 -E '^kind:[[:space:]]*' "$msg_file" 2>/dev/null | sed -E 's/^kind:[[:space:]]*//' | tr -d '[:space:]')"
case "$kind" in
  metadata|business) ;;
  *) err "kind は metadata|business のみ (取得値='$kind', fail-closed)"; exit 1 ;;
esac

# --- secret check（fail-closed: 1 件でも検出で中止）---
# 正本 regex: templates/pre-commit.sh.template（DRY: 変更時は両方同期）
secret_regexes=(
  "AKIA[0-9A-Z]{16}"
  "-----BEGIN ((RSA|EC|DSA|OPENSSH) )?PRIVATE KEY-----"
  "password[[:space:]]*=[[:space:]]*[\"'][^\"'[:space:]]{8,}[\"']"
  "ghp_[A-Za-z0-9]{36}"
  "xox[abposr]-[A-Za-z0-9-]{10,}"
)
for re in "${secret_regexes[@]}"; do
  grep_rc=0
  grep -Eiq -- "$re" "$msg_file" 2>/dev/null || grep_rc=$?
  if [ "$grep_rc" -eq 0 ]; then
    err "secret らしき文字列を検出。送信中止 (pattern: $re)"; exit 1
  elif [ "$grep_rc" -ge 2 ]; then
    err "secret check 実行エラー (pattern: $re, fail-closed)"; exit 1
  fi
done

# --- commit ---
rel="$(basename "$msg_file")"
( cd "$CC_COMMS_DIR" && git add -- "$msg_file" >/dev/null 2>&1 \
    && git commit -qm "[cc-comms] send $kind $rel" >/dev/null 2>&1 ) || {
  err "commit 失敗 (fail-closed)"; exit 1; }

# --- kind による push 分岐 ---
if [ "$kind" = "metadata" ]; then
  local_branch="$(cd "$CC_COMMS_DIR" && git rev-parse --abbrev-ref HEAD 2>/dev/null)"
  if ( cd "$CC_COMMS_DIR" && git push -q "$CC_COMMS_REMOTE" "HEAD:${local_branch}" >/dev/null 2>&1 ); then
    echo "cc-comms-send: metadata 自律送信 完了 ($rel)"
    exit 0
  else
    err "push 失敗 (commit は済。後で再送可)"; exit 1
  fi
else
  echo "cc-comms-send: business を commit しました（未送信）。送信するには client 承認が必要です:" >&2
  echo "  git -C \"$CC_COMMS_DIR\" push $CC_COMMS_REMOTE HEAD" >&2
  exit 0
fi
