# cc-client-setup backlog (v0.5.0)

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
| 10 | pre-push hook secret regex check | memory push 経路復活時 (v0.2 では remote 連携 0) |
| 11 | client → owner memory upload 経路 (双方向 sync 化) | owner / client 合意 + 法的整理完了時 |
| 12 | client cheatsheet PDF 自動生成 | 「印刷品質低い」フィードバック時 |
| 13 | IT 在籍 / プログラマ常駐 client 用別 kit (cc-client-setup-pro 等) | IT スタッフ在籍 client 案件発生時 |

各 Phase は独立 spec / 別 sprint。v0.2 は Phase 2.1-13 をブロックしない範囲で薄く設計。

## 関連 reference

- spec: [`docs/superpowers/specs/2026-05-27-cc-client-setup-v0.2-design.md`](../../office-tada/docs/superpowers/specs/2026-05-27-cc-client-setup-v0.2-design.md) (office-tada 配下、commit `6a2a50d5`)
- plan: [`docs/superpowers/plans/2026-05-27-cc-client-setup-v0.2.md`](../../office-tada/docs/superpowers/plans/2026-05-27-cc-client-setup-v0.2.md) (office-tada 配下、本 plan)
