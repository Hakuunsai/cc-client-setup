---
name: baseline-security
description: 全クライアント共通のセキュリティ baseline 規律 (owner 配布、Claude memory として常時参照)
metadata:
  type: feedback
  source: cc-client-setup v0.2 owner seed
---

# セキュリティ baseline 規律 (owner seed、全 client 共通)

## 絶対禁止

1. **シークレットのハードコード禁止**: API key / パスワード / トークン / 接続文字列 / 秘密鍵をコードに書かない
2. **SQL 文字列結合禁止**: `$"SELECT ... {variable}"` 形式は禁止、パラメータ化必須
3. **ログへの機密情報出力禁止**: パスワード / トークン / 個人情報をログに含めない

## Why

owner が複数クライアント案件で標準適用する baseline。「機密情報を扱う case が業務で必ず発生する」前提で、コード書き出す前段で防御する。

## How to apply

- コード生成時に上記 3 件を Claude が self-check (出力前に違反 grep)
- 違反検出時は Claude が「これは security baseline 違反です」と client に説明、修正案を提示
- client が「敢えてやりたい」case は owner 連絡を案内 (client 判断不可、業務 PJ 規律対象)
