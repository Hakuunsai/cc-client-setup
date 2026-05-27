# cc-client-setup v0.2 - installation guide

v0.2 では PowerShell bootstrap script を廃止 (`Setup-CCClientSetup.ps1` 削除)。Claude Code 自身を agent としてセットアップ実行 (Approach W)。

## 全体フロー

```
[Step 0] office-tada 秘書 Phase A hearing (owner 別 session、10-20 min)
   ↓ kit-prompt-{client-id}.md / seed-client-persona-{client-id}.md / cheatsheet-{client-id}.md 生成
[Step 1] client PC 環境準備 (Claude Code + Git for Windows install)
[Step 2] フォルダ作成 + claude 起動
[Step 3] kit-prompt.md paste → Claude が自律 setup (15-25 min)
[Step 4] 完了確認 + cheatsheet 配布
[Step 5] claude 再起動 + SessionStart hook 確認 (option: client 同席で Phase B hearing 実行)
```

合計 30-40 min (1 PC、Step 0 別途)。

## 詳細手順

詳細は `docs/owner-handoff.md` 参照。本 file は概要のみ。

## Phase B (client hearing) について

owner setup 完了後、`~/.cc-client-memory/seed-client-persona.md` に Phase B marker `<<<CLIENT_HEARING_PENDING>>>` が残ります。次に client が claude 起動した最初の chat で秘書が自律 hearing を主導します (詳細 `hearing-sop-client.md`)。

## 更新時 (kit 改訂)

owner が kit (`Hakuunsai/cc-client-setup`) を改訂した case、client PC に差分適用する手順:

```
[Step 1] owner が改訂 commit を `Hakuunsai/cc-client-setup` に push
[Step 2] owner が `kit-prompt-update.md` を改訂 (差分対象 file を列挙)
[Step 3] owner connect → client PC で claude 起動 → kit-prompt-update.md paste
[Step 4] Claude が差分のみ apply (5-10 min)
[Step 5] claude 再起動で動作確認
```

`seed-client-persona.md` の client 領域 (Phase B 結果) は保護対象、update で overwrite されません。

## Step 11 plugin install 不成功時 (superpowers fallback、v0.4 で追加)

kit-prompt Step 11b で `superpowers` plugin を install する際、初回 `claude` 起動時の auto resolve で install されない case がある (詳細トリガー不明、cache / metadata 同期の問題と推測)。**2026-05-27 demo-001 観察事例**: marketplace update + Claude Code 再起動を 1-2 回繰り返すと install 成功。

### 初回 install fail 時の fallback 手順

owner が client PC で以下を順次手動実行:

```
# 1. marketplace を最新化 (Claude Code 内で)
/plugin marketplace update

# 2. claude を一旦終了 (Ctrl+C → Enter)、再起動
exit
claude

# 3. install 状態確認
/plugin list
```

`superpowers@claude-plugins-official` が `enabled` で表示されれば成功。表示されない場合は再度 `/plugin marketplace update` + claude 再起動を 1 回繰り返す (2-3 回が目安)。

### それでも install されない場合

- **network 確認**: `git clone https://github.com/anthropics/claude-plugins-official.git /tmp/test-clone` を Git Bash で実行、network / proxy 問題切り分け
- **GitHub auth 確認**: claude-plugins-official は public repo、通常 auth 不要だが、企業 PC で network 制限があるなら owner の判断で proxy / certificate 設定
- **owner に相談**: cheatsheet「困ったとき」table 経由で owner 連絡

### 補足 (秘書側挙動)

`superpowers` plugin が install 成功すると、秘書が `brainstorming` / `writing-plans` / `systematic-debugging` / `verification-before-completion` / `receiving-code-review` 等の skill を自律発動する (client は明示指定不要、v0.4 で principle 確立)。install 不成功状態でも `company` plugin の secretary 基本振舞いは動作するため、業務影響は限定的だが、新規依頼の brainstorming / 計画立案の質が低下する。

## トラブルシュート

詳細は `docs/recovery.md` 参照。
