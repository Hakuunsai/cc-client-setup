# cc-client-setup backlog (v0.8.0)

## v0.8.0 cc-comms 連絡機構 sprint 完走 (2026-06-06)

per-client Private Git repo + deploy key による client 秘書 ↔ owner office-tada 双方向連絡機構 (cc-comms) を追加。Phase 10 相当の secret check (fail-closed) と Phase 11 相当の双方向連絡経路を一体統合実装。

| Task | 内容 |
|---|---|
| 送信スクリプト | `scripts/comms-send.sh` (kind=metadata / business 2 本立て、secret regex fail-closed、push/local-only 分岐) |
| repo 初期化 | `scripts/comms-init.sh` (per-client `~/.cc-client-comms/` bare + deploy key 生成 + Private repo 登録手順) |
| hook 連携 | Stop hook (`hooks/memory-local-commit.sh`) + comms 送信 trigger を kit-prompt 指示書に組込 |
| テスト | `tests/test-comms-send.sh` (11 ケース: metadata PASS / business local-only / secret refused / invalid kind / missing file / case-insensitive / inbox stray) |

cc-comms 設計原則: memory repo (`~/.cc-client-memory`) の local-only は維持し、連絡 payload のみ別 repo (`~/.cc-client-comms`) で remote 化。技術 metadata は自律 push、業務情報は client 承認後のみ push の 2 系統。

spec source of truth: [office-tada `docs/superpowers/specs/2026-06-06-cc-client-setup-cc-comms-design.md`](https://github.com/Hakuunsai/office-tada-secretary)。

## v0.7.0 Linux variant sprint 完走 (2026-06-06)

Linux 物理サーバー + VSCode Remote-SSH + Claude 拡張 構成向けに kit を Linux ネイティブ化 (案 A、Windows 版と完全併存)。roadmap Phase 9 (macOS / WSL サポート) の Linux 部分に相当。生命線前提「拡張 + Remote-SSH でも hook は リモート Linux 側で発火」を公式 docs で確証済。

| Task | 内容 |
|---|---|
| Task 1-3 (hook 移植) | `PreToolUse-DenyDangerous.sh` (jq で JSON 抽出、deny 等価 + フェイルオープン) / `PostToolUse-AutoCheckpoint.sh` (git stash) / `pre-commit.sh.template` (secret regex) を bash 移植 + TDD test 3 本 |
| Task 4 (settings) | `settings-user.linux.json.template` (hook 登録を `pwsh.exe` → `bash`、timeout 15) |
| Task 5 (kit-prompt) | `kit-prompt-linux.md` (cwd=`~/`、dnf install、単一 bash pre-commit、jq verify) + `client-cheatsheet.linux.md.template` (起動=VSCode 拡張パネル) |
| Task 6 (docs) | owner-handoff 「# Linux 版手順」+ installation.md Linux section + README OS 2 系統 + 本 backlog |
| Task 7 (Codex review) | セキュリティ hook (deny / auto-checkpoint / pre-commit) の等価性・バイパス耐性 review |

完了基準: bash hook 3本 dry-run PASS (`tests/`) + Windows 版無傷 + jq 前提明記。

**Codex review (verdict: failed → 3 件修正反映)**: ① pre-commit が working tree でなく staged blob を検査するよう修正 (add後 working tree clean 化のすり抜け防止) ② PostToolUse stash push 成功時のみ apply (無関係 stash 誤適用防止) ③ `--index` で staged 状態保持。各 finding に回帰テスト追加。

**Windows .ps1 parity debt (follow-up)**: 上記 3 件は Windows 版 (`PreToolUse-DenyDangerous.ps1` は無関係、`PostToolUse-AutoCheckpoint.ps1` + `pre-commit.ps1.template`) にも同じ潜在問題あり。本 sprint は「Windows 版無傷」制約のため未修正。別 sprint で `.ps1` 側にも同等修正を backport 候補 (Phase 2.x)。

spec source of truth: [office-tada `docs/superpowers/specs/2026-06-06-cc-client-setup-linux-variant-design.md`](https://github.com/Hakuunsai/office-tada-secretary)。

implementation plan: [office-tada `docs/superpowers/plans/2026-06-06-cc-client-setup-linux-variant.md`](https://github.com/Hakuunsai/office-tada-secretary) (9 Task)。

## v0.6.0 秘書 self-update orchestration sprint 完走 (2026-05-27)

owner / client が「cc-client 更新して」「kit 更新」「アップデート」trigger で kit-prompt 最新版 fetch + placeholders 置換 + 新 claude session paste 案内を秘書が自動オーケストレーション。v0.5 で確立した「秘書自動発動」「Codex 自動委譲 explicit 予告」pattern の自然な拡張。

| Layer | 内容 |
|---|---|
| Layer A (秘書振舞い) | secretary-claude.md.template に「cc-client 更新」trigger 行追加 + 新規 section「cc-client self-update 規律」追加 (Step A-D + 業務言語化規律 + 取得失敗 case fallback) |
| Layer B (kit-prompt self-document) | kit-prompt.md Step 14 owner 伝達文言に v0.6 self-update 経路周知追加、冒頭 title v0.6 bump |
| Layer C (cheatsheet 業務言語化) | client-cheatsheet.md.template「秘書 (Claude) との会話」section に self-update trigger 案内 1 行追加 |

fetch URL: `https://raw.githubusercontent.com/Hakuunsai/cc-client-setup/main/kit-prompt.md` (main HEAD 固定、owner ruling 2026-05-27)。

demo-001 verify は v0.5 + v0.6 まとめて別日 owner manual (= 「cc-client 更新して」trigger 経路自体を verify、kit-prompt 再実行で配備物 verify)。

sprint contract: [office-tada `.company/projects/cc-client-setup/backlogs/2026-05-27-v0.6-self-update-sprint-contract.md`](https://github.com/Hakuunsai/office-tada-secretary)。

spec source of truth: [office-tada `docs/superpowers/specs/2026-05-27-cc-client-setup-v0.6-self-update-design.md`](https://github.com/Hakuunsai/office-tada-secretary)。

## v0.5.0 Codex 委譲統合 sprint 完走 (2026-05-27)

v0.4.0 release 後の Codex 委譲統合 (= 別 AI 自動委譲 + sandbox 規律) を 1 sprint で実装、v0.5.0 release (minor bump)。owner ruling 2026-05-27 由来。

| Layer | 内容 |
|---|---|
| Layer 1 (実体 install) | kit-prompt.md Step 11.5 (Node.js + Codex CLI install) + Step 11.6 (owner manual `codex login` OAuth flow 案内) + Step 11b に `codex@openai-codex` plugin install 追加 + Step 12 配備確認に Codex verify list 追加 |
| Layer 2 (規律 templates) | claude-md-user.template 5 柱 → 6 柱化 (第 6 柱 = Codex 自動委譲規律) + secretary-claude.md.template に Codex 委譲規律 section 追加 (skill 自動発動 table 拡張 + 業務言語化規律 + verify gate + 利用不能 規律) + client-cheatsheet.md.template「困ったとき」table に Codex unavailable 3 case 追加 + seed-baseline-secretary-posture.md に Codex 自動委譲 baseline 追記 |
| Layer 3 (sandbox 安全装置) | settings-user.json.template `enabledPlugins` + `extraKnownMarketplaces` に `openai-codex` 追加 + permissions deny に `Bash(codex *)` 追加 + forbidden-files.md に `~/.codex/auth.json` 等追加 + Codex prompt prefix template (`templates/codex-prompts/client-delegation-prefix.md`) 新規作成 |

demo-001 verify (2026-05-27 release 後、owner 手動 5 件、別日):
1. Codex 実体配備 verify (`node --version` / `codex --version` / `~/.codex/auth.json` 存在)
2. Codex review 自動発動 verify
3. Codex 実装委譲 自動発動 verify
4. Sandbox 規律 verify (forbidden パス侵害検出)
5. Codex unavailable fallback verify (ユーザー = 秘書二者で完結、owner connect 経路不使用)

sprint contract: [office-tada `.company/projects/cc-client-setup/backlogs/2026-05-27-v0.5-codex-delegation-sprint-contract.md`](https://github.com/Hakuunsai/office-tada-secretary)。

spec source of truth: [office-tada `docs/superpowers/specs/2026-05-27-cc-client-setup-v0.5-codex-delegation-design.md`](https://github.com/Hakuunsai/office-tada-secretary)。

implementation plan: [office-tada `docs/superpowers/plans/2026-05-27-cc-client-setup-v0.5-codex-delegation.md`](https://github.com/Hakuunsai/office-tada-secretary) (12 Task)。

## v0.4.0 Phase 2.x sprint 完走 (2026-05-27)

v0.3.0 release 後の demo-001 verify 由来 4 件を 1 sprint で集中処理、v0.4.0 release。

| Task | 内容 | commit |
|---|---|---|
| 2.x-2 (F-5) | git-workflow direct skill 同梱 (templates/claude-skills/git-workflow/ 経路追加、kit-prompt Step 11 を 11a + 11b に分割、settings template から git-workflow@cc-company 削除) | bf1f6e2 |
| 2.x-1 (F-6) | superpowers install 経路 audit + 再発防止策 (kit-prompt Step 11b に marketplace update + restart 1-2 回 fallback 案内、docs/installation.md に補足 section 追加) | 9e4578c |
| 2.x-4 (秘書 principle) | 秘書 superpowers / git-workflow skill 自動発動規律 (secretary-claude.md.template + seed-baseline-secretary-posture.md を 8 則化、cheatsheet template + kit-prompt Step 14 status に反映、owner ruling 2026-05-27 由来) | 71ccbb3 |
| 2.x-3 (spec cleanup) | spec v0.4-draft → v0.5-approved bump (Section 5.4.4 owner connect 書換、Section 8.3 7 則 → 8 則化、改訂履歴 v0.5-approved entry 追加) | office-tada side (別 repo) |

demo-001 verify status (2026-05-27 owner 報告):
- superpowers 主要 skill (`brainstorming` / `writing-plans` / `using-superpowers`) 発動 ✅
- git-workflow direct skill 配置後の発動 verify は v0.4.0 release 後 owner 手動

sprint contract: [office-tada `.company/projects/cc-client-setup/backlogs/2026-05-27-phase-2-x-sprint-contract.md` (v1.3-amended)](https://github.com/Hakuunsai/office-tada-secretary)。

## Phase 1 backlog の v0.2 での扱い

Phase 1 MVP (commit `4a64fcd` HEAD、freeze 中、deprecated-by-v0.2) で起票された B-1〜B-4 を v0.2 で再評価:

| B 番号 | Phase 1 内容 | v0.2 での扱い |
|---|---|---|
| B-1 | settings.json deny pattern regex robust 化 (hook 側対応済、deny pattern は prefix only で限界) | **残課題、Phase 2.1 持越し** (Claude Code schema 改善時に対応) |
| B-2 | settings.json hook path `<USER>` 置換の HomeRoot 不整合 | **v0.2 で解消** (kit-prompt.md Step 3 で Claude が `$env:USERPROFILE` を動的解決) |
| B-3 | docs/client-cheatsheet.md `owner に連絡 (XXX)` の populate 自動化 | **v0.2 で解消** (office-tada 秘書 Phase A hearing で `{OWNER_CONTACT}` 取得 + Claude が cheatsheet template で置換) |
| B-4 | docs/recovery.md に irreversible operation warning 追加 | **流用、Phase 2.2 で拡充** (初回 client incident 発生時) |

## Phase 2+ roadmap (v0.2 spec Section 7.2 由来、本 plan では実装しない)

| Phase | scope 候補 | trigger |
|---|---|---|
| 2.1 | settings.json deny pattern regex robust 化 (B-1 持越し) | Claude Code schema 改善時 |
| 2.2 | recovery.md irreversible operation warning 拡充 (B-4 持越し) | 初回 client incident 発生時 |
| 3 | 言語別 `.gitignore` variant (.NET / Node / Python / Go) + PJ 別 settings.json | 最初 1-2 社運用 + 共通言語確定後 |
| 4 | 既存コード遡及 security audit skill | 予防取りこぼし発生時 |
| 5 | 部署自然追加 mechanism + 3 問 onboarding (cc-company v2.1.0 機能後 merge) | client 業務拡大時 |
| 6 | D-番号 + lock + agent-status sub-block (並行運用機構) | client 側並行 Claude Code 運用ニーズ発生時 |
| 7 | auto-update 配信機構 (kit-prompt-update.md 自動 carry 化) | install 済 client 3+ 社、update 頻度上昇時 |
| 8 | Codex / Win-Codex 連携 hook | client が Codex 利用開始時 |
| 9 | macOS / WSL サポート | client OS 多様化時 |
| 10 | pre-push hook secret regex check | memory push 経路復活時 (v0.2 では remote 連携 0) — **本 spec で実装 (spec 2026-06-06、cc-comms 連絡機構)**: cc-comms は secret check (fail-closed、送信スクリプト `comms-send.sh` 内) を Phase 10 相当として統合。memory repo local-only 維持のまま連絡 payload 別 repo で remote 化。 |
| 11 | client → owner memory upload 経路 (双方向 sync 化) | owner / client 合意 + 法的整理完了時 — **本 spec で実装 (spec 2026-06-06、cc-comms 連絡機構)**: cc-comms は双方向連絡 (per-client Private Git repo + deploy key) を Phase 11 相当として統合。memory repo (`~/.cc-client-memory`) の local-only は維持し、連絡 payload のみ別 repo (`~/.cc-client-comms`) で remote 化。技術 metadata 自律 push / 業務情報 client 承認後 push の 2 系統。Phase 10 + Phase 11 を一体実装。 |
| 12 | client cheatsheet PDF 自動生成 | 「印刷品質低い」フィードバック時 |
| 13 | IT 在籍 / プログラマ常駐 client 用別 kit (cc-client-setup-pro 等) | IT スタッフ在籍 client 案件発生時 |

各 Phase は独立 spec / 別 sprint。v0.2 は Phase 2.1-13 をブロックしない範囲で薄く設計。

## 関連 reference

- spec: [`docs/superpowers/specs/2026-05-27-cc-client-setup-v0.2-design.md`](../../office-tada/docs/superpowers/specs/2026-05-27-cc-client-setup-v0.2-design.md) (office-tada 配下、commit `6a2a50d5`)
- plan: [`docs/superpowers/plans/2026-05-27-cc-client-setup-v0.2.md`](../../office-tada/docs/superpowers/plans/2026-05-27-cc-client-setup-v0.2.md) (office-tada 配下、本 plan)
