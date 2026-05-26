# アクセス禁止ファイル

以下のパターンに一致するファイルは読まない・開かない・編集しない。例外なし。

## 禁止パターン

**Local ファイル**: `*Local.cs`, `*Local.vb`, `*.Local.*`（.csproj, .json, .config, .xaml 等）
**機密情報**: `secrets.json`, `secrets.*.json`, `*.secret`, `*.secrets`, `.env`, `.env.*`
**認証・鍵**: `*.pem`, `*.key`, `*.pfx`, `*.p12`, `.ssh/**`, `id_rsa*`, `.aws/**`, `.azure/**`, `credentials`, `service-account*.json`
**名前に含む**: `password`, `token`, `credential`, `secret`, `apikey`, `api_key`, `api-key`（.md は除く）

## 許可される操作

- ファイルの存在確認（名前のみ）
- 禁止パターンについての説明
- 非Localバージョンのファイルの提案

## 検出時

アクセス拒否し、該当パターンと代替案をユーザーに提示する。
