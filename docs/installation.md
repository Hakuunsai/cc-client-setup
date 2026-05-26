# cc-client-setup install 手順 (owner 用)

クライアント PC (Windows native) に Claude Code 環境を構築する手順。所要時間 1-2h / 1 PC。

## 事前準備 (クライアント PC で実施)

1. **Claude Code Windows 版 install**
   - 公式 install 手順に従う
   - install 後、初回起動で OAuth (Anthropic アカウント) 完了

2. **Git for Windows install**
   - <https://gitforwindows.org/> から install
   - PowerShell から `git --version` で動作確認

3. **PowerShell 7+ 確認**
   - `pwsh -Version` で 7 以降を確認
   - Windows 10 以前なら別途 install ([PowerShell 公式](https://github.com/PowerShell/PowerShell))

## bootstrap 実行 (owner が代行)

### Step 1: cc-client-setup repo clone (owner 認証)

クライアント PC で PowerShell 開いて:

```powershell
cd $env:USERPROFILE\source
git clone https://github.com/Hakuunsai/cc-client-setup.git
cd cc-client-setup
```

(private repo なので owner の GitHub Personal Access Token / SSH 鍵が必要)

### Step 2: bootstrap 実行

```powershell
.\Setup-CCClientSetup.ps1 -ProjectPath C:\path\to\client-app
```

- `-ProjectPath`: クライアントの自社 PJ ルート (例: `C:\Users\client\source\my-app`)
- `.git` が無いなら interactive prompt で `git init` 確認
- dir が無いなら interactive prompt で作成確認

### Step 3: 動作確認

クライアント PC で Claude Code 起動 (`claude` コマンド) し、次の挙動を確認:

- 「`~/.claude/CLAUDE.md` を読み込みました」相当の応答
- `Read .env` を依頼 → permission deny
- `curl https://example.com` を依頼 → permission deny + hook deny
- 適当な file を Edit 依頼 → `git stash list` で `[claude-auto-checkpoint]` stash が増える

### Step 4: クライアントに引き渡し

`docs/client-cheatsheet.md` を印刷 (PDF 化) してクライアントに渡す。

## トラブルシュート

- `pwsh: 認識されません` → PowerShell 7 未 install、Step 事前準備 3 参照
- `git: 認識されません` → Git for Windows 未 install、Step 事前準備 2 参照
- hook 経路エラー → `~/.claude/hooks/*.ps1` の絶対パスが `<USER>` 置換済か確認
- pre-commit hook が動かない → `.git/hooks/pre-commit` shim の `#!/bin/sh` 行末改行 (LF) を確認

## アップデート (再 install)

owner が repo を pull → 再 invoke でクライアント PC は冪等更新:

```powershell
cd $env:USERPROFILE\source\cc-client-setup
git pull
.\Setup-CCClientSetup.ps1 -ProjectPath C:\path\to\client-app
```

既存 file は `*.bak.YYYYMMDDTHHmmss` に backup される。
