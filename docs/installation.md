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

## Step 11.5 / 11.6 (v0.5 新規): Codex 実体配備 + OAuth login

### Step 11.5 (Codex CLI install) が失敗する場合

- **Node.js install fail (winget)**:
  - owner manual で `winget install OpenJS.NodeJS.LTS` を terminal で実行、または公式 installer (`https://nodejs.org/`) で install
  - 新 terminal を開いて PATH 反映確認 (`node --version` 反応すれば OK)
- **`npm install -g @openai/codex` fail**:
  - owner manual で `npm install -g @openai/codex` を terminal (新 shell 推奨) で実行
  - permission error の場合 PowerShell を「管理者として実行」で再試行
  - それでも fail の場合は degraded mode で運用継続 (= v0.4 機能は全動作、Codex 委譲のみ無効)

### Step 11.6 (owner manual `codex login`)

1. terminal (PowerShell or Git Bash) で `codex login` 実行
2. ブラウザが自動で開く (`https://chat.openai.com/...`)
3. ChatGPT アカウント (Plus / Pro / Enterprise) で login
4. ブラウザに「Authentication successful」表示 + terminal close
5. 配備確認: `Test-Path $HOME\.codex\auth.json` (PowerShell) or `ls ~/.codex/auth.json` (Bash) で存在確認

**login が失敗する場合**:
- ChatGPT アカウントを保持していない場合 → ChatGPT Plus 加入が必要 (`https://chat.openai.com/`)
- ブラウザが開かない → terminal 出力の URL を手動で browser に paste
- network 制限環境 → owner の VPN / network 設定確認

**login 後の運用**:
- 認証 token は `~/.codex/auth.json` に cache、自動 refresh
- 期限切れ時は秘書が「`codex login` を再実行してください」と業務言語で案内 (cheatsheet「困ったとき」case 経由)
- token 流出回避: `~/.codex/auth.json` は forbidden-files で保護済、秘書も Codex も触らない

### 補足 (秘書側挙動)

Codex CLI + `codex@openai-codex` plugin が install 成功すると、秘書が以下を自動発動:

- **Codex review (mcp__codex__codex 経由)**: コード変更を伴う完了報告の直前 / git commit 指示時 / 「レビューして」明示 → 「別の AI (Codex) にダブルチェックさせます」予告 + 委譲
- **Codex 実装委譲 (mcp__codex__codex 経由)**: 中規模以上の実装 task / stuck / second pass 必要 / 「Codex に任せて」明示 → 「別の AI (Codex) に始めから書いてもらいます」予告 + client 了承後に委譲

詳細規律: `~/.claude/CLAUDE.md` 「6 柱」§6 + `templates/secretary-claude.md.template` Codex 委譲規律 section 参照。

Codex 利用不能時 (認証切れ / network / rate limit / 応答なし) はユーザー = 秘書二者で対処、owner connect は使わない (秘書視点 owner 不存在 principle 徹底適用、v0.3 owner ruling 由来)。

## トラブルシュート

詳細は `docs/recovery.md` 参照。
