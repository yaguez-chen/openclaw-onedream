#!/bin/bash
# inbox-updater.sh — 强制更新 .last-read（不依赖 LLM）
# 用法: ./inbox-updater.sh <agent_dir>
set -uo pipefail

AGENT_DIR="${1:-/home/gang/.openclaw/workspace-lambda}"
INBOX="${AGENT_DIR}/inbox"
LAST_READ_FILE="${INBOX}/.last-read"

[ -d "$INBOX" ] || { echo "Error: inbox not found: $INBOX"; exit 1; }

# 获取最新的 msg 文件（排除 recovery 文件）
LATEST=$(ls -1 "$INBOX"/msg-202*.json 2>/dev/null | sort | tail -1 | xargs basename 2>/dev/null)

if [ -n "$LATEST" ]; then
  OLD=$(cat "$LAST_READ_FILE" 2>/dev/null | tr -d '\n')
  if [ "$LATEST" != "$OLD" ]; then
    echo "$LATEST" > "$LAST_READ_FILE"
    echo "✅ Updated: $OLD → $LATEST"
  else
    echo "✅ Already up to date: $LATEST"
  fi
else
  echo "⚠️ No msg files found in $INBOX"
fi
