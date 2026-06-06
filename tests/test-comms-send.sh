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
      && ( git push -q -u origin HEAD:refs/heads/main 2>/dev/null \
           || git push -q -u origin HEAD:refs/heads/master 2>/dev/null ) \
      && _branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)" \
      && git branch --set-upstream-to="origin/$_branch" "$_branch" 2>/dev/null )
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

# Case 10 (C-1): business commit 後に metadata 送信を試みると exit 1（business 相乗り防止）
setup
write_msg b_stale.md business "業務相談の未送信コミット"
"$SCRIPT" "$CC_COMMS_DIR/outbox/b_stale.md" >/dev/null 2>&1
# この時点で business commit が 1 件ある（未 push）
write_msg m_after.md metadata "metadata after business"
"$SCRIPT" "$CC_COMMS_DIR/outbox/m_after.md" >/dev/null 2>&1
check "C-1: business 相乗り防止で metadata exit 1" $? 1
# bare に business も metadata も push されていないこと
c1_pushed=$(cd "$bare" && git log --all --oneline 2>/dev/null | grep -cE "b_stale|m_after" || true)
check "C-1: bare に何も push されていない" "$c1_pushed" 0
teardown

# Case 11 (C-2): staged に evil ファイルがあっても msg_file のみ commit される（pathspec 限定）
setup
write_msg c2_clean.md metadata "clean metadata msg"
# 悪意ある別ファイルを stage に乗せる
echo "AKIA_EVIL=not_a_real_key_just_test_c2" > "$CC_COMMS_DIR/evil.txt"
( cd "$CC_COMMS_DIR" && git add -f evil.txt >/dev/null 2>&1 )
"$SCRIPT" "$CC_COMMS_DIR/outbox/c2_clean.md" >/dev/null 2>&1
check "C-2: staged evil あり metadata exits 0" $? 0
# bare の HEAD ツリーに evil.txt が含まれないこと
evil_in_bare=$(git --git-dir="$bare" ls-tree -r --name-only HEAD 2>/dev/null | grep -c "evil.txt" || true)
check "C-2: evil.txt が bare に含まれない" "$evil_in_bare" 0
teardown

# Case 12 (H-3a): kind に内部空白（'meta data'）→ exit 1
setup
cat > "$CC_COMMS_DIR/outbox/h3a.md" <<'MSGEOF'
---
msg_id: h3a-001
direction: client-to-owner
kind: meta data
status: draft
---
body
MSGEOF
"$SCRIPT" "$CC_COMMS_DIR/outbox/h3a.md" >/dev/null 2>&1
check "H-3a: kind='meta data' (内部空白) exits 1" $? 1
teardown

# Case 13 (H-3b): frontmatter に kind: 行が 2 つ → exit 1
setup
cat > "$CC_COMMS_DIR/outbox/h3b.md" <<'MSGEOF'
---
msg_id: h3b-001
direction: client-to-owner
kind: metadata
kind: business
status: draft
---
body
MSGEOF
"$SCRIPT" "$CC_COMMS_DIR/outbox/h3b.md" >/dev/null 2>&1
check "H-3b: kind 行が 2 つ exits 1" $? 1
teardown

# Case 14 (C-1-deep): ローカル remote-tracking ref 改竄 → ls-remote 権威で検出、exit 1 かつ bare 汚染なし
# 攻撃シナリオ: business commit B を未 push のまま、upstream tracking が指す
#   refs/remotes/origin/<upstream_branch> を B に書き換える
#   → 旧ゲート（@{u}ベース）では commit C 後 rev-list B..HEAD = 1 と誤判定して通過する
#   → 新ゲート（ls-remote ベース）では実 remote(=A) 基準で unpushed==2 を検出して中止
setup
# upstream tracking が指す remote branch 名を取得（例: origin/main → main）
_upstream_sym="$(git -C "$work" rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null)"
_upstream_branch="${_upstream_sym#*/}"
# B: business commit（未 push のまま）
write_msg b_deep.md business "未送信 business commit"
"$SCRIPT" "$CC_COMMS_DIR/outbox/b_deep.md" >/dev/null 2>&1
b_sha="$(git -C "$work" rev-parse HEAD 2>/dev/null)"
# 攻撃: upstream tracking が指す refs/remotes/origin/<upstream_branch> を B に書き換え
# これにより @{u} ベースゲートは後続 commit C が乗った後 rev-list B..C = 1 と誤判定する
git -C "$work" update-ref "refs/remotes/origin/$_upstream_branch" "$b_sha" >/dev/null 2>&1
# C: clean metadata commit を送信試行（スクリプト内で commit → gate の順）
write_msg m_deep.md metadata "metadata after local-ref tamper"
"$SCRIPT" "$CC_COMMS_DIR/outbox/m_deep.md" >/dev/null 2>&1
check "C-1-deep: ローカルref改竄後 metadata exit 1" $? 1
# bare に B も C も push されていないこと
c1d_pushed=$(cd "$bare" && git log --all --oneline 2>/dev/null | grep -cE "b_deep|m_deep" || true)
check "C-1-deep: bare に B も C も push されていない" "$c1d_pushed" 0
teardown

echo "---"
[ "$fail" -eq 0 ] && echo "ALL PASS" || echo "SOME FAILED"
exit $fail
