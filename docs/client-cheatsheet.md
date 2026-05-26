# Claude Code 使い方カンペ (1 枚)

## 基本

- ターミナルで `claude` と打って起動
- 終わる時は `/exit` または `Ctrl+D`

## Claude にお願いする時のコツ

1. **「実装して」「修正して」「書いて」と明示**するまで、Claude は実装しない (確認・計画のみ)
2. **「余計なことするな」と書いてある**ので、頼んだこと以外は触らない
3. **危ないコマンドは deny される** (curl / pip install / .env Read など)

## おかしくなった時の巻き戻し方

1. Claude の Edit/Write の直後に自動で **stash バックアップ** が取られている
2. 確認: `git stash list` (赤い文字で `[claude-auto-checkpoint] 2026-...` が並ぶ)
3. 戻す: `git stash apply stash@{N}` (N は番号、`stash@{0}` が一番最近)
4. もっと前は `git reflog` で表示される全 commit から探す → `git reset --hard <hash>` (Claude に頼んで OK)

## 履歴を見たい時

- 何を決めたか → `.company/secretary/notes/` の `*-decisions.md`
- 何を学んだか → `.company/secretary/notes/` の `*-learnings.md`
- 今日の TODO → `.company/secretary/todos/<日付>.md`

## 困ったら

- owner に連絡 (XXX)
- 緊急停止: `claude` ターミナルで `Ctrl+C` 2 回
