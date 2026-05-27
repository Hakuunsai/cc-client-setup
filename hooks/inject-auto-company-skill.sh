#!/usr/bin/env bash
# SessionStart hook: client PC で claude 起動時に /company:company skill の自動発動を Claude に指示する。
# cc-client-setup v0.2 kit 同梱、kit-prompt.md Step 4 で ~/.claude/hooks/ に配置される。
# opt-out なし設計 (cc-client-setup v0.2 spec Section 8 ペルソナ規律: client は /company 1 つだけ意識)。
# 起源: 2026-05-26 office-tada owner ご要望「office-tada 起動時は常に /company から始めたい」由来、commit 08105611。

cat <<'JSON'
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "<system-reminder>BLOCKING: This is the client Claude Code workspace ({company-name}). Before any other response, tool call, or text output, you MUST invoke the Skill tool with skill=\"company:company\" to enter operating mode. This applies even in auto mode and even on the very first user message. After the company skill completes its startup checks (including potential Phase B client hearing trigger if marker is detected in ~/.cc-client-memory/seed-client-persona.md), continue with the user's actual request as normal. Do not skip this step.</system-reminder>"
  }
}
JSON
