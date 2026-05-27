---
name: git-workflow
description: |
  Git操作を円滑に実行するためのスキル。
  権限エラーやコミットメッセージのエラーを防止する。
  「コミットして」「プッシュして」「プルして」
  「ブランチを作って」「ブランチ切って」「ブランチを消して」
  「マージして」「ワークツリーを追加」「worktree作って」
  「ワークツリーを削除」「commit」「push」「pull」「merge」
  などのリクエストで自動適用される。
---

# Git Workflow Skill

Git操作を円滑に実行するためのスキル。

## 役割

- **何を**: Git操作（commit, push, pull, branch, merge, worktree）
- **いつ**: ユーザーからGit操作の指示があった時
- **どう**: 権限エラーを回避し、一貫したルールで実行

---

## コミット前 Codex レビュー（最優先・前処理）

**「コミットしてください」単位で1回**、実際の `git commit` 実行前に Codex レビューを自動実行する。Claude Code が内部で commit を分割する場合でも Codex レビューは1回のみ（冒頭で1回走らせる）。

### フロー

1. **差分キャプチャ**
   - `git -C <path> status`
   - `git -C <path> diff HEAD`（staged + unstaged のトラッキング済み変更）
   - `git -C <path> ls-files --others --exclude-standard`（未追跡の新規ファイル一覧）
   - 新規ファイルの内容は必要に応じて `Read` で取得し、差分材料に含める

2. **スキップ判定**

   以下のいずれかに該当する場合、Codex レビューをスキップして通常のコミットフローに直行する。スキップした旨はユーザーに明示報告する。

   | 条件 | 判定方法 |
   |---|---|
   | **ドキュメント/コメントのみの差分** | 変更ファイルが全て `*.md` / `docs/` 配下 / コード内コメント行のみ（ロジック行に変更なし） |
   | **ユーザーが「Codex 不要」「codex skip」等を明言** | コミット指示文面を確認 |
   | **codex skill の「委譲しない場合」に該当** | typo 修正のみ / 1ファイルで完結する軽微な変更 |

3. **Codex レビュー実行**

   `codex` スキルの「Codex 実行コマンド」と「Retry 別 focus text テンプレート」に従う。コミット前レビューは常に **パターン 1（初回レビュー）** を使用し、`/codex:adversarial-review --wait` 経由で実行する（手動 `codex exec` は Phase 3-A 移行で廃止）。実行中は数十秒〜数分程度かかる旨をユーザーに伝えておく。ハング兆候が出たら `/codex:cancel` で中断し、`codex` スキルの委譲失敗時対応（最大 3 回リトライ → Claude Code 自己レビュー代行）に従う。

4. **判定と分岐**

   | Codex の検出 | 挙動 |
   |---|---|
   | **Critical あり** | **commit 中断**。検出内容と修正提案をユーザーに提示して判断を仰ぐ |
   | **High あり（Critical なし）** | 一時停止。ユーザーに「修正してから commit するか / このまま commit するか」を確認 |
   | **Medium/Low のみ** | 警告表示してコミットフロー続行 |
   | **問題なし** | そのままコミットフロー続行 |
   | **Codex 委譲失敗** | `codex` スキルの委譲失敗時の対応（最大3回リトライ → Claude Code 自己レビュー代行）に従う |

5. **コミット実行**（従来フロー）
   - 下記 ルール に従って `git add` / `git commit` / `git push` を実行

### 省略できないケース

- コード変更を伴う commit は原則として上記フローを通すこと
- スキップ判定に該当しない限り Codex を走らせる
- 「急ぎだから」「小さい変更だから」は理由にならない（小さい変更は c1/c3 でスキップ対象になっているはず）

### 関連
- `codex` スキル: レビュー指示テンプレート、委譲失敗時の対応
- `code-review` スキル: レビュー観点
- office-tada `.company/secretary/notes/2026-04-10-e2e-enforcement-policy.md`: 運用背景

---

## ルール

### 1. パス指定（最重要）

**`cd && git` の複合コマンドは禁止。必ず `git -C` オプションを使用する。**

```bash
# ❌ 禁止（権限エラーになる）
cd /path/to/repo && git commit -m "message"

# ✅ 正しい方法
git -C /path/to/repo commit -m "message"
```

すべてのGitコマンドで `-C <path>` を使用すること：

```bash
git -C /path/to/repo status
git -C /path/to/repo add .
git -C /path/to/repo commit -m "message"
git -C /path/to/repo push origin branch-name
git -C /path/to/repo pull
git -C /path/to/repo checkout -b new-branch
git -C /path/to/repo branch -d old-branch
git -C /path/to/repo worktree add ../new-worktree branch-name
git -C /path/to/repo worktree remove ../old-worktree
```

### 2. コミットメッセージ

| ルール | 内容 |
|--------|------|
| 言語 | **英語のみ** |
| 文字数 | **50文字以内** |
| 改行 | **禁止（1行のみ）** |
| 形式 | **動詞始まり（命令形）** |

```bash
# ✅ 良い例
git commit -m "Add user authentication feature"
git commit -m "Fix null reference in OrderService"
git commit -m "Update README with installation guide"
git commit -m "Remove deprecated API endpoints"
git commit -m "Refactor validation logic"

# ❌ 悪い例
git commit -m "ユーザー認証機能を追加"           # 日本語
git commit -m "Added user authentication"         # 過去形
git commit -m "This commit adds user auth..."     # 50文字超過の可能性
git commit -m "Add feature\n\nDetails here"       # 改行あり
```

**動詞の例**:
- Add, Create, Implement（追加）
- Fix, Resolve, Correct（修正）
- Update, Modify, Change（更新）
- Remove, Delete, Drop（削除）
- Refactor, Extract, Reorganize（リファクタ）
- Rename, Move（名前変更・移動）
- Improve, Optimize, Enhance（改善）

### 3. ブランチ命名

ユーザーからブランチ名を指定された場合はそれに従う。

指定がない場合は、以下を参考に命名：

```bash
# 機能開発
feature/user-authentication

# バグ修正
fix/null-reference-error
hotfix/critical-bug

# その他
refactor/extract-service
docs/update-readme
```

### 4. Push

制限なし。そのまま実行してよい。

```bash
git -C /path/to/repo push origin feature/new-feature
```

### 5. Worktree操作

#### 追加（確認不要）

```bash
git -C /path/to/repo worktree add ../new-worktree branch-name
```

#### 削除（確認必須）

削除前に必ずユーザーに確認する。以下をチェック：

1. **未コミットの変更がないか**
2. **削除対象が正しいか**（パスを明示）
3. **関連ブランチの状態**

```
⚠️ Worktree削除の確認

削除対象: /path/to/worktree
関連ブランチ: feature/xxx

リスク:
- [未コミットの変更がある場合] 未保存の変更が失われます
- [その他気づいたリスク]

削除を実行してよいですか？
```

### 6. 危険操作（条件付き許可）

以下のコマンドは**ユーザーの明示的な指示があれば実行可能**。明示指示なしで使用するとhookがブロックする。

| コマンド | カテゴリ | リスク | 許可される指示の例 |
|----------|---------|--------|-------------------|
| `git reset --hard` | 履歴破壊 | コミット済み変更を破棄 | 「reset --hardして」「強制リセットして」「ハードリセットして」 |
| `git push --force` / `git push -f` | 上流履歴破壊 | リモート履歴を上書き | 「force pushして」「強制プッシュして」「--forceでpushして」 |
| `git restore <path>` | **未コミット変更消失** | 他エージェントの変更を含めて復元不能で消失 | 「restoreして」「特定ファイルを戻して」 |
| `git checkout -- <path>` | **未コミット変更消失** | `git restore` と同等 | 「checkoutで戻して」「HEADに戻して」 |
| `git clean -fd` | 未追跡ファイル削除 | Untrackedファイルの強制削除 | 「clean -fdで掃除して」「未追跡を削除して」 |

**2026-04-20 追加**: `restore` / `checkout --` / `clean -fd` は `proposals/2026-04-20-git-restore-deny-list.md` で deny-list 化。Ubie n8n ハーネス実践記（`tickets/accepted/2026-04-20-ubie-n8n-harness-engineering.md`）の「`git restore` で他エージェントの未コミット変更 5 ファイル消失」事故を契機に、マルチエージェント並行実行環境での安全網として追加した。

#### 特に未コミット変更消失のリスク

`reset --hard` は reflog で回復余地があるが、**`git restore` / `git checkout -- <file>` は未コミット変更の純粋消失**で reflog でも復元できない。Agent Teams / サブエージェント並行実行 / worktree 並行運用での事故リスクが高い。

#### 暗黙的な使用は禁止

```bash
# ❌ 禁止：ユーザーが「元に戻して」と言った場合
git reset --hard HEAD~1  # 勝手に使わない
git restore <file>       # 勝手に使わない（未コミット変更消失）
git checkout -- <file>   # 勝手に使わない（未コミット変更消失）

# ✅ 代わりに安全な方法を提案
git revert HEAD          # コミット済み変更の「取り消しコミット」を作成
git stash push -- <file> # 特定ファイルを一時退避（後で pop 可能）
git stash                # 一時退避（全変更）

# ❌ 禁止：ユーザーが「pushして」と言った場合
git push --force origin main  # 勝手に--forceを付けない

# ✅ 通常のpushを試み、失敗したら報告
git push origin main     # まず通常push
# 失敗した場合 → ユーザーに状況を報告し、対処法を提案
```

#### 実行前の確認

明示的な指示があった場合でも、実行前に以下を確認・報告：

```
⚠️ 危険操作の確認

実行コマンド: git reset --hard HEAD~1
影響: 直近1コミットの変更が完全に失われます

リスク:
- 未プッシュのコミットは復元困難
- ローカルの変更もすべて破棄されます

実行してよいですか？
```

### 7. ClickOnce発行後のバージョン同期

ClickOnce発行によりmainのcsproj/vbprojでバージョンが進んだ場合、以下のフローで同期：

```
1. ユーザーから発行完了報告を受ける
2. mainのバージョン変更をコミット・push
3. main → developへマージ（逆伝播）
4. （必要に応じて）develop → 他ブランチへ取り込み
```

**競合解決**: csprojのバージョン行が競合した場合、**mainの値を優先**。

---

## 実行例

### 基本的なコミットフロー

```bash
# 1. 状態確認
git -C /path/to/repo status

# 2. ステージング
git -C /path/to/repo add .

# 3. コミット（英語、50文字以内、動詞始まり）
git -C /path/to/repo commit -m "Add order validation logic"

# 4. プッシュ
git -C /path/to/repo push origin feature/order-validation
```

### ブランチ作成とチェックアウト

```bash
# 新しいブランチを作成してチェックアウト
git -C /path/to/repo checkout -b feature/new-feature

# 既存ブランチへ切り替え
git -C /path/to/repo checkout main
```

### マージ

```bash
# mainにマージ
git -C /path/to/repo checkout main
git -C /path/to/repo merge feature/completed-feature
```

### ClickOnce発行後の同期

```bash
# 1. mainでバージョン変更をコミット
git -C /path/to/repo checkout main
git -C /path/to/repo add .
git -C /path/to/repo commit -m "Bump version after ClickOnce publish"
git -C /path/to/repo push origin main

# 2. developへ逆伝播
git -C /path/to/repo checkout develop
git -C /path/to/repo merge main
git -C /path/to/repo push origin develop

# 3. 必要に応じて他ブランチへ取り込み
git -C /path/to/repo checkout feature/xxx
git -C /path/to/repo merge develop
git -C /path/to/repo push origin feature/xxx
```

---

## チェックリスト

コミット前の確認：

- [ ] `-C <path>` オプションを使用しているか
- [ ] コミットメッセージは英語か
- [ ] コミットメッセージは50文字以内か
- [ ] コミットメッセージは改行を含まないか
- [ ] コミットメッセージは動詞で始まっているか

Worktree削除前の確認：

- [ ] 未コミットの変更がないか確認したか
- [ ] ユーザーに確認を求めたか
- [ ] リスクがあれば確認メッセージに含めたか

危険操作の確認：

- [ ] ユーザーの明示的な指示があるか
- [ ] 暗黙的に使用しようとしていないか
- [ ] 実行前にリスクを説明したか
- [ ] ユーザーの最終確認を得たか

ClickOnce発行後の同期：

- [ ] mainのバージョン変更をコミットしたか
- [ ] main → developへマージしたか
- [ ] 必要に応じて他ブランチへ取り込んだか
