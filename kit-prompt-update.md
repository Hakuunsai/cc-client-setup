# cc-client-setup v0.2 update prompt (差分指示書)

このプロンプトは Claude Code (あなた) が、既にセットアップ済の client PC に対して
**差分のみ**を冪等に適用するための指示書です。

## 前提

- 既に kit-prompt.md (initial setup) が実行済 (~/.claude/{rules,hooks,CLAUDE.md,settings.json} + ~/.cc-client-memory/ + {company-name}/ 配置済)
- owner が「以下の file を改訂しました」と差分を列挙 (本 prompt 末尾の "改訂対象" section)
- 差分のみ適用、それ以外は touch しない (冪等性、client の auto memory `feedback-*.md` / `user-*.md` には影響なし)

## per-client placeholders

- `{COMPANY_NAME}`: クライアント企業名 (cheatsheet 改訂時のみ必要)
- `{OWNER_CONTACT}`: owner 連絡先 (同上)

## あなたの仕事

下記 "改訂対象" section に列挙された file のみ、kit raw URL prefix から WebFetch + Write (既存 file あれば `*.bak.YYYYMMDDTHHmmss` に backup 後 overwrite)。

```
kit raw URL prefix = https://raw.githubusercontent.com/Hakuunsai/cc-client-setup/main/
```

## 改訂対象 (owner が編集して paste 時に列挙)

下記 file のみ差分適用してください:

- [ ] {file path 1} (例: `~/.claude/rules/security-essentials.md` → 新版、deny rule 3 追加)
- [ ] {file path 2} (例: `~/.cc-client-memory/seed-baseline-secretary-posture.md` → 新版、姿勢英文の言い回し改善)
- [ ] {file path 3} (任意)

(他 file は touch しない。`~/.cc-client-memory/seed-client-persona.md` の client 領域 (Phase B 結果) は保護対象、絶対 overwrite しないこと。)

## 完了確認 + 報告

```bash
# 改訂対象 file の存在 + sanity check
for f in {改訂対象 file list}; do
  test -f "$f" && echo "$f OK"
done
```

完了後 owner に出力:
```
✅ cc-client-setup v0.2 update 完了 (revision YYYY-MM-DD)
改訂 file: {count}
client 領域 (Phase B 結果) は保護維持
```
