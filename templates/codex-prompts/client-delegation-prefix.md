# Codex 委譲 prompt prefix (client 代行モード)

秘書が `mcp__codex__codex` 経由で Codex に委譲する際、prompt 冒頭に固定挿入するテンプレートです。

## prefix 本体 (秘書が動的 placeholder 置換して使用)

```
【client 代行モード】

あなたは {COMPANY_NAME} の業務システム担当 client から委譲されたコーディングタスクを実行します。以下の規律を厳守してください:

【規律】
- 最上位ルール「実装許可制」遵守 (= 与えられた task 以外のコード変更禁止)
- forbidden-files 規律遵守 (`~/.codex/auth.json` `~/.codex/sessions/*` `~/.cc-client-memory/` `~/.claude/` `*.env` 等 access 禁止)
- cwd `{client-repo}` 配下のみ Edit/Write 許可、上位ディレクトリ書き込み禁止
- 業務文脈 (client persona、業務概要のみ technical 詳細含まない):
{client-business-overview}

【sandbox】
- workspace-write mode、cwd 限定
- 規律違反検出時は秘書 verify gate で棄却される (3 重防御の層 3)

【task】
{秘書からの委譲 prompt 本体}
```

## placeholder 置換ルール (秘書が動的解決)

| placeholder | 値の source |
|---|---|
| `{COMPANY_NAME}` | `~/.cc-client-memory/seed-client-persona.md` owner 領域から抽出 |
| `{client-repo}` | cwd 絶対パス (`pwd` 実行結果) |
| `{client-business-overview}` | `~/.cc-client-memory/seed-client-persona.md` の Phase B hearing 結果「業務概要」section のみ抽出 (技術用語含まず、業務言語のみ) |
| `{秘書からの委譲 prompt 本体}` | 秘書が状況依存で生成 (= レビュー指示 or 実装委譲指示) |

## 利用シーン

秘書が Codex 委譲判断 (= `~/.claude/CLAUDE.md` 「6 柱」§6 trigger 表 lookup) 後、`mcp__codex__codex` 呼び出し時に本 prefix を prompt 冒頭に挿入。

### レビュー (mode: review) 利用例

```
{prefix 本体}

【task】
以下の diff を品質観点でレビューしてください。Critical / High / Medium / Low の severity で findings を整理してください。

{git diff 出力}
```

### 実装委譲 (mode: implement) 利用例

```
{prefix 本体}

【task】
client から以下の要求を受けました。実装してください:

{client 業務要求の業務言語化版}

期待する成果物: {実装ファイル list + テスト方針}
```

## 3 重防御の層 3 (秘書 verify gate)

Codex 結果を受領後、秘書は以下を機械検証:

1. **forbidden-files パス侵害 grep**: 結果差分に `~/.codex/auth.json` / `~/.cc-client-memory/` / `~/.claude/` / `*.env` 等パス access が含まれないか
2. **cwd 外 Edit 検出**: 差分 file パスが cwd `{client-repo}` 配下のみか (相対パス + 絶対パス両方検査)
3. **業務適合性 check**: 結果が client persona 業務概要と整合しているか

違反検出時は Codex 結果を棄却 + 再委譲 or 秘書直接処理に切替。
