# cc-client-setup backlog (v0.2)

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
