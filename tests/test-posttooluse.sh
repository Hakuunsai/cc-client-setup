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

  # staged な変更 (a.txt 更新 + 新規 b.txt) と untracked c.txt を用意
  echo "staged change" >> a.txt
  git add a.txt
  echo "new staged" > b.txt
  git add b.txt
  echo "untracked" > c.txt

  bash "$HOOK" >/dev/null 2>&1

  # 1) auto-checkpoint stash が作成された
  if git stash list | grep -q 'claude-auto-checkpoint'; then
    echo "PASS: auto-checkpoint stash created"
  else
    echo "FAIL: no auto-checkpoint stash"; exit 1
  fi

  # 2) staged 状態が保持されている (--index)。a.txt と b.txt が index に残る (Codex Finding 3)
  staged_now="$(git diff --cached --name-only | sort | tr '\n' ' ')"
  if [ "$staged_now" = "a.txt b.txt " ]; then
    echo "PASS: staged state preserved (--index): [$staged_now]"
  else
    echo "FAIL: staged state lost, got [$staged_now]"; exit 1
  fi

  # 3) working tree の内容も復元されている (untracked c.txt が残る)
  if [ -f c.txt ] && grep -q "staged change" a.txt; then
    echo "PASS: working tree restored"
  else
    echo "FAIL: working tree not restored"; exit 1
  fi
) || fail=1
rm -rf "$tmp"
exit $fail
