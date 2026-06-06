# cc-client-setup v0.7 (Linux) - Claude Code Self-Setup Prompt (Codex 委譲統合 + self-update)

このプロンプトは Claude Code (あなた) が、Linux サーバー上に Claude Code 環境を
自律でセットアップするための指示書です。owner ご了承前提、本指示書を実行することを承諾します。

**Windows native 環境では `kit-prompt.md` (v0.6) を使用してください。本 file は Linux (RHEL/Rocky/Alma 系) + VSCode Remote-SSH + Claude Code 拡張 構成専用です。**

## 前提

- **本セッション cwd** = `~/source/{company-name}/` (owner が作成済)
- **Claude Code** = 素の状態で install 済 (plugin / hook / settings 未設定)、Linux サーバー上で動作 (VSCode 拡張は Remote-SSH 越しにこのリモート Claude を使う)
- **git / jq** = install 済 (`sudo dnf install -y git jq`)。`jq` は PreToolUse hook の JSON 抽出に使用
- **bash** = native (Linux 標準)。hook は全て bash で動作
- **kit raw URL prefix** = `https://raw.githubusercontent.com/Hakuunsai/cc-client-setup/main/`
- **owner** = この環境に setup を代行する人物 (= 私の owner)
- **client** = この環境の最終 user (プログラミング未経験、業務知識あり)。日常は VSCode を開いて Claude 拡張パネルで会話するだけ

## per-client placeholders (owner が paste 前に置換、office-tada 秘書 Phase A hearing で取得)

- `{COMPANY_NAME}` = クライアント企業名 (例: 「株式会社サンプル」)
- `{OWNER_CONTACT}` = cheatsheet 用 owner 連絡先 (例: 「email: owner@example.com / 受付時間: 平日 9:00-18:00」)
- `{CLIENT_OWNER_SEED_BLOCK}` = owner hearing 結果 (Q-owner-1〜4 全 4 件)、`seed-client-persona.md` owner 領域に注入される markdown block (約 4-8 行)

※ client 業務情報 (業務概要 / 業務範囲 / 業界 common sense) は Phase B (client PC 秘書) で client 本人が答えるため、本 kit-prompt 内には含めない (marker placeholder で wait)。

## あなたの仕事 (冪等で実行、既存 file は backup + overwrite)

下記 Step 1-14 を上から順に冪等に実行してください。各 Step で対象 file が既に存在し内容一致なら skip、差分なら `*.bak.YYYYMMDDTHHmmss` に backup 後 overwrite してください。permission ask が出たら owner に確認してください (auto mode 中なら自動で acceptEdits)。

- [ ] **Step 1**: `~/.claude/rules/` に 3 file 配置 (security-essentials.md / forbidden-files.md / network-security.md)
- [ ] **Step 2**: `~/.claude/CLAUDE.md` 配置 (姿勢英文 + ペルソナ + 6 柱 + 自動記録規律 + Codex 自動委譲規律)
- [ ] **Step 3**: `~/.claude/settings.json` 配置 (plugins + hooks 4 種 (全 bash) + permissions + `autoMemoryDirectory: "~/.cc-client-memory"`)
- [ ] **Step 4**: `~/.claude/hooks/` に 4 hook script 配置 (全 .sh: inject-auto-company-skill.sh / memory-local-commit.sh / PreToolUse-DenyDangerous.sh / PostToolUse-AutoCheckpoint.sh) + `chmod +x`
- [ ] **Step 5**: `~/.cc-client-memory/` 配置 (mkdir + git init + 3 baseline seed copy + seed-client-persona.md (owner 領域実値 + Phase B marker 注入) + 初回 commit)
- [ ] **Step 6**: `.claude/settings.json` 配置 (cwd 相対、空テンプレ、user-wide override 用)
- [ ] **Step 7**: `CLAUDE.md` 配置 (cwd 相対、姿勢英文 + ペルソナ + 業務概要 marker)
- [ ] **Step 8**: `.gitignore` 配置 (cwd 相対、言語中立)
- [ ] **Step 9**: cwd で git init (未 init なら) + `.git/hooks/pre-commit` (単一 bash file) 配置 + `chmod +x` + 初回 commit
- [ ] **Step 10**: `.company/secretary/` 配置 (cwd 相対、CLAUDE.md + 空 inbox/todos/notes、cc-company plugin 利用前提)
- [ ] **Step 11a (Claude 自動)**: `~/.claude/skills/git-workflow/SKILL.md` 配置 (direct skill 配置)
- [ ] **Step 11b (owner manual)**: plugin install (`/plugin marketplace add` + `/plugin install` × 3 = cc-company + superpowers + codex)
- [ ] **Step 11.5 (owner manual)**: Codex 実体配備 (Node.js install + `@openai/codex` CLI install + 配備確認)
- [ ] **Step 11.6 (owner manual)**: `codex login` OAuth flow 案内 (ブラウザ login)、`~/.codex/auth.json` 配備確認
- [ ] **Step 12**: 完了確認 (各配置物 grep + 4 hook 存在 + 実行権限 + plugin enabled state + Phase B marker 存在 + jq 存在 + Codex 実体配備)
- [ ] **Step 13**: cheatsheet 出力 (Linux 版 placeholder 置換版を chat に出力、owner が印刷 / PDF 化して client に渡す)
- [ ] **Step 14**: Phase B + Codex + self-update 状況説明 (owner に)

## 各 Step の具体 command

### Step 1: `~/.claude/rules/` に 3 file 配置

```bash
mkdir -p ~/.claude/rules
```

3 file それぞれ:
- WebFetch `{kit raw URL prefix}/templates/claude-rules/security-essentials.md` → Write `~/.claude/rules/security-essentials.md`
- WebFetch `{kit raw URL prefix}/templates/claude-rules/forbidden-files.md` → Write `~/.claude/rules/forbidden-files.md`
- WebFetch `{kit raw URL prefix}/templates/claude-rules/network-security.md` → Write `~/.claude/rules/network-security.md`

既存 file あれば `mv original original.bak.$(date +%Y%m%dT%H%M%S)` で backup 後 Write。

### Step 2: `~/.claude/CLAUDE.md` 配置 (姿勢 + ペルソナ + 6 柱)

```bash
# 既存あれば backup
[ -f ~/.claude/CLAUDE.md ] && mv ~/.claude/CLAUDE.md ~/.claude/CLAUDE.md.bak.$(date +%Y%m%dT%H%M%S)
```

WebFetch `{kit raw URL prefix}/templates/claude-md-user.template` → 取得した template の placeholder を置換 (`{COMPANY_NAME}` を実値で置換) → Write `~/.claude/CLAUDE.md`。

### Step 3: `~/.claude/settings.json` 配置 (Linux 版)

```bash
[ -f ~/.claude/settings.json ] && mv ~/.claude/settings.json ~/.claude/settings.json.bak.$(date +%Y%m%dT%H%M%S)
```

WebFetch `{kit raw URL prefix}/templates/settings-user.linux.json.template` → 取得した template の `<USER_HOME>` placeholder を `$HOME` の実値 (例: `/home/{user}`) で全置換 → Write `~/.claude/settings.json`。

(hook 登録は全て `bash <USER_HOME>/.claude/hooks/*.sh`。Windows 版の `pwsh.exe` は使わない)

### Step 4: `~/.claude/hooks/` に 4 hook script 配置 (全 .sh)

```bash
mkdir -p ~/.claude/hooks
```

4 hook それぞれ WebFetch + Write:
- `inject-auto-company-skill.sh` → `~/.claude/hooks/inject-auto-company-skill.sh`
- `memory-local-commit.sh` → `~/.claude/hooks/memory-local-commit.sh`
- `PreToolUse-DenyDangerous.sh` → `~/.claude/hooks/PreToolUse-DenyDangerous.sh`
- `PostToolUse-AutoCheckpoint.sh` → `~/.claude/hooks/PostToolUse-AutoCheckpoint.sh`

既存 file あれば backup。配置後、実行権限を付与:

```bash
chmod +x ~/.claude/hooks/*.sh
```

### Step 5: `~/.cc-client-memory/` 配置

```bash
mkdir -p ~/.cc-client-memory
cd ~/.cc-client-memory
git init -b main
```

baseline 3 file (kit raw URL prefix `/templates/memory-seed/` 配下):
- WebFetch `seed-baseline-security.md` → Write `~/.cc-client-memory/seed-baseline-security.md`
- WebFetch `seed-baseline-implementation-gate.md` → 同上
- WebFetch `seed-baseline-secretary-posture.md` → 同上

client persona:
- WebFetch `seed-client-persona.md.template` → 取得した template の Phase A placeholder (`<<<COMPANY_NAME>>>` / `<<<MAIN_CONTACT>>>` / `<<<LEGACY_SYSTEM>>>` / `<<<OWNER_CONTACT>>>` の 4 件、+ frontmatter の `<<<PHASE_A_COMPLETED_AT>>>`) を `{CLIENT_OWNER_SEED_BLOCK}` の実値で置換 → Phase B 領域は marker `<<<CLIENT_HEARING_PENDING>>>` のまま保持 → Write `~/.cc-client-memory/seed-client-persona.md`

```bash
cd ~/.cc-client-memory
git add -A
git commit -m "Initial seed (owner Phase A complete, client Phase B pending)"
```

### Step 6: `.claude/settings.json` 配置 (cwd 相対)

(本セッション cwd = `~/source/{company-name}/` 想定、以下 Step 6-10/12 の全 path は cwd 相対で記述。`{company-name}/` 前置は付けないこと。付けると `~/source/{company-name}/{company-name}/.claude/` の二重 path になる)

```bash
mkdir -p .claude
```

WebFetch `{kit raw URL prefix}/templates/settings-project.json.template` → Write `.claude/settings.json`。空テンプレ (user-wide override 用)。

### Step 7: `CLAUDE.md` 配置 (cwd 相対)

WebFetch `{kit raw URL prefix}/templates/claude-md-project.template` → 取得した template の placeholder 置換:
- `{COMPANY_NAME}` を実値置換
→ Write `CLAUDE.md` (cwd 直下)

### Step 8: `.gitignore` 配置 (cwd 相対)

WebFetch `{kit raw URL prefix}/templates/gitignore.template` → Write `.gitignore` (言語中立)

### Step 9: git init + pre-commit 配置 (単一 bash file)

```bash
[ ! -d .git ] && git init -b main
mkdir -p .git/hooks
```

**pre-commit (bash 本体)** を WebFetch + Write:
- WebFetch `{kit raw URL prefix}/templates/pre-commit.sh.template` → Write `.git/hooks/pre-commit`

```bash
chmod +x .git/hooks/pre-commit
git add .claude/ CLAUDE.md .gitignore
git commit -m "Initial setup ({company-name} workspace)"
```

(Linux の git は `.git/hooks/pre-commit` を直接実行するため、Windows 版の sh shim → pwsh.exe 2-file layout は不要。単一 bash file で完結)

### Step 10: `.company/secretary/` 配置 (cwd 相対)

```bash
mkdir -p .company/secretary/inbox
mkdir -p .company/secretary/todos
mkdir -p .company/secretary/notes
```

WebFetch `{kit raw URL prefix}/templates/secretary-claude.md.template` → Write `.company/secretary/CLAUDE.md`

`.gitkeep` 配置:
```bash
touch .company/secretary/inbox/.gitkeep
touch .company/secretary/todos/.gitkeep
touch .company/secretary/notes/.gitkeep
```

```bash
git add .company/
git commit -m "Add secretary dir (cc-company integration)"
```

### Step 11a: `~/.claude/skills/git-workflow/SKILL.md` 配置 (direct skill、Claude 自動実行可)

cc-company marketplace は `company` plugin のみ提供のため、git-workflow は direct skill 経路で配備する。

```bash
mkdir -p ~/.claude/skills/git-workflow
```

WebFetch `{kit raw URL prefix}/templates/claude-skills/git-workflow/SKILL.md` → Write `~/.claude/skills/git-workflow/SKILL.md`。既存 file あれば `*.bak.YYYYMMDDTHHmmss` backup 後 overwrite。

配置後、Claude Code は次セッション以降で `git-workflow` skill を `Skill` tool 経由で自動発動可能になる。

### Step 11b: plugin install (cc-company + superpowers + codex) — ⚠️ owner manual step

**重要**: `/plugin marketplace add` / `/plugin install` 等の slash command は Claude tool 呼び出しから発動できません (user 入力起点のみ)。Claude (あなた) は本 Step を直接実行できず、**owner に手動依頼**してください。

settings.json には Step 3 で `extraKnownMarketplaces` + `enabledPlugins` を宣言済のため、**次回 Claude Code 起動時に auto resolve される可能性あり**。Auto resolve 成功時は本 Step 全 skip 可。

**注意**: superpowers は初回起動時に auto resolve されない case がある。**marketplace update + Claude Code (VSCode 拡張) 再起動を 1-2 回繰り返すと install 成功**することが確認されている。2-3 回繰り返しても install されない場合は GitHub auth / network 設定を確認 (詳細: `docs/installation.md` の Step 11 補足 section)。

Auto resolve しない / 確認したい case は、owner が新しい claude session で以下を順次手動実行:

```
/plugin marketplace add Shin-sibainu/cc-company
/plugin marketplace add anthropics/claude-plugins-official
/plugin marketplace add openai/codex-plugin-cc
/plugin install company@cc-company
/plugin install superpowers@claude-plugins-official
/plugin install codex@openai-codex
/plugin list
```

完了後、`/plugin list` で 3 plugin (company + superpowers + codex) が enabled 状態であることを確認。git-workflow は plugin ではなく direct skill (Step 11a で配置済) のため `/plugin list` には表示されない。

Claude (あなた) の Step 11b 完了報告は「owner に slash command 7 行を案内した」で OK。

### Step 11.5: Codex 実体配備 (owner manual)

Codex CLI を Linux に install します。Step 11b の plugin install (`codex@openai-codex`) と pair で動作 (plugin = Claude Code から `mcp__codex__codex` tool を呼ぶ経路、CLI = 実体実行 binary)。

**owner manual**: `sudo dnf install` (sudo 権限が必要) と `npm install -g` (settings.json deny `Bash(npm install:*)` で Claude からは block) のため、owner が terminal で手動実行:

```bash
# Node.js install (既 install ならバージョン確認のみ)
node --version 2>/dev/null || sudo dnf install -y nodejs
# (NodeSource / nvm でも可。企業 repo 制約があれば nvm を推奨)

# Codex CLI install
codex --version 2>/dev/null || npm install -g @openai/codex
# (npm permission error の場合は nvm 環境 or sudo で再試行)

# 配備確認
node --version && codex --version
```

Claude (あなた) は owner に上記コマンドを案内し、owner 実行後に `codex --version` の結果を確認。

**失敗時**: Node/Codex 不在は Step 12 配備確認に degraded mode flag を立て、Codex なし運用継続 (= 他機能は全動作する)。kit-prompt 完走自体は継続。

### Step 11.6: `codex login` OAuth flow 案内 (owner manual)

**重要**: `codex login` はブラウザ OAuth flow を起動する human-in-the-loop step、自動化不可。Claude (あなた) は本 Step を直接実行できず、**owner に手動依頼**してください。

owner に以下を chat 出力で案内:

```
Codex CLI の認証を 1 度だけ手動で実施してください:

1. terminal で `codex login` 実行
2. ブラウザが開く (`https://chat.openai.com/...` の OAuth login 画面)
   - リモートサーバーで browser が開かない場合は、terminal 出力の URL を手元の browser に paste
3. ChatGPT アカウント (Plus / Pro / Enterprise) で login
4. ブラウザに「Authentication successful」表示
5. 配備確認: `[ -f ~/.codex/auth.json ] && echo "OK"`

login 完了後、本 kit-prompt 実行を再開してください (秘書に「Codex login 完了しました」と伝達)。

login が失敗する場合:
- ChatGPT アカウント未保有 → ChatGPT Plus 加入が必要 (`https://chat.openai.com/`)
- リモートで browser が開かない → URL を手元 browser に paste
- network 制限環境 → owner の VPN / network 設定確認
```

**配備確認**: owner が「login 完了」と伝達した後、Claude (あなた) は `[ -f ~/.codex/auth.json ]` を確認。true なら次の Step、false なら Step 12 配備確認に未完了 flag を立てるが kit-prompt 自体は完走継続。

### Step 12: 完了確認

```bash
# 配置物 grep
test -f ~/.claude/rules/security-essentials.md && \
test -f ~/.claude/rules/forbidden-files.md && \
test -f ~/.claude/rules/network-security.md && \
test -f ~/.claude/CLAUDE.md && \
test -f ~/.claude/settings.json && \
test -x ~/.claude/hooks/inject-auto-company-skill.sh && \
test -x ~/.claude/hooks/memory-local-commit.sh && \
test -x ~/.claude/hooks/PreToolUse-DenyDangerous.sh && \
test -x ~/.claude/hooks/PostToolUse-AutoCheckpoint.sh && \
test -d ~/.cc-client-memory/.git && \
test -f ~/.cc-client-memory/seed-baseline-security.md && \
test -f ~/.cc-client-memory/seed-baseline-implementation-gate.md && \
test -f ~/.cc-client-memory/seed-baseline-secretary-posture.md && \
test -f ~/.cc-client-memory/seed-client-persona.md && \
test -f ~/.claude/skills/git-workflow/SKILL.md && \
test -d .git && \
test -f CLAUDE.md && \
test -f .gitignore && \
test -x .git/hooks/pre-commit && \
test -d .company/secretary && \
echo "全配置物 OK"

# Phase B marker 存在確認
grep -q "<<<CLIENT_HEARING_PENDING>>>" ~/.cc-client-memory/seed-client-persona.md && echo "Phase B marker OK"

# jq 存在確認 (PreToolUse deny hook の前提)
command -v jq >/dev/null 2>&1 && echo "jq OK" || echo "jq NG (PreToolUse deny がフェイルオープン、sudo dnf install -y jq を案内)"

# Codex 配備確認 (失敗時は degraded mode flag のみ、kit-prompt 完走継続)
echo "--- Codex 配備確認 ---"
node --version >/dev/null 2>&1 && echo "Node.js OK" || echo "Node.js NG (degraded mode)"
codex --version >/dev/null 2>&1 && echo "Codex CLI OK" || echo "Codex CLI NG (degraded mode)"
[ -f ~/.codex/auth.json ] && echo "codex login OK" || echo "codex login 未完了 (Step 11.6 owner manual を再実行案内)"
grep -q "codex@openai-codex" ~/.claude/settings.json && echo "Codex plugin enabled state OK" || echo "Codex plugin enabled state NG"
```

基本 + jq + Codex 配備が OK 表示されること。jq NG は `sudo dnf install -y jq` を案内。Codex 関連 NG は degraded mode で運用継続 (= 他機能は全動作、Codex 委譲のみ無効)。

### Step 13: cheatsheet 出力 (chat に)

WebFetch `{kit raw URL prefix}/docs/client-cheatsheet.linux.md.template` → 取得した template の placeholder (`{COMPANY_NAME}` / `{OWNER_CONTACT}`) を実値で置換 → chat に出力 (Markdown 形式)。

owner は出力を copy → Word / PDF / 紙印刷で client に渡す。

(Linux 版 cheatsheet は起動方法が「VSCode を開く → 自動接続 → Claude 拡張パネルで会話」になっている点が Windows 版との差分)

### Step 14: Phase B 状況説明 (owner に)

chat に以下を出力:

```
✅ cc-client-setup v0.7 (Linux) setup 完了

【配置物】
- ~/.claude/{rules, CLAUDE.md, settings.json, hooks/} : rules 3 + CLAUDE.md 1 + settings.json 1 + hooks 4 (全 .sh、実行権限付与済)
- ~/.cc-client-memory/ : 4 seed file (3 baseline + 1 client persona = owner 領域実値 + Phase B marker)
- {company-name}/ : .claude/settings.json + CLAUDE.md + .gitignore + .git/hooks/pre-commit (単一 bash) + .company/secretary/
- enabled plugin : 3 (company + superpowers + codex) + direct skill : 1 (git-workflow)
- Codex CLI : Node.js + @openai/codex install + `codex login` OAuth (~/.codex/auth.json cache)

【秘書振舞い】 ✅ 自動発動規律配備済
- skill 自動発動 (brainstorming / writing-plans / systematic-debugging / verification-before-completion / receiving-code-review / requesting-code-review / dispatching-parallel-agents / git-workflow を秘書自律発動)
- Codex 自動委譲 (review + 実装委譲 を秘書判断 + explicit 予告 + client 了承後発動)
- cc-client self-update orchestration (「cc-client 更新して」「アップデート」trigger で kit 最新化を秘書自律案内)

【Phase A (owner hearing)】 ✅ 完了 (owner answer 済、Q-owner-1〜4 実値が seed-client-persona.md owner 領域に注入)

【Phase B (client hearing)】 ⏳ pending (marker `<<<CLIENT_HEARING_PENDING>>>` で wait)

【次の動作】
- 次に VSCode で Claude を起動すると SessionStart hook で /company が自動発動します。
- /company の startup checks で seed-client-persona.md の Phase B marker が検知され、秘書が AskUserQuestion で client hearing (Q-client-1: 業務概要 / Q-client-2: 業務範囲 / Q-client-3: 業界 common sense) を主導します。

【owner 同席なら今すぐ Phase B 実行可】
- 今、Claude を再起動 → client を同席させて秘書 hearing を実行できます。
- client 単独持ち帰り後でも、初回起動時に同じ hearing が自動で走ります。

【日常の使い方 (client へ)】
- VSCode を開く → 自動接続 → Claude (クロード) パネルで会話するだけ。ターミナルは不要。

【次に kit を更新したい case】
- 秘書に「cc-client 更新して」「アップデート」と言うだけで OK。秘書が最新版を取得し、更新手順を案内します。
- owner 手動の slash command (plugin install) と Codex login が一部残ります、案内が出たら従ってください。

【cheatsheet】
- Step 13 で chat に出力した Linux 版 cheatsheet を印刷 / PDF 化 → 紙で client に渡してください。
```

---

## 完了報告フォーマット

setup 完了後、最終的に owner に対して上記 Step 14 の chat 出力を提示すれば完了。
