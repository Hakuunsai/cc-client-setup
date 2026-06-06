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

# --- msg_file が outbox/ 配下に限定（path traversal / 外部パス / inbox 巻き込みを拒否）---
msg_dir_abs="$(cd "$(dirname "$msg_file")" 2>/dev/null && pwd -P)"
comms_abs="$(cd "$CC_COMMS_DIR" 2>/dev/null && pwd -P)"
case "$msg_dir_abs/" in
  "$comms_abs"/outbox/*) ;;
  "$comms_abs"/outbox/) ;;
  *) err "msg ファイルは \$CC_COMMS_DIR/outbox/ 配下に限定 (fail-closed): $msg_file"; exit 1 ;;
esac

# --- kind 取得（frontmatter ブロック内に厳密 1 行 — H-3 strict singleton）---
# frontmatter ブロック（先頭 '---' 〜 次 '---'）内の kind を厳密に取得
fm="$(awk 'NR==1&&/^---[[:space:]]*$/{f=1;next} f&&/^---[[:space:]]*$/{exit} f{print}' "$msg_file" 2>/dev/null)"
kind_count="$(printf '%s\n' "$fm" | grep -cE '^kind:' 2>/dev/null)"
[ "$kind_count" = "1" ] || { err "kind は frontmatter 内に厳密 1 行 (検出=$kind_count, fail-closed)"; exit 1; }
# 値は前後空白のみ trim、内部空白は残す（'meta data' 等を弾く）
kind="$(printf '%s\n' "$fm" | grep -E '^kind:' | head -1 | sed -E 's/^kind:[[:space:]]*//; s/[[:space:]]+$//')"
case "$kind" in
  metadata|business) ;;
  *) err "kind は metadata|business のみ (取得='$kind', fail-closed)"; exit 1 ;;
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

# --- commit（pathspec 限定: msg_file のみ commit — C-2 staged 全体 commit 防止）---
rel="$(basename "$msg_file")"
( cd "$CC_COMMS_DIR" && git add -- "$msg_file" >/dev/null 2>&1 \
    && git commit -qm "[cc-comms] send $kind $rel" -- "$msg_file" >/dev/null 2>&1 ) || {
  err "commit 失敗 (fail-closed)"; exit 1; }

# --- kind による push 分岐 ---
if [ "$kind" = "metadata" ]; then
  # C-1: 未送信 commit が今の 1 件のみであることを保証（business 相乗り防止）
  upstream="$(cd "$CC_COMMS_DIR" && git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null)"
  [ -n "$upstream" ] || { err "upstream 未設定 (fail-closed): metadata 自律 push 不可"; exit 1; }
  unpushed="$(cd "$CC_COMMS_DIR" && git rev-list "$upstream"..HEAD --count 2>/dev/null)"
  if [ "$unpushed" != "1" ]; then
    err "未送信 commit が他にあります (unpushed=$unpushed)。business 相乗り防止のため metadata 自律送信を中止 (fail-closed)。先に未送信分を解決してください"; exit 1
  fi
  local_branch="$(cd "$CC_COMMS_DIR" && git rev-parse --abbrev-ref HEAD 2>/dev/null)"
  if ( cd "$CC_COMMS_DIR" && git push -q "$CC_COMMS_REMOTE" "HEAD:${local_branch}" >/dev/null 2>&1 ); then
    echo "cc-comms-send: metadata 自律送信 完了 ($rel)"
    exit 0
  else
    err "push 失敗 (commit は済。後で再送可)"; exit 1
  fi
else
  # H-1: business 承認 push 案内 — 'cd ... && git push' 形式で Bash(git push:*) ask にマッチ
  echo "cc-comms-send: business を commit しました（未送信）。送信するには client 承認が必要です:" >&2
  echo "  cd ~/.cc-client-comms && git push" >&2
  exit 0
fi
