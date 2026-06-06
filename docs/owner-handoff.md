# cc-client-setup v0.2 - owner 代行手順 (5 step)

owner が新クライアント PC に cc-client-setup v0.2 を配備する際の標準 5 step 手順。所要 30-40 min (1 PC、事前 hearing 別途 10-20 min)。

## 前提

- owner WSL local に `Hakuunsai/cc-client-setup` repo clone 済 (`~/repos/cc-client-setup/`)
- owner GitHub PAT 持ち (Hakuunsai org private repo access)
- client PC に物理 / リモートでアクセス可能 (RDP / 現地 / TeamViewer 等)
- client PC は Windows 10 / 11 native (WSL なし)

## Step 0: office-tada 秘書で Phase A hearing (事前 10-20 min、別 session)

owner が office-tada で秘書と壁打ち:

```
owner: 「新クライアント {client-name} の cc-client-setup を準備して」
```

秘書が `hearing-sop-owner.md` に従って Q-owner-1〜5 を AskUserQuestion で順次 hearing、結果を `~/repos/cc-client-setup/per-client/{client-id}/` 配下に customize 物 (kit-prompt / seed-client-persona / cheatsheet 各 1 file) として生成。

詳細は `.company/projects/cc-client-setup/hearing-sop-owner.md` 参照。

## Step 1: client PC 環境準備 (8 min)

client PC に lock-in (現地 / リモート):

```powershell
# Claude Code Windows native install
winget install Anthropic.ClaudeCode

# Git for Windows install (Git Bash 同梱、bash.exe で hook 動作)
winget install Git.Git
```

(client が既に install 済なら skip 可、version は推奨最新)

## Step 2: フォルダ作成 + 起動 (2 min)

```powershell
# Explorer で `C:\Users\{user}\source\{company-name}\` フォルダ作成
mkdir C:\Users\$env:USERNAME\source\{company-name}
cd C:\Users\$env:USERNAME\source\{company-name}

# Desktop ショートカット作成 (client 用、PowerShell or 手動で)
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\{company-name}.lnk")
$Shortcut.TargetPath = "wt.exe"   # Windows Terminal
$Shortcut.Arguments = "-d C:\Users\$env:USERNAME\source\{company-name}"
$Shortcut.Save()

# claude 起動 (初回 acceptEdits 推奨)
claude --dangerously-skip-permissions
```

## Step 3: kit-prompt paste + Claude 自律 setup (15-25 min)

owner 手元の `~/repos/cc-client-setup/per-client/{client-id}/kit-prompt.md` の中身を chat に paste:

```
(owner が kit-prompt.md 全文を copy → chat に paste)
```

Claude が自律で Step 1-14 を実行。owner は permission ask を都度承認 (auto mode 中なら自動 acceptEdits)。

途中 progress は Claude が chat に逐次出力。

## Step 4: 完了確認 + cheatsheet (3 min)

Claude の完了報告 (kit-prompt.md Step 14 出力) を確認:

- 配置物確認
- Phase A 完了 / Phase B pending 状態確認
- cheatsheet chat 出力を copy → Word / PDF / 紙印刷で client に渡す

### （任意）cc-comms 連絡 repo の準備（owner 作業、Step 4 完了後・Step 5 前）

**任意機能**。owner が repo + deploy key を用意した client のみ実施。未提供 client は skip して Step 5 へ（通常運用可）。

1. GitHub で Private repo `cc-client-comms-{client-id}` を作成（owner 所有）
2. `ssh-keygen -t ed25519 -f "$env:USERPROFILE\.ssh\cc-comms_{client-id}" -N ""` で deploy key 生成
3. 公開鍵（.pub）を repo Settings > Deploy keys に **Allow write access** で登録
4. 秘密鍵を client 機 `$env:USERPROFILE\.ssh\cc-comms_ed25519` に配置 + `$env:USERPROFILE\.ssh\config` に:
   ```
   Host cc-comms.github.com
     HostName github.com
     IdentityFile C:\Users\{user}\.ssh\cc-comms_ed25519
   ```
   remote URL は `git@cc-comms.github.com:Owner/cc-client-comms-{client-id}.git`
5. comms repo template（`templates/comms-repo/`）を初期 push（outbox/inbox/archive/README/AGENTS）
6. **executor を `~/.cc-comms-bin/` に配置**（セキュリティ上重要: executor は comms データ repo と分離し書込不可にする）:
   ```powershell
   # Windows: executor を読み取り専用で配置（~/.cc-comms-bin/ は settings の allow/Write に含めない）
   New-Item -ItemType Directory -Force "$env:USERPROFILE\.cc-comms-bin"
   Copy-Item "hooks\cc-comms-send.ps1" "$env:USERPROFILE\.cc-comms-bin\cc-comms-send.ps1" -Force
   # ACL で読み取り専用（書き込み権限を削除）
   $acl = Get-Acl "$env:USERPROFILE\.cc-comms-bin\cc-comms-send.ps1"
   $acl.SetAccessRuleProtection($true, $false)
   $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($env:USERNAME, 'ReadAndExecute', 'Allow')
   $acl.SetAccessRule($rule)
   Set-Acl "$env:USERPROFILE\.cc-comms-bin\cc-comms-send.ps1" $acl
   ```
7. kit-prompt の **Step 11.7** を owner が手動で実行（clone のみ、executor は上記で配置済）

## Step 5: claude 再起動 + SessionStart hook 確認 (2 min)

```powershell
# Ctrl+C で claude 終了
claude
```

SessionStart hook で `/company:company` が自動発動することを確認。

(option) owner 同席なら、ここで client を同席させて Phase B hearing を実行:
- 秘書が AskUserQuestion で Q-client-1〜3 を順次主導
- 完了で hearing 完了報告
- 詳細は `.company/projects/cc-client-setup/hearing-sop-client.md` 参照

owner setup 完了。client に「これからは {company-name} ショートカットダブルクリックで秘書と話してください」と引き継ぎ。

## トラブルシュート

詳細は `docs/recovery.md` 参照。代表 case:

| 症状 | 対応 |
|---|---|
| `/company` 自動発動しない | claude 再起動 → 駄目なら `~/.claude/settings.json` の hooks.SessionStart 確認 |
| permission 拒否で動かない | client が「これ拒否されました」と秘書経由 → owner connect → settings.json deny 緩和 |
| plugin が読み込まれてない | claude 再起動 + 秘書経由で `/plugin list` 確認 → 駄目なら `enabledPlugins` 確認 |
| client hearing が走らない | `~/.cc-client-memory/seed-client-persona.md` の marker `<<<CLIENT_HEARING_PENDING>>>` 存在確認、なければ既に完了 (`phase_b_completed: true`) |

## 完了基準 (cc-client-setup v0.2 spec Section 7.1 = 14 件) を verify

詳細は v0.2 spec Section 7.1 参照。owner 実機で 14 基準を順次 verify (30-40 min)。

---

# Linux 版手順 (v0.7、RHEL/Rocky/Alma 系 + VSCode Remote-SSH + Claude 拡張)

Linux 物理サーバー上の Claude Code を、Windows の VSCode から Remote-SSH 接続 + Claude Code 拡張パネルで使う構成。Claude Code 本体と hook は **リモート Linux 側**で実行される (公式 docs 確認済)。利用者は端末を一切触らず、VSCode の Claude パネルで会話するだけ。

## 前提 (Linux)

- owner WSL local に `Hakuunsai/cc-client-setup` repo clone 済
- owner GitHub PAT 持ち
- Linux サーバー (RHEL/Rocky/Alma 系) に SSH アクセス可能
- Windows 側に VSCode + Remote-SSH 拡張 + Claude Code 拡張

## Step 0: office-tada 秘書で Phase A hearing (Windows 版と同一)

`hearing-sop-owner.md` の Q-owner-1〜4 を hearing → `per-client/{client-id}/` に customize 物生成 (kit-prompt は **`kit-prompt-linux.md`** を base に生成)。

## Step 1: Linux サーバー環境準備 (owner 代行・冪等)

```bash
# git / jq (jq は PreToolUse deny hook の JSON 抽出に必須)
sudo dnf install -y git jq

# Claude Code (公式 installer)。既 install ならバージョン確認のみ
# node (Codex 用・任意): sudo dnf install -y nodejs  または nvm
```

## Step 2: フォルダ + VSCode 接続

```bash
mkdir -p ~/source/{company-name}
```

- owner が VSCode に **Remote-SSH 接続先 (Linux サーバー) + 保存ワークスペース (`~/source/{company-name}/`)** を設定
- VSCode に Claude Code 拡張を install (リモート側で有効化)

## Step 3: kit-prompt paste + Claude 自律 setup (15-25 min)

owner 手元の `~/repos/cc-client-setup/per-client/{client-id}/kit-prompt.md` (= Linux 版) の中身を、Claude 拡張パネル (またはリモート terminal の `claude`) に paste。Claude が自律で Step 1-14 を実行。

## Step 4: 完了確認 + cheatsheet (3 min)

Claude の完了報告 (kit-prompt-linux.md Step 14 出力) を確認。**Linux 版 cheatsheet** (起動方法 = VSCode 拡張パネル) を chat 出力 → 印刷 / PDF 化で client に渡す。

### （任意）cc-comms 連絡 repo の準備（owner 作業、Step 4 完了後・Step 5 前）

**任意機能**。owner が repo + deploy key を用意した client のみ実施。未提供 client は skip して Step 5 へ（通常運用可）。

1. GitHub で Private repo `cc-client-comms-{client-id}` を作成（owner 所有）
2. `ssh-keygen -t ed25519 -f ~/.ssh/cc-comms_{client-id} -N ""` で deploy key 生成
3. 公開鍵（.pub）を repo Settings > Deploy keys に **Allow write access** で登録
4. 秘密鍵を client 機 `~/.ssh/cc-comms_ed25519` に配置 + `~/.ssh/config` に:
   ```
   Host cc-comms.github.com
     HostName github.com
     IdentityFile ~/.ssh/cc-comms_ed25519
   ```
   remote URL は `git@cc-comms.github.com:Owner/cc-client-comms-{client-id}.git`
5. comms repo template（`templates/comms-repo/`）を初期 push（outbox/inbox/archive/README/AGENTS）
6. **executor を `~/.cc-comms-bin/` に配置**（セキュリティ上重要: executor は comms データ repo と分離し書込不可にする）:
   ```bash
   # Linux: executor を読み取り専用で配置（~/.cc-comms-bin/ は settings の allow/Write に含めない）
   mkdir -p ~/.cc-comms-bin
   cp hooks/cc-comms-send.sh ~/.cc-comms-bin/cc-comms-send.sh
   chmod 555 ~/.cc-comms-bin/cc-comms-send.sh
   ```
7. kit-prompt の **Step 11.7** を owner が手動で実行（clone のみ、executor は上記で配置済）

## Step 5: 再起動 + SessionStart hook 確認

VSCode で Claude を再起動 → SessionStart hook で `/company` が自動発動することを確認。

(option) owner 同席なら Phase B hearing を実行。

## 日常導線 (client へ引き継ぎ)

> 「**VSCode を開く → 自動接続 → Claude (クロード) パネルで話しかける**」だけ。ターミナルは不要です。

## トラブルシュート (Linux 固有)

| 症状 | 対応 |
|---|---|
| PreToolUse deny が効かない | `command -v jq` で jq 確認、無ければ `sudo dnf install -y jq` |
| hook が動かない | `~/.claude/settings.json` の hooks が `bash ...` 登録か、hook に `chmod +x` 済か確認 |
| Codex 委譲が使えない | `node --version` / `codex --version` / `~/.codex/auth.json` 確認、degraded mode で他機能は動作 |
| Claude パネルがリモートに繋がらない | VSCode 左下の Remote-SSH 接続状態を確認 |
