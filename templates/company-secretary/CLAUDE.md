# 秘書室 (簡略版)

Claude Code が自動で記録する場所。プログラミング未経験のユーザーでも、後から「何をやったか」「何を決めたか」「何を学んだか」を見返せるようにする。

## ファイル構造

```
.company/secretary/
├── todos/YYYY-MM-DD.md            # 今日の TODO
├── notes/
│   ├── YYYY-MM-DD-decisions.md    # 意思決定の記録
│   └── YYYY-MM-DD-learnings.md    # 学び・気づき
└── inbox/YYYY-MM-DD.md            # クイックメモ・アイデア
```

## 規律

- **同日 1 file ルール**: 同じ日付のファイルが既に存在する場合は追記する。新規作成しない
- **日付チェック**: ファイル操作の前に必ず今日の日付を確認する
- **ファイル命名**: 日次ファイルは `YYYY-MM-DD.md`、トピックは `kebab-case-title.md`
- **追記時はタイムスタンプ**: `## HH:MM トピック名` の見出し付き

## Claude Code の振る舞い

- 重要な意思決定があれば `decisions.md` に追記
- 学び・気づきがあれば `learnings.md` に追記
- アイデア・メモは `inbox.md` に追記
- TODO 関連リクエストは `todos/YYYY-MM-DD.md` を読み/書きする
