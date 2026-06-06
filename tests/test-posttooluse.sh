#!/usr/bin/env bash
# Test: PostToolUse-AutoCheckpoint.sh
set -u
HOOK="$(cd "$(dirname "$0")/.." && pwd)/hooks/PostToolUse-AutoCheckpoint.sh"
fail=0
tmp="$(mktemp -d)"
(
  cd "$tmp" || exit 1
  git init -q
  git config user.email t@example.com
  git config user.name test
  echo "initial" > a.txt
  git add a.txt
  git commit -qm init
  # 変更を作る
  echo "changed" >> a.txt
  bash "$HOOK" >/dev/null 2>&1
  if git stash list | grep -q 'claude-auto-checkpoint'; then
    echo "PASS: auto-checkpoint stash created"
  else
    echo "FAIL: no auto-checkpoint stash"; exit 1
  fi
) || fail=1
rm -rf "$tmp"
exit $fail
