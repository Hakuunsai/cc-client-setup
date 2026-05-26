# ネットワーク・機密アクセス制限

## 外部通信の禁止
- curl, wget, Invoke-WebRequest, Invoke-RestMethod を Bash で実行しない
- python, node を直接 Bash で実行しない（HTTP通信によるセキュリティバイパスのリスク）
- 外部通信が必要な場合は WebFetch ツールを使用する

## 機密ファイル・ディレクトリへのアクセス禁止
- ~/.ssh/*, ~/.aws/*, ~/.azure/*, ~/.config/gh/* にアクセスしない
- .env, secrets.json, *.secret にアクセスしない
- 環境変数の一括表示（env, printenv, set）を実行しない

## パッケージインストールの禁止
- pip install, npm install を Bash で実行しない（サプライチェーンリスク）
- パッケージの追加が必要な場合はユーザーに手動実行を依頼する

## ネスト実行の禁止
- powershell -Command, cmd /c, bash -c によるネスト実行をしない（hook回避のリスク）
