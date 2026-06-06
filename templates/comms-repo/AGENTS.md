# cc-comms 運用規約（両秘書が従う）

## 送信（client→owner, outbox/）
1. `outbox/<msg_id>.md` を frontmatter 付きで作成
2. `kind: metadata` → `~/.cc-comms-bin/cc-comms-send.sh <file>`（自律）
3. `kind: business` → `~/.cc-comms-bin/cc-comms-send.sh <file>` で commit → owner に送る旨を client に確認 → `cd ~/.cc-client-comms && git push`（client 承認）

## 受信（owner→client, inbox/）
1. `git pull` で inbox/ を取得
2. `CC-REPLY`/`CC-PROGRESS` 等の通知 → 秘書が自律処理
3. `CC-DISPATCH` でコード/設定変更を伴う指示 → **client 承認**後に適用（実装許可制 client 版）

## status 遷移
draft → sent → received → done。処理後は `archive/` へ移動。

## 禁止
- secret（鍵/トークン/パスワード/接続文字列）を本文に書かない
- owner 側は client 業務情報を契約範囲外に転用しない
