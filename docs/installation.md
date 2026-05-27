# cc-client-setup v0.2 - installation guide

v0.2 では PowerShell bootstrap script を廃止 (`Setup-CCClientSetup.ps1` 削除)。Claude Code 自身を agent としてセットアップ実行 (Approach W)。

## 全体フロー

```
[Step 0] office-tada 秘書 Phase A hearing (owner 別 session、10-20 min)
   ↓ kit-prompt-{client-id}.md / seed-client-persona-{client-id}.md / cheatsheet-{client-id}.md 生成
[Step 1] client PC 環境準備 (Claude Code + Git for Windows install)
[Step 2] フォルダ作成 + claude 起動
[Step 3] kit-prompt.md paste → Claude が自律 setup (15-25 min)
[Step 4] 完了確認 + cheatsheet 配布
[Step 5] claude 再起動 + SessionStart hook 確認 (option: client 同席で Phase B hearing 実行)
```

合計 30-40 min (1 PC、Step 0 別途)。

## 詳細手順

詳細は `docs/owner-handoff.md` 参照。本 file は概要のみ。

## Phase B (client hearing) について

owner setup 完了後、`~/.cc-client-memory/seed-client-persona.md` に Phase B marker `<<<CLIENT_HEARING_PENDING>>>` が残ります。次に client が claude 起動した最初の chat で秘書が自律 hearing を主導します (詳細 `hearing-sop-client.md`)。

## 更新時 (kit 改訂)

owner が kit (`Hakuunsai/cc-client-setup`) を改訂した case、client PC に差分適用する手順:

```
[Step 1] owner が改訂 commit を `Hakuunsai/cc-client-setup` に push
[Step 2] owner が `kit-prompt-update.md` を改訂 (差分対象 file を列挙)
[Step 3] owner connect → client PC で claude 起動 → kit-prompt-update.md paste
[Step 4] Claude が差分のみ apply (5-10 min)
[Step 5] claude 再起動で動作確認
```

`seed-client-persona.md` の client 領域 (Phase B 結果) は保護対象、update で overwrite されません。

## トラブルシュート

詳細は `docs/recovery.md` 参照。
