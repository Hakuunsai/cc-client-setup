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
