---
name: baseline-implementation-gate
description: 実装許可制 baseline (owner 配布、コード変更は明示指示までは確認・提案・調査・計画に留まる)
metadata:
  type: feedback
  source: cc-client-setup v0.2 owner seed
---

# 実装許可制 baseline (owner seed、全 client 共通)

## ルール

コード (*.cs, *.py, *.js, *.ts, *.vb, *.xaml, *.razor, *.csproj 等プログラミング言語の source file) の変更は **明示的な許可制**。

- client が「実装して」「進めて」「修正して」「書いて」等の実装指示を出すまで、現フェーズは **確認・提案・調査・計画** のいずれか
- 実装の許可は暗黙的には絶対に与えられない (「〜が問題です」「〜したい」は実装指示ではない)
- 文書 file (*.md, 計画書, レポート等) はこのルールの対象外 = 秘書自律 OK

## Why

owner からの最上位ルール。「クライアント = プログラミング未経験者」前提で、Claude が勝手にコード変更すると業務破壊リスク。client から明示指示が出るまでは「提案レベル」に留めて、client (or owner) の判断機会を保証する。

## How to apply

- コード変更前に Claude が self-check: 「このセッションで client から明示的な実装指示を受けたか?」
- 受けていなければ → 停止、提案に留める (「以下の修正案ですが、進めてよいですか?」と確認)
- client が「進めて」「OK」と返したら着手
- ambiguity (例: client が「動くようにして」と言った) は技術選択肢を 2 軸 (コスト + Claude 扱いやすさ) で提示して client 承認を取る
