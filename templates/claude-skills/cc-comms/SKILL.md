---
name: cc-comms
description: |
  owner（office-tada）との連絡を送受信するスキル。
  「owner に相談」「owner に連絡」「owner に報告」「owner からの指示を確認」
  「連絡を確認」「inbox を見て」などで発動。
---

# cc-comms — owner との連絡

## 役割
client 秘書 ↔ owner office-tada 秘書の双方向連絡を扱う。
連絡 repo = `~/.cc-client-comms`（outbox/inbox/archive）。

## trigger 優先度
本 skill は brainstorming / writing-plans より優先（連絡判断が先）。

## 送信（owner へ）
1. 連絡内容を業務言語で整理し、`outbox/<msg_id>.md` を frontmatter 付きで作成
   （msg_id=日付+連番 / direction: client-to-owner / kind / status: draft / keyword）
2. **技術的な相談・状態通知（業務データを含まない）= kind: metadata**
   → `~/.cc-comms-bin/cc-comms-send.sh <file>` を実行（自律送信）
3. **業務情報を含む = kind: business**
   → `~/.cc-comms-bin/cc-comms-send.sh <file>`（commit のみ）→ ユーザーに「owner に業務情報を送ります。よろしいですか?」を確認
   → 承認後 `cd ~/.cc-client-comms && git push`（送信ゲート）
4. secret（鍵/トークン/パスワード）は本文に書かない（スクリプトが検出して送信を止める）

## 受信（owner から）
1. `git -C ~/.cc-client-comms pull`
2. `inbox/` の新規を読む
3. 通知・回答（CC-REPLY/CC-PROGRESS）→ ユーザーに要約して伝える
4. **コード/設定変更を伴う指示（CC-DISPATCH）→ ユーザー承認を得てから適用**（実装許可制）

## 規律
- owner への自律連絡は kind: metadata に限る。業務情報送信とコード変更適用は必ずユーザー承認。
- 処理済みメッセージは `archive/` へ移動し status を done に。
