# cc-client-setup v0.2

owner クライアント (プログラミング未経験者) 向け Claude Code 環境構築 kit。Windows native、Approach W (Claude self-setup) で配備。

## 配布形態

- **public GitHub repo** (`Hakuunsai/cc-client-setup`、機微なし)
- 配布物 = markdown + template + 4 hook script のみ (PowerShell bootstrap script 0 行)
- owner 代行で 1 PC 30-40 min セットアップ

## クイックスタート (owner 用)

1. 本 repo を WSL local clone: `gh repo clone Hakuunsai/cc-client-setup ~/repos/cc-client-setup/`
2. office-tada 秘書で新クライアント hearing (`hearing-sop-owner.md` に従って秘書が AskUserQuestion で順次)
3. customize 物 (`~/repos/cc-client-setup/per-client/{client-id}/`) 生成
4. client PC に lock-in → kit-prompt.md paste → Claude が自律 setup
5. cheatsheet を印刷 → client に渡す

詳細手順は [`docs/owner-handoff.md`](docs/owner-handoff.md) 参照。

## 配布物の中身

### Core (Claude 自律 setup の中心)

- [`kit-prompt.md`](kit-prompt.md) ⭐ メイン指示書 (約 250 行、Claude が自律 setup する Step 1-14)
- [`kit-prompt-update.md`](kit-prompt-update.md) - 改訂時差分指示書 (約 50 行)

### Templates (Claude が WebFetch で取得して client PC に配置)

- `templates/claude-rules/` - セキュリティ rules 3 file
- `templates/claude-md-user.template` - `~/.claude/CLAUDE.md` (姿勢 + ペルソナ + 5 柱、約 150 行)
- `templates/claude-md-project.template` - PJ 別 `CLAUDE.md`
- `templates/settings-user.json.template` - `~/.claude/settings.json` (plugin + hook + permissions)
- `templates/settings-project.json.template` - PJ 別 `.claude/settings.json` (空テンプレ)
- `templates/secretary-claude.md.template` - `.company/secretary/CLAUDE.md` (cc-company plugin 連携)
- `templates/gitignore.template` - generic Windows + 言語中立
- `templates/pre-commit.ps1.template` - pre-commit hook (secret regex grep)
- `templates/memory-seed/` - memory baseline 4 file (3 baseline + 1 client persona template)

### Hooks (`~/.claude/hooks/` 配置)

- `hooks/inject-auto-company-skill.sh` - SessionStart hook (Claude に `/company:company` 自動発動を指示)
- `hooks/memory-local-commit.sh` - Stop hook (`~/.cc-client-memory/` local commit)
- `hooks/PreToolUse-DenyDangerous.ps1` - Bash 危険操作 deny (Phase 1 流用、Codex review 反映済)
- `hooks/PostToolUse-AutoCheckpoint.ps1` - Edit/Write 後 `claude-checkpoints` branch auto commit (Phase 1 流用)

### Docs

- [`docs/owner-handoff.md`](docs/owner-handoff.md) - owner 5 step 代行手順
- [`docs/client-cheatsheet.md.template`](docs/client-cheatsheet.md.template) - client 常設カンペ (印刷推奨)
- [`docs/recovery.md`](docs/recovery.md) - 「Claude が壊した」復旧ガイド
- [`docs/installation.md`](docs/installation.md) - v0.2 installation guide
- [`docs/backlog.md`](docs/backlog.md) - Phase 2-13 roadmap

## 設計 spec / plan (owner 用、office-tada 配下)

- [v0.2 spec](https://github.com/Hakuunsai/office-tada-secretary/blob/master/docs/superpowers/specs/2026-05-27-cc-client-setup-v0.2-design.md) (commit `6a2a50d5`)
- [v0.2 plan](https://github.com/Hakuunsai/office-tada-secretary/blob/master/docs/superpowers/plans/2026-05-27-cc-client-setup-v0.2.md)

(これら paperwork は office-tada 内に保管、kit repo には含めない)

## hearing 2 段階構造 (重要)

owner ruling Q10 (cc-client-setup v0.2 spec Section 5.1) 由来:

- **Phase A (owner hearing)**: office-tada 秘書が owner 相手に、owner が知る事項のみ (企業名 / 担当者 / レガシーシステム概要 / owner 連絡先 / contact 方針) を hearing
- **Phase B (client hearing)**: client PC 秘書 (cc-company `/company:company`) が client 本人相手に、client が知る事項のみ (業務概要 / 業務範囲 / 業界 common sense) を hearing
- **marker placeholder 方式**: client setup 直後は Phase B 領域に `<<<CLIENT_HEARING_PENDING>>>` marker、client が次に claude 起動した最初の chat で秘書が自律的に hearing 主導

owner / client が別法人前提、業務情報の sync 経路はない (一方向 owner → client seed のみ、remote 連携 0)。

## 5 つの目的の柱

1. セキュリティ rules (機密 access 禁止 / シークレットハードコード抑止 / 外部通信制限)
2. 実装許可制 + 「余計なことしない」
3. settings.json (permissions + 4 hook 種)
4. git 巻き戻し体制 (auto-checkpoint)
5. 秘書簡略版 + cc-company plugin

+ 3 新規要素 (v0.2 で追加):
6. 起動直後の秘書振舞い (SessionStart hook で `/company:company` 自動発動)
7. 記憶の引継ぎ (owner → client 一方向、kit 同梱 seed、remote 連携 0)
8. フルセットハーネス (cc-company + git-workflow + superpowers)

## ライセンス + 配布

private 配布対象 (owner / owner クライアント限定)、外部公開しない。本 repo は public だが、クライアント案件 fee 部分は owner 自社契約に含まれる。

## 改訂履歴

- v0.2 (2026-05-27): Approach W (Claude self-setup) で大ピボット、PowerShell bootstrap 廃止、hearing 2 段階構造 (owner ruling Q10) 反映
- v0.1 (2026-05-26): Phase 1 MVP (PowerShell bootstrap)、deprecated-by-v0.2
