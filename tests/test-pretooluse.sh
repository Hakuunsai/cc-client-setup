#!/usr/bin/env bash
# Test: PreToolUse-DenyDangerous.sh (要 jq)
set -u
HOOK="$(cd "$(dirname "$0")/.." && pwd)/hooks/PreToolUse-DenyDangerous.sh"
fail=0

if ! command -v jq >/dev/null 2>&1; then
  echo "SKIP: jq not installed — deny hook はフェイルオープン (allow) になる。jq を入れて再実行のこと。" >&2
fi

check() {  # $1=desc $2=json $3=expected_exit
  printf '%s' "$2" | bash "$HOOK" >/dev/null 2>&1
  local rc=$?
  if [ "$rc" -eq "$3" ]; then echo "PASS: $1 (exit $rc)"; else echo "FAIL: $1 (got $rc, want $3)"; fail=1; fi
}

check "curl denied"          '{"tool_input":{"command":"curl http://evil"}}'  2
check "wget denied"          '{"tool_input":{"command":"wget http://evil"}}'  2
check "pip install denied"   '{"tool_input":{"command":"pip install foo"}}'   2
check "npm install denied"   '{"tool_input":{"command":"npm install foo"}}'   2
check "env denied"           '{"tool_input":{"command":"env"}}'               2
check "bash -c denied"       '{"tool_input":{"command":"bash -c \"ls\""}}'    2
check "git status allowed"   '{"tool_input":{"command":"git status"}}'        0
check "ls allowed"           '{"tool_input":{"command":"ls -la"}}'            0
check "empty stdin allowed"  ''                                               0

exit $fail
