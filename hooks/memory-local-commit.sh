#!/usr/bin/env bash
# Stop hook: ~/.cc-client-memory/ に client PC 内 local commit のみ (remote 連携 0)。
# cc-client-setup v0.2 spec Section 2.4 (remote 連携 0、local commit のみ) 由来。
# client が「Claude が壊した」case で git log + git reset で復旧可能化。
# 失敗しても session 締めを妨げない (|| true で吸収)。

MEMORY_DIR="$HOME/.cc-client-memory"

# memory dir 不在なら skip (initial setup 前 / 削除済 case)
[ ! -d "$MEMORY_DIR/.git" ] && exit 0

cd "$MEMORY_DIR" || exit 0

# 変更がなければ skip
if ! git diff --quiet HEAD 2>/dev/null || ! git diff --cached --quiet 2>/dev/null || [ -n "$(git ls-files --others --exclude-standard)" ]; then
  git add -A 2>/dev/null
  git commit -m "[local-auto] $(date -Iseconds)" --allow-empty > /dev/null 2>&1 || true
fi

exit 0
