# cc-client-setup v0.6 - Claude Code Self-Setup Prompt (Codex 委譲統合 + self-update)

このプロンプトは Claude Code (あなた) が、クライアント PC に Claude Code 環境を
自律でセットアップするための指示書です。owner ご了承前提、本指示書を実行することを承諾します。

## 前提

- **本セッション cwd** = `C:\Users\{user}\source\{company-name}\` (Explorer で作成済)
- **Claude Code** = 素の状態で install 済 (plugin / hook / settings 未設定、`winget install Anthropic.ClaudeCode` 直後)
- **Git for Windows** = install 済 (`winget install Git.Git`、Git Bash 同梱で `bash.exe` 利用可能)
- **kit raw URL prefix** = `https://raw.githubusercontent.com/Hakuunsai/cc-client-setup/main/`
- **owner** = この PC に setup を代行する人物 (= 私の owner)
- **client** = この PC の最終 user (プログラミング未経験、業務知識あり)

## per-client placeholders (owner が paste 前に置換、office-tada 秘書 Phase A hearing で取得)

- `{COMPANY_NAME}` = クライアント企業名 (例: 「株式会社サンプル」)
- `{OWNER_CONTACT}` = cheatsheet 用 owner 連絡先 (例: 「email: owner@example.com / 受付時間: 平日 9:00-18:00」)
- `{CLIENT_OWNER_SEED_BLOCK}` = owner hearing 結果 (Q-owner-1〜4 全 4 件)、`seed-client-persona.md` owner 領域に注入される markdown block (約 4-8 行)

※ client 業務情報 (業務概要 / 業務範囲 / 業界 common sense) は Phase B (client PC 秘書) で client 本人が答えるため、本 kit-prompt 内には含めない (marker placeholder で wait)。

## あなたの仕事 (冪等で実行、既存 file は backup + overwrite)

下記 Step 1-14 を上から順に冪等に実行してください。各 Step で対象 file が既に存在し内容一致なら skip、差分なら `*.bak.YYYYMMDDTHHmmss` に backup 後 overwrite してください。permission ask が出たら owner に確認してください (auto mode 中なら自動で acceptEdits)。

- [ ] **Step 1**: `~/.claude/rules/` に 3 file 配置 (security-essentials.md / forbidden-files.md / network-security.md)
- [ ] **Step 2**: `~/.claude/CLAUDE.md` 配置 (姿勢英文 + ペルソナ + 6 柱 + 自動記録規律 + Codex 自動委譲規律、v0.5 拡張)
- [ ] **Step 3**: `~/.claude/settings.json` 配置 (plugins + hooks 4 種 + permissions + `autoMemoryDirectory: "~/.cc-client-memory"`)
- [ ] **Step 4**: `~/.claude/hooks/` に 4 hook script 配置 (inject-auto-company-skill.sh / memory-local-commit.sh / PreToolUse-DenyDangerous.ps1 / PostToolUse-AutoCheckpoint.ps1)
- [ ] **Step 5**: `~/.cc-client-memory/` 配置 (mkdir + git init + 3 baseline seed copy + seed-client-persona.md (owner 領域実値 + Phase B marker 注入) + 初回 commit)
- [ ] **Step 6**: `.claude/settings.json` 配置 (cwd 相対、空テンプレ、user-wide override 用)
- [ ] **Step 7**: `CLAUDE.md` 配置 (cwd 相対、姿勢英文 + ペルソナ + 業務概要 marker)
- [ ] **Step 8**: `.gitignore` 配置 (cwd 相対、generic Windows + 言語中立)
- [ ] **Step 9**: cwd で git init (未 init なら) + `.git/hooks/pre-commit` (sh shim) + `.git/hooks/pre-commit.ps1` (本体) 配置 + 初回 commit
- [ ] **Step 10**: `.company/secretary/` 配置 (cwd 相対、CLAUDE.md + 空 inbox/todos/notes、cc-company plugin 利用前提)
- [ ] **Step 11a (Claude 自動)**: `~/.claude/skills/git-workflow/SKILL.md` 配置 (cc-company marketplace 経由 plugin 提供がないため direct skill 配置、v0.4 で経路追加)
- [ ] **Step 11b (owner manual)**: plugin install (`/plugin marketplace add` + `/plugin install` × 3 = cc-company + superpowers + codex (v0.5 追加))
- [ ] **Step 11.5 (Claude 自動、v0.5 追加)**: Codex 実体配備 (Node.js install + `@openai/codex` CLI install + 配備確認)
- [ ] **Step 11.6 (owner manual、v0.5 追加)**: `codex login` OAuth flow 案内 (ブラウザ login)、`~/.codex/auth.json` 配備確認
- [ ] **Step 11.7 (owner manual)**: cc-comms 連絡 repo を配置（owner が事前に repo+deploy key を用意済の場合のみ。未提供ならこの Step を skip）
- [ ] **Step 12**: 完了確認 (各配置物 grep + 4 hook 存在 + plugin enabled state + `~/.cc-client-memory/seed-client-persona.md` 内 Phase B marker 存在 + Codex 実体配備 + `codex@openai-codex` plugin enabled、v0.5 拡張)
- [ ] **Step 13**: cheatsheet 出力 (placeholder 置換版を chat に出力、owner が印刷 / PDF 化して client に渡す)
- [ ] **Step 14**: Phase B + v0.5 Codex + v0.6 self-update 状況説明 (owner に「次の claude 再起動で client hearing が走る」+「秘書が必要に応じて別の AI (Codex) にダブルチェック / 実装委譲を自動で行う」+「次に kit を更新したい case は秘書に『cc-client 更新して』と言うだけ」と伝達)

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

### Step 2: `~/.claude/CLAUDE.md` 配置 (姿勢 + ペルソナ + 5 柱)

```bash
# 既存あれば backup
[ -f ~/.claude/CLAUDE.md ] && mv ~/.claude/CLAUDE.md ~/.claude/CLAUDE.md.bak.$(date +%Y%m%dT%H%M%S)
```

WebFetch `{kit raw URL prefix}/templates/claude-md-user.template` → 取得した template の placeholder を置換 (`{COMPANY_NAME}` を実値で置換) → Write `~/.claude/CLAUDE.md`。

### Step 3: `~/.claude/settings.json` 配置

```bash
[ -f ~/.claude/settings.json ] && mv ~/.claude/settings.json ~/.claude/settings.json.bak.$(date +%Y%m%dT%H%M%S)
```

WebFetch `{kit raw URL prefix}/templates/settings-user.json.template` → 取得した template の placeholder を置換 (`<USER>` を `$env:USERNAME` で動的解決、hook の絶対 path を実 path に置換) → Write `~/.claude/settings.json`。

(注: Phase 1 backlog B-2 = HomeRoot 不整合は v0.2 で本 step の動的解決で解消)

### Step 4: `~/.claude/hooks/` に 4 hook script 配置

```bash
mkdir -p ~/.claude/hooks
```

4 hook それぞれ WebFetch + Write:
- `inject-auto-company-skill.sh` → `~/.claude/hooks/inject-auto-company-skill.sh` (実行権限不要、bash 起動)
- `memory-local-commit.sh` → `~/.claude/hooks/memory-local-commit.sh`
- `PreToolUse-DenyDangerous.ps1` → `~/.claude/hooks/PreToolUse-DenyDangerous.ps1`
- `PostToolUse-AutoCheckpoint.ps1` → `~/.claude/hooks/PostToolUse-AutoCheckpoint.ps1`

既存 file あれば backup。

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

(本セッション cwd = `C:\Users\{user}\source\{company-name}\` 想定、以下 Step 6-10/12 の全 path は cwd 相対で記述。`{company-name}/` 前置は付けないこと。付けると `…\source\{company-name}\{company-name}\.claude\` の二重 path になる)

```bash
mkdir -p .claude
```

WebFetch `{kit raw URL prefix}/templates/settings-project.json.template` → Write `.claude/settings.json`。空テンプレ (user-wide override 用)。

### Step 7: `CLAUDE.md` 配置 (cwd 相対)

WebFetch `{kit raw URL prefix}/templates/claude-md-project.template` → 取得した template の placeholder 置換:
- `{COMPANY_NAME}` を実値置換
→ Write `CLAUDE.md` (cwd 直下)

### Step 8: `.gitignore` 配置 (cwd 相対)

WebFetch `{kit raw URL prefix}/templates/gitignore.template` → Write `.gitignore`

### Step 9: git init + pre-commit 配置 (2-file layout: sh shim + ps1 本体)

```bash
[ ! -d .git ] && git init -b main
mkdir -p .git/hooks
```

**pre-commit.ps1 (PowerShell 本体)** を WebFetch + Write:
- WebFetch `{kit raw URL prefix}/templates/pre-commit.ps1.template` → Write `.git/hooks/pre-commit.ps1`

**pre-commit (sh shim)** を Write で配置 (Git for Windows の git は sh shim を最初に実行、shim から pwsh.exe に委譲):

```sh
#!/bin/sh
# sh shim — exec pwsh.exe で PowerShell 本体に委譲 (Git for Windows 環境前提)
exec pwsh.exe -File "$(dirname "$0")/pre-commit.ps1"
```

(本 sh shim は file 名 `.git/hooks/pre-commit`、改行 LF、shebang `#!/bin/sh` で Write)

```bash
chmod +x .git/hooks/pre-commit
git add .claude/ CLAUDE.md .gitignore
git commit -m "Initial setup ({company-name} workspace)"
```

(注: kit-prompt v0.2 で「pre-commit に直接 ps1 内容書き」と指示していたが、sh は ps1 を直接実行できないため commit が落ちる。v0.2.1 で 2-file layout に修正。pre-commit.ps1.template の self-description と整合。F-2 fix 2026-05-27)

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

cc-company marketplace は `company` plugin のみ提供のため、git-workflow は direct skill 経路で配備する (v0.4 で経路追加、v0.3 時点の plugin install spec 誤りを是正)。

```bash
mkdir -p ~/.claude/skills/git-workflow
```

WebFetch `{kit raw URL prefix}/templates/claude-skills/git-workflow/SKILL.md` → Write `~/.claude/skills/git-workflow/SKILL.md`。既存 file あれば `*.bak.YYYYMMDDTHHmmss` backup 後 overwrite。

配置後、Claude Code は次セッション以降で `git-workflow` skill を `Skill` tool 経由で自動発動可能になる。秘書は git 操作 (commit / push / branch / worktree 等) の trigger で本 skill を自律発動する (本 client は技術用語を意識する必要なし)。

### Step 11b: plugin install (cc-company + superpowers) — ⚠️ owner manual step

**重要**: `/plugin marketplace add` / `/plugin install` 等の slash command は Claude tool 呼び出しから発動できません (user 入力起点のみ)。Claude (あなた) は本 Step を直接実行できず、**owner に手動依頼**してください。

settings.json には Step 3 で `extraKnownMarketplaces` + `enabledPlugins` を宣言済のため、**次回 Claude Code 起動時に auto resolve される可能性あり**。Auto resolve 成功時は本 Step 全 skip 可。

**注意 (2026-05-27 demo-001 観察事例)**: superpowers は初回 `claude` 起動時に auto resolve されない case がある。**marketplace update + Claude Code 再起動を 1-2 回繰り返すと install 成功**することが確認されている (詳細トリガー不明、cache / metadata 同期の問題と推測)。2-3 回繰り返しても install されない場合は GitHub auth / network 設定を確認 (詳細: `docs/installation.md` の Step 11 補足 section)。

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

完了後、`/plugin list` で 3 plugin (company + superpowers + codex、v0.5 で codex 追加) が enabled 状態であることを確認。git-workflow は plugin ではなく direct skill (Step 11a で配置済) のため `/plugin list` には表示されない。

Claude (あなた) の Step 11b 完了報告は「owner に slash command 7 行を案内した」で OK。実 install は owner 側で完了する想定。

### Step 11.5: Codex 実体配備 (Claude 自動、v0.5 追加)

Codex CLI を Windows native に install します。Step 11b の plugin install (`codex@openai-codex`) と pair で動作 (plugin = Claude Code から `mcp__codex__codex` tool を呼ぶ経路、CLI = 実体実行 binary)。

```bash
# Node.js 既 install 確認 (skip 判定)
if ! node --version >/dev/null 2>&1; then
  # winget install (silent + 自動 accept)
  winget install --id OpenJS.NodeJS.LTS --silent --accept-source-agreements --accept-package-agreements
  echo "Note: PATH 反映に新 shell 起動が必要な場合あり"
fi

# Codex CLI install (既 install ならバージョン確認のみ)
if ! codex --version >/dev/null 2>&1; then
  npm install -g @openai/codex
fi

# 配備確認
node --version && codex --version
```

**冪等性**: `codex --version` 反応すれば skip。`node` 不在で winget install fail した場合、新 shell で再試行 or owner manual install (`winget install OpenJS.NodeJS.LTS` を terminal で実行) を案内。

**失敗時**: winget / npm fail は warning 出力 + Step 12 配備確認に degraded mode flag を立て、Codex なし運用継続 (= v0.4 機能は全動作する)。kit-prompt 完走自体は継続。

(注: Node.js install 後の PATH 反映に新 shell 必要 case あり。失敗時は cheatsheet「Codex 利用不能」case 案内で運用、`docs/installation.md` Step 11.5 section 参照)

### Step 11.6: `codex login` OAuth flow 案内 (owner manual、v0.5 追加)

**重要**: `codex login` はブラウザ OAuth flow を起動する human-in-the-loop step、自動化不可。Claude (あなた) は本 Step を直接実行できず、**owner に手動依頼**してください。

owner に以下を chat 出力で案内:

```
Codex CLI の認証を 1 度だけ手動で実施してください:

1. terminal (PowerShell or Git Bash) で `codex login` 実行
2. ブラウザが自動で開く (`https://chat.openai.com/...` の OAuth login 画面)
3. ChatGPT アカウント (Plus / Pro / Enterprise) で login
4. ブラウザに「Authentication successful」表示 + terminal close
5. 配備確認: PowerShell で `Test-Path $HOME\.codex\auth.json` (true なら OK)、Bash で `[ -f ~/.codex/auth.json ] && echo "OK"`

login 完了後、本 kit-prompt 実行を再開してください (秘書に「Codex login 完了しました」と伝達)。

login が失敗する場合:
- ChatGPT アカウント未保有 → ChatGPT Plus 加入が必要 (`https://chat.openai.com/`)
- ブラウザが開かない → terminal 出力の URL を手動で browser に paste
- network 制限環境 → owner の VPN / network 設定確認
```

**配備確認**: owner が「login 完了」と伝達した後、Claude (あなた) は `[ -f ~/.codex/auth.json ]` を確認。true なら次の Step に進む、false なら Step 12 配備確認に未完了 flag を立てるが kit-prompt 自体は完走継続 (= 次回 login 完了時から Codex 利用有効化)。

(注: login OAuth flow は human-in-the-loop で自動化不可、唯一 owner manual step。Step 11b plugin install と同じ「owner 手動」カテゴリだが、こちらは settings.json declarative ではなく事前 OAuth が必要なため)

### Step 11.7: cc-comms 連絡 repo を配置（owner manual、任意）

**本 Step は owner が事前に comms repo + deploy key を用意済の場合のみ実行。未提供の場合は skip して Step 12 へ。**

comms 未提供のクライアントでは本 Step を skip（連絡機構なしで通常運用可）。

owner に以下を案内（repo + deploy key が用意済であれば PowerShell で実行）:

```powershell
# cc-comms repo が未 clone なら clone（owner 提供の SSH URL を使用）
if (-not (Test-Path "$env:USERPROFILE\.cc-client-comms\.git")) {
    git clone "<comms-repo-ssh-url>" "$env:USERPROFILE\.cc-client-comms"
}

# cc-comms-send.ps1 をコピー（実行権限は Windows では不要）
# （kit の hooks/ から取得済みの場合、または kit raw URL から WebFetch でも可）
Copy-Item "$env:USERPROFILE\.claude\hooks\cc-comms-send.ps1" `
          "$env:USERPROFILE\.cc-client-comms\cc-comms-send.ps1" -Force

# 配備確認
if (Test-Path "$env:USERPROFILE\.cc-client-comms\.git") { "cc-comms: ready" } else { "cc-comms: clone 失敗" }
```

**deploy key 配置** (owner が事前準備):
- owner 側で deploy key 生成済（`ssh-keygen -t ed25519 -f "$env:USERPROFILE\.ssh\cc-comms_{client-id}" -N ""`）
- 公開鍵（.pub）を comms repo Settings > Deploy keys に **Allow write access** で登録済
- 秘密鍵は client 機 `$env:USERPROFILE\.ssh\cc-comms_ed25519` に配置済
- `$env:USERPROFILE\.ssh\config` に Host alias 設定済（`Host cc-comms.github.com` / `HostName github.com` / `IdentityFile ...cc-comms_ed25519`）
- comms repo の remote URL は `git@cc-comms.github.com:Owner/cc-client-comms-{client-id}.git`

Claude (あなた) の Step 11.7 完了報告は「owner に手順を案内し、deploy key 配備済の場合のみ clone + copy を実行した（未提供の場合は skip）」で OK。

### Step 12: 完了確認

```bash
# 配置物 grep
test -f ~/.claude/rules/security-essentials.md && \
test -f ~/.claude/rules/forbidden-files.md && \
test -f ~/.claude/rules/network-security.md && \
test -f ~/.claude/CLAUDE.md && \
test -f ~/.claude/settings.json && \
test -f ~/.claude/hooks/inject-auto-company-skill.sh && \
test -f ~/.claude/hooks/memory-local-commit.sh && \
test -f ~/.claude/hooks/PreToolUse-DenyDangerous.ps1 && \
test -f ~/.claude/hooks/PostToolUse-AutoCheckpoint.ps1 && \
test -d ~/.cc-client-memory/.git && \
test -f ~/.cc-client-memory/seed-baseline-security.md && \
test -f ~/.cc-client-memory/seed-baseline-implementation-gate.md && \
test -f ~/.cc-client-memory/seed-baseline-secretary-posture.md && \
test -f ~/.cc-client-memory/seed-client-persona.md && \
test -f ~/.claude/skills/git-workflow/SKILL.md && \
test -d .git && \
test -f CLAUDE.md && \
test -f .gitignore && \
test -f .git/hooks/pre-commit && \
test -f .git/hooks/pre-commit.ps1 && \
test -d .company/secretary && \
echo "全配置物 OK"

# Phase B marker 存在確認
grep -q "<<<CLIENT_HEARING_PENDING>>>" ~/.cc-client-memory/seed-client-persona.md && echo "Phase B marker OK"

# Codex 配備確認 (v0.5 追加、失敗時は degraded mode flag のみ、kit-prompt 完走継続)
echo "--- Codex 配備確認 (v0.5) ---"
node --version >/dev/null 2>&1 && echo "Node.js OK" || echo "Node.js NG (degraded mode)"
codex --version >/dev/null 2>&1 && echo "Codex CLI OK" || echo "Codex CLI NG (degraded mode)"
[ -f ~/.codex/auth.json ] && echo "codex login OK" || echo "codex login 未完了 (Step 11.6 owner manual を再実行案内)"
grep -q "codex@openai-codex" ~/.claude/settings.json && echo "Codex plugin enabled state OK" || echo "Codex plugin enabled state NG"
test -f templates/codex-prompts/client-delegation-prefix.md && echo "Codex prompt prefix template OK" || echo "Codex prompt prefix template NG (kit 同梱漏れ?)"

# cc-comms 配備確認 (任意。未配置は正常運用継続)
[ -d ~/.cc-client-comms/.git ] && echo "cc-comms: ready" || echo "cc-comms: 未配置(任意)"
```

両方 (基本 + Codex 配備) OK が表示されること。Codex 関連 NG は degraded mode で運用継続 (= v0.4 機能は全動作、Codex 委譲のみ無効、cheatsheet 「Codex 利用不能」case 案内継承)。

### Step 13: cheatsheet 出力 (chat に)

WebFetch `{kit raw URL prefix}/docs/client-cheatsheet.md.template` → 取得した template の placeholder (`{COMPANY_NAME}` / `{OWNER_CONTACT}`) を実値で置換 → chat に出力 (Markdown 形式)。

owner は出力を copy → Word / PDF / 紙印刷で client に渡す。

### Step 14: Phase B 状況説明 (owner に)

chat に以下を出力:

```
✅ cc-client-setup v0.6 setup 完了

【配置物】
- ~/.claude/{rules, CLAUDE.md, settings.json, hooks/} : 4 種 (rules 3 + CLAUDE.md 1 + settings.json 1 + hooks 4)
- ~/.cc-client-memory/ : 4 seed file (3 baseline + 1 client persona = owner 領域実値 + Phase B marker)
- {company-name}/ : .claude/settings.json + CLAUDE.md + .gitignore + .git/hooks/pre-commit + .company/secretary/
- enabled plugin : 3 (company + superpowers + codex、v0.5 で codex 追加) + direct skill : 1 (git-workflow @ ~/.claude/skills/git-workflow/SKILL.md)
- Codex CLI : Node.js + @openai/codex install + `codex login` OAuth (~/.codex/auth.json cache)
- Codex prompt prefix template : {company-name}/templates/codex-prompts/client-delegation-prefix.md

【秘書振舞い (v0.4 + v0.5 + v0.6)】 ✅ 自動発動規律配備済
- v0.4: skill 自動発動 (brainstorming / writing-plans / systematic-debugging / verification-before-completion / receiving-code-review / requesting-code-review / dispatching-parallel-agents / git-workflow を秘書自律発動)
- v0.5: Codex 自動委譲 (review + 実装委譲 を秘書判断 + explicit 予告 + client 了承後発動、sandbox 3 重防御)
- v0.6: cc-client self-update orchestration (「cc-client 更新して」「アップデート」trigger で kit 最新化を秘書自律案内)

【Phase A (owner hearing)】 ✅ 完了 (owner answer 済、Q-owner-1〜4 実値が seed-client-persona.md owner 領域に注入)

【Phase B (client hearing)】 ⏳ pending (marker `<<<CLIENT_HEARING_PENDING>>>` で wait)

【次の動作】
- 次に claude を起動すると SessionStart hook で /company が自動発動します。
- /company の startup checks で seed-client-persona.md の Phase B marker が検知され、秘書が AskUserQuestion で client hearing (Q-client-1: 業務概要 / Q-client-2: 業務範囲 / Q-client-3: 業界 common sense) を主導します。

【owner 同席なら今すぐ Phase B 実行可】
- 今、claude を再起動 (Ctrl+C → claude) → client を同席させて秘書 hearing を実行できます。
- client 単独持ち帰り後でも、初回起動時に同じ hearing が自動で走ります。

【次に kit を更新したい case (v0.6 追加)】
- 秘書に「cc-client 更新して」「アップデート」と言うだけで OK。秘書が最新版を取得し、新しい terminal で paste 実行する手順を案内します。
- owner 手動の slash command (plugin install) と Codex login が一部残ります、案内が出たら従ってください。

【cc-comms 連絡機構 (任意・Step 11.7 で配備済の場合)】
- owner との連絡は「owner に相談」「owner に伝えて」で起動。
- 技術連絡 (metadata kind) は自動送信。業務情報 (business kind) の送信は client の承認確認あり。
- comms 未配備の場合は連絡機構なしで通常運用を継続 (他の全機能は動作)。

【cheatsheet】
- Step 13 で chat に出力した cheatsheet を印刷 / PDF 化 → 紙で client に渡してください。
```

---

## 完了報告フォーマット

setup 完了後、最終的に owner に対して上記 Step 14 の chat 出力を提示すれば完了。
