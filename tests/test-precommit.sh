#!/usr/bin/env bash
# Test: pre-commit.sh.template
set -u
HOOK="$(cd "$(dirname "$0")/.." && pwd)/templates/pre-commit.sh.template"
fail=0
tmp="$(mktemp -d)"
(
  cd "$tmp" || exit 1
  git init -q
  git config user.email t@example.com
  git config user.name test

  # 1) secret を含む staged file → exit 1
  echo 'aws = "AKIAIOSFODNN7EXAMPLE"' > leak.txt
  git add leak.txt
  bash "$HOOK" >/dev/null 2>&1
  [ $? -eq 1 ] && echo "PASS: secret blocked (exit 1)" || { echo "FAIL: secret not blocked"; exit 1; }

  # 2) clean file → exit 0
  git rm -q --cached leak.txt; rm -f leak.txt
  echo 'hello world' > ok.txt
  git add ok.txt
  bash "$HOOK" >/dev/null 2>&1
  [ $? -eq 0 ] && echo "PASS: clean passes (exit 0)" || { echo "FAIL: clean blocked"; exit 1; }

  # 3) staged blob に secret、working tree は clean に上書き → それでも exit 1
  #    (git add secret → working tree clean → commit のすり抜けを防ぐ。Codex Finding 1)
  echo 'key = "AKIAIOSFODNN7EXAMPLE"' > sneaky.txt
  git add sneaky.txt
  echo 'now clean' > sneaky.txt   # working tree だけ clean に
  bash "$HOOK" >/dev/null 2>&1
  [ $? -eq 1 ] && echo "PASS: staged-blob secret blocked (working tree clean でも検出)" || { echo "FAIL: staged-blob secret leaked"; exit 1; }
) || fail=1
rm -rf "$tmp"
exit $fail
