# アクセス禁止ファイル

以下のパターンに一致するファイルは読まない・開かない・編集しない。例外なし。

## 禁止パターン

**Local ファイル**: `*Local.cs`, `*Local.vb`, `*.Local.*`（.csproj, .json, .config, .xaml 等）
**機密情報**: `secrets.json`, `secrets.*.json`, `*.secret`, `*.secrets`, `.env`, `.env.*`
**認証・鍵**: `*.pem`, `*.key`, `*.pfx`, `*.p12`, `.ssh/**`, `id_rsa*`, `.aws/**`, `.azure/**`, `credentials`, `service-account*.json`
**名前に含む**: `password`, `token`, `credential`, `secret`, `apikey`, `api_key`, `api-key`（.md は除く）
**Codex 関連** (v0.5 追加): `~/.codex/auth.json`, `~/.codex/sessions/*`, `~/.codex/auth.*`

※ Codex 認証情報は Codex CLI 自身が管理。秘書も Codex も触らない (3 重防御の層 3)。

## 許可される操作

- ファイルの存在確認（名前のみ）
- 禁止パターンについての説明
- 非Localバージョンのファイルの提案

## 検出時

アクセス拒否し、該当パターンと代替案をユーザーに提示する。
