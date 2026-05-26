# 復旧 (リカバリ) 手順

Claude Code が「おかしな修正」をした時に、前の状態に戻す方法。

## レベル 1: 直近の変更を取り消す (一番簡単)

Claude が直前に Edit/Write した直後なら、auto-checkpoint stash が取れているはず。

```powershell
git stash list
# stash@{0}: On main: [claude-auto-checkpoint] 2026-05-26T17:00:00
# stash@{1}: On main: [claude-auto-checkpoint] 2026-05-26T16:55:00
# ...
```

このうち戻したい時点の stash を apply:

```powershell
# 現在の作業を退避してから (重要)
git stash push -m "before-recovery"
# 戻したい checkpoint を apply
git stash apply stash@{1}
```

apply で問題なければ `git stash drop stash@{1}` で削除可。

## レベル 2: もっと前の commit に戻す

```powershell
git log --oneline -20
# abc1234 (HEAD -> main) commit message
# def5678 ...
```

戻したい commit hash を `git reset --hard <hash>` (Claude に頼んで OK、ask 経由で都度確認される):

```powershell
git reset --hard def5678
```

## レベル 3: 全ての git 操作履歴から救う

`git reflog` は **すべての HEAD の動きの履歴**。誤った reset や rebase もここから救える:

```powershell
git reflog -20
# HEAD@{0}: reset: moving to def5678
# HEAD@{1}: commit: 失敗した自動 commit
# HEAD@{2}: commit: 直前の良い state
```

`HEAD@{2}` の hash で `git reset --hard HEAD@{2}` で復旧。

## レベル 4: file 単位で戻す

特定 file だけ前の状態に戻したい場合:

```powershell
# 直前 commit の file 状態に戻す
git checkout HEAD -- path/to/file.cs
# 5 commit 前の file 状態に戻す
git checkout HEAD~5 -- path/to/file.cs
```

## トラブル

- stash apply で conflict → `git stash drop` してから別 stash を試す
- reflog にも履歴が無い → backup file (`*.bak.YYYYMMDDTHHmmss`) を探す
- どうにもならない → owner に連絡 (cc-client-setup repo の clone を保持していれば再 bootstrap 可)

## 予防

- 大事な変更前は手動で `git commit` (Claude に頼んでも OK)
- 1 日の終わりに `git push` (`ask` permission で都度確認される)
- 「やっていいか聞いて」と明示すれば Claude は実装前に確認する
