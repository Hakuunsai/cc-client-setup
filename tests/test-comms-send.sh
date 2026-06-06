#!/usr/bin/env bash
# test: cc-comms-send.sh の secret check(fail-closed) + kind 強制 + 送受信
set +e
SCRIPT="$(cd "$(dirname "$0")/.." && pwd)/hooks/cc-comms-send.sh"
fail=0

setup() {
  work="$(mktemp -d)"
  bare="$(mktemp -d)/remote.git"
  git init -q --bare "$bare"
  git init -q "$work"
  ( cd "$work" && git config user.email t@e && git config user.name t \
      && git remote add origin "$bare" \
      && mkdir -p outbox inbox archive && touch outbox/.gitkeep \
      && git add -A && git commit -qm init \
      && git push -q origin HEAD:refs/heads/main 2>/dev/null \
      || git push -q origin HEAD:refs/heads/master 2>/dev/null )
  export CC_COMMS_DIR="$work"
  export CC_COMMS_REMOTE="origin"
}
teardown() {
  local bare_parent
  bare_parent="$(dirname "$bare")"
  rm -rf "$work" "$bare_parent"
  unset CC_COMMS_DIR CC_COMMS_REMOTE
}

write_msg() { # $1=file $2=kind $3=body
  cat > "$CC_COMMS_DIR/outbox/$1" <<EOF
---
msg_id: test-001
direction: client-to-owner
kind: $2
status: draft
---
$3
EOF
}

check() { # desc, actual_rc, expected_rc
  if [ "$2" -eq "$3" ]; then echo "PASS: $1"; else echo "FAIL: $1 (rc=$2 want=$3)"; fail=1; fi
}

# Case 1: metadata + clean → exit 0 + pushed
setup
write_msg m1.md metadata "kit version check, no secrets here"
"$SCRIPT" "$CC_COMMS_DIR/outbox/m1.md" >/dev/null 2>&1
check "metadata clean exits 0" $? 0
# work repo から remote tracking branch を fetch して push 済みか確認
( cd "$CC_COMMS_DIR" && git fetch -q "$CC_COMMS_REMOTE" 2>/dev/null )
pushed=$(cd "$CC_COMMS_DIR" && git log --remotes --oneline 2>/dev/null | grep -c "m1")
check "metadata was pushed" "$pushed" 1
teardown

# Case 2: business + clean → exit 0 + NOT pushed (committed only)
setup
write_msg b1.md business "顧客Aの売上状況について相談"
"$SCRIPT" "$CC_COMMS_DIR/outbox/b1.md" >/dev/null 2>&1
check "business clean exits 0" $? 0
# bare repo には b1.md コミットが届いていないこと
b_pushed=$(cd "$bare" && git log --all --oneline 2>/dev/null | grep -c "b1" )
check "business NOT pushed" "$b_pushed" 0
# local repo には commit が存在すること
b_local=$(cd "$CC_COMMS_DIR" && git log --oneline 2>/dev/null | grep -c "b1" )
check "business committed locally" "$b_local" 1
teardown

# Case 3: secret in payload → refuse (exit 1)
setup
write_msg s1.md metadata "token AKIA0123456789ABCDEF leaked"
"$SCRIPT" "$CC_COMMS_DIR/outbox/s1.md" >/dev/null 2>&1
check "secret refused exits 1" $? 1
teardown

# Case 4: invalid kind → refuse (exit 1)
setup
write_msg x1.md unknownkind "body"
"$SCRIPT" "$CC_COMMS_DIR/outbox/x1.md" >/dev/null 2>&1
check "invalid kind exits 1" $? 1
teardown

# Case 5: missing file → refuse (fail-closed, exit 1)
setup
"$SCRIPT" "$CC_COMMS_DIR/outbox/nope.md" >/dev/null 2>&1
check "missing file exits 1" $? 1
teardown

# Case 6: case-insensitive secret 検出（Password= 大文字P → 修正3 を lock）
setup
write_msg pw.md metadata 'Password="supersecret123"'
"$SCRIPT" "$CC_COMMS_DIR/outbox/pw.md" >/dev/null 2>&1
check "case-insensitive secret refused exits 1" $? 1
teardown

# Case 7: inbox に stray ファイルがあっても msg_file のみコミット・bare に inbox/junk.md が含まれない（修正1 を lock）
setup
write_msg clean.md metadata "kit version check, no secrets here"
echo "stray" > "$CC_COMMS_DIR/inbox/junk.md"   # 未コミットの stray ファイル
"$SCRIPT" "$CC_COMMS_DIR/outbox/clean.md" >/dev/null 2>&1
check "inbox stray: send exits 0" $? 0
# bare から HEAD の tree を確認して inbox/junk.md が含まれていないこと
# git -C で bare を操作すると safe.bareRepository=explicit で失敗するため --git-dir を使う
junk_in_bare=$(git --git-dir="$bare" ls-tree -r --name-only HEAD 2>/dev/null | grep -c "inbox/junk.md" || true)
check "inbox/junk.md not pushed to bare" "$junk_in_bare" 0
teardown

# Case 8: inbox 配下のパスを渡すと拒否 (exit 1) — F-1 path validation lock
setup
mkdir -p "$CC_COMMS_DIR/inbox"
cat > "$CC_COMMS_DIR/inbox/evil.md" <<'MSGEOF'
---
msg_id: evil-001
direction: client-to-owner
kind: metadata
status: draft
---
should be rejected
MSGEOF
"$SCRIPT" "$CC_COMMS_DIR/inbox/evil.md" >/dev/null 2>&1
check "inbox path rejected exits 1" $? 1
teardown

# Case 9: path traversal (outbox/../inbox) を渡すと拒否 (exit 1) — F-1 path traversal lock
setup
mkdir -p "$CC_COMMS_DIR/inbox"
cat > "$CC_COMMS_DIR/inbox/evil.md" <<'MSGEOF'
---
msg_id: evil-002
direction: client-to-owner
kind: metadata
status: draft
---
should be rejected via traversal
MSGEOF
"$SCRIPT" "$CC_COMMS_DIR/outbox/../inbox/evil.md" >/dev/null 2>&1
check "path traversal rejected exits 1" $? 1
teardown

echo "---"
[ "$fail" -eq 0 ] && echo "ALL PASS" || echo "SOME FAILED"
exit $fail
