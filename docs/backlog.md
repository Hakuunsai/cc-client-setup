# Phase 2+ Backlog

Phase 1 MVP 実装中に検出した improvement 候補。Phase 2 以降で別 spec / sprint として着手。

## 既知の限界 (Phase 1 MVP 受容済)

### B-1: settings.json deny pattern も regex robust 化が必要

**起源**: 2026-05-26 Task 8 Codex review High finding 由来 + Task 17 review concerns。

**症状**: hook 側 (`PreToolUse-DenyDangerous.ps1`) は `pwsh -NoProfile -c "curl ..."` 等オプション挟み込み迂回に対応済 (regex に `\b.*?\s+` lazy match) が、`settings.json.template` の `permissions.deny` の同等 pattern (`Bash(powershell -Command:*)` 等) は同じ迂回問題を抱える。深層防御の二重とも素通りリスク残。

**対応案**: Claude Code permissions deny pattern は prefix match のみ対応 (regex 不可)。代替として:
- (a) deny 数を増やし、`Bash(pwsh:*)`, `Bash(powershell.exe:*)`, `Bash(cmd.exe:*)`, `Bash(pwsh -NoProfile:*)` 等の variant を網羅
- (b) PreToolUse hook 1 本に防御を集約し、settings.json deny は最小限のみ (false positive 防止)

**判断時期**: Phase 2 着手時、Claude Code permissions の最新仕様を確認してから。

---

### B-2: settings.json hook path `<USER>` 置換の HomeRoot 不整合

**起源**: 2026-05-26 Task 17 Codex review High finding 由来。

**症状**: `Install-ClaudeCodeSettings` が `settings.json.template` の `<USER>` を `$UserName` で置換するが、hook reference path は `C:/Users/<USER>/.claude/hooks/...` で固定形式。production 環境 (`$env:USERPROFILE = C:\Users\<actual user>` + `$env:USERNAME = <actual user>`) では一致するが、TestHomeOverride 経由 (e.g. `/tmp/cc-home-xxxx`) では hook reference path が間違う。

**production には影響なし** (TestHomeOverride 不使用)、test スコープ内のみ。

**対応案**: `settings.json.template` の hook path を `<HOOK_PATH>` placeholder にして、`Install-ClaudeCodeSettings -HookPath $HomeRoot/.claude/hooks` で置換するよう refactor。

**判断時期**: Phase 2 着手時。

---

### B-3: docs/client-cheatsheet.md `owner に連絡 (XXX)` の populate

**起源**: 2026-05-26 Task 19 Codex review action item。

**症状**: `cheatsheet.md` の owner 連絡先が `(XXX)` placeholder。Phase 1 MVP では owner が PJ ごとに手動で populate する想定だが、template auto-fill 機能で自動化可能。

**対応案**: `Setup-CCClientSetup.ps1` に `-OwnerContact` parameter 追加、Install-Cheatsheet 関数 (新規) で client-cheatsheet.md を copy → `(XXX)` を `$OwnerContact` で置換。

**判断時期**: Phase 2 着手時、複数クライアントに同時配布する状況になってから。

---

### B-4: docs/recovery.md に irreversible operation warning

**起源**: 2026-05-26 Task 20 review minor item。

**症状**: recovery.md の Level 2 (`git reset --hard`) と Level 3 (`git reflog` + reset) は破壊的操作。クライアント (プログラミング未経験) が誤って実行するリスク。冒頭の警告が薄い。

**対応案**: recovery.md 冒頭に `⚠️ 重要` block 追加、Level 2 以降は事前に `git stash push` 推奨を明示。

**判断時期**: Phase 2 着手時、または初回クライアント実運用で誤実行発生時。

---

## Phase 2+ 機能拡張候補 (spec から)

Phase 1 MVP spec の Phase 2+ roadmap section と同期:

| Phase | scope | trigger |
|---|---|---|
| Phase 2 | 言語別 `.gitignore` variant (.NET / Node / Python / Go) + PJ 別 `.claude/settings.json` の言語別テンプレ | クライアント 1-2 社運用後 |
| Phase 3 | 既存コード遡及 security audit skill | 予防取りこぼし発生時 |
| Phase 4 | 部署自然追加 mechanism + 3 問 onboarding | クライアント業務拡大時 |
| Phase 5 | D-番号 + lock + agent-status sub-block (並行運用機構) | クライアント並行運用ニーズ発生時 |
| Phase 6 | PowerShell module 化 + auto-update 機構 | install 済クライアント 3+ 社時 |
| Phase 7 | Codex / Win-Codex 連携 hook | クライアント Codex 利用開始時 |

---

## メンテ前提

- 本 backlog は owner が随時 review、Phase 2 着手時に該当項目を spec / plan 化
- owner 直接修正 (Phase 1 MVP 配布前の hotfix 等) は本 backlog 不要 (直接 commit)
- 新規 backlog 候補は本 file に追記 (kebab-case-title.md トピック分離は将来検討)
