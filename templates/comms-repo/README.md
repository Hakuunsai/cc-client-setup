# cc-client-comms-{client-id}

cc-client（client 秘書AI）↔ office-tada（owner 秘書AI）の双方向連絡 repo。
office-tada が所有する Private repo。client は deploy key で write する。

## ディレクトリ
- `outbox/` : client → owner（client が書いて送る）
- `inbox/`  : owner → client（owner が書いて送る、client が pull）
- `archive/`: 処理済みメッセージ

## メッセージ形式（frontmatter + 本文）
- `msg_id` 一意 / `direction` / `kind: metadata|business` / `status` / `created_at` / `keyword` / `secret_check`
- 合言葉: client→owner `CC-ESCALATE`/`CC-PROGRESS`、owner→client `CC-DISPATCH`/`CC-REPLY`、完了 `CC-DONE`

## 送信規律
- 技術metadata: 秘書が `cc-comms-send.sh` 経由で自律送信（secret check fail-closed + kind 強制を通過）
- 業務情報: `kind: business`。秘書は commit のみ、**client 承認の raw `git push`** で送信
- secret（API key/password/token/秘密鍵）は送信前 check で block。検出時は送らない
