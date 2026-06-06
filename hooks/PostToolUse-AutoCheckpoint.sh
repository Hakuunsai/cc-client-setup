#!/usr/bin/env bash
# Claude Code PostToolUse hook for Edit|Write matcher (Linux variant).
# Auto-checkpoint via git stash (does not move HEAD / affect current branch).
# Recovery: git stash list | grep claude-auto-checkpoint ; git stash apply stash@{N}
# 何が起きても session を止めない (常に exit 0)。

{
  repo_root="$(git rev-parse --show-toplevel 2>/dev/null)"
  [ -z "$repo_root" ] && exit 0
  cd "$repo_root" 2>/dev/null || exit 0

  [ -z "$(git status --porcelain 2>/dev/null)" ] && exit 0

  ts="$(date -Iseconds 2>/dev/null || date +%Y-%m-%dT%H:%M:%S)"
  # push が成功 (= 新規 checkpoint stash 作成) した場合のみ apply。
  # 失敗時に無関係な既存 stash@{0} を誤適用しないため。
  if git stash push -u -m "[claude-auto-checkpoint] $ts" --quiet 2>/dev/null; then
    # --index で staged/unstaged 境界も復元。失敗時は working tree のみ復元に fallback。
    git stash apply --index --quiet 2>/dev/null || git stash apply --quiet 2>/dev/null
  fi
} 2>/dev/null

exit 0
