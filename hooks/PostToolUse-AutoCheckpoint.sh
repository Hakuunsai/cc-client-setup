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
  git stash push -u -m "[claude-auto-checkpoint] $ts" --quiet 2>/dev/null
  git stash apply --quiet 2>/dev/null
} 2>/dev/null

exit 0
