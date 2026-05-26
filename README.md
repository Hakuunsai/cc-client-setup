# cc-client-setup

owner クライアント向け Claude Code 環境構築 PowerShell bootstrap kit。**private 配布** (Claude Code plugin marketplace への公開 / public 配布は行わない)。

**Version**: v0.1.0 (Phase 1 MVP, 2026-05-26)

## 目的

プログラミング未経験のクライアントが自社アプリを Claude Code で運用できるよう、owner が現地/リモートで環境構築を代行する際の bootstrap kit。

## 5 つの柱

1. **セキュリティ rules** — `~/.claude/rules/{security-essentials,forbidden-files,network-security}.md`
2. **CLAUDE.md** — 実装許可制 + 余計なことしない (user-wide + PJ 別)
3. **settings.json** — permissions deny/ask + PreToolUse/PostToolUse hooks
4. **git 巻き戻し体制** — `.gitignore` / pre-commit secret 検出 / auto-checkpoint via `git stash`
5. **秘書簡略版** — `.company/secretary/` で decisions/learnings/inbox 同日 1 file 追記

## 対象

- OS: Windows native (WSL なし)
- ユーザー: プログラミング未経験、自社アプリを Claude Code で運用したい層
- 配布: private (owner のクライアントのみ)

## 使い方

詳細は [docs/installation.md](docs/installation.md)。

クイックスタート (owner 用):

```powershell
git clone https://github.com/Hakuunsai/cc-client-setup.git
cd cc-client-setup
.\Setup-CCClientSetup.ps1 -ProjectPath C:\path\to\client-app
```

クライアント向けカンペ: [docs/client-cheatsheet.md](docs/client-cheatsheet.md)
復旧手順: [docs/recovery.md](docs/recovery.md)

## Phase 1 MVP に含まれないもの (Phase 2+ で別 spec)

- macOS / Linux / WSL サポート
- 既存コード遡及 security audit
- 言語別 .gitignore variant
- Codex / 並行運用機構
- 公開 plugin marketplace 化
- auto-update 配信機構

## テスト

```powershell
Invoke-Pester ./tests/ -Output Detailed
```

(Windows native PC で `pwsh` + Pester 5 環境必要)
