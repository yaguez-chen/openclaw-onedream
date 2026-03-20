#!/bin/bash
# mail_read.sh — 邮件原子操作：读取inbox
# 用法: bash mail_read.sh {inbox路径} [--unread] [--all] [--mark-read]
INBOX="${1:?必须指定inbox路径}"
FLAG="${2:---unread}"
LAST_READ_FILE="${INBOX}/.last-read"

if [ ! -d "$INBOX" ]; then
  echo "❌ inbox不存在: ${INBOX}" >&2
  exit 1
fi

if [ -f "$LAST_READ_FILE" ]; then
  LAST_READ=$(cat "$LAST_READ_FILE")
else
  LAST_READ=""
fi

FILES=$(ls -1t "$INBOX"/msg-*.json 2>/dev/null)
if [ -z "$FILES" ]; then
  echo "📭 空"
  exit 0
fi

case "$FLAG" in
  --unread)
    if [ -z "$LAST_READ" ]; then
      echo "$FILES"
    else
      NEW_FILES=$(for f in $FILES; do
        bn=$(basename "$f")
        [[ "$bn" > "$LAST_READ" ]] && echo "$f"
      done)
      if [ -z "$NEW_FILES" ]; then
        echo "📭 无新消息"
        exit 0
      fi
      echo "$NEW_FILES"
    fi
    ;;
  --all)
    echo "$FILES"
    ;;
  --mark-read)
    NEWEST=$(echo "$FILES" | head -1)
    echo "$(basename "$NEWEST")" > "$LAST_READ_FILE"
    echo "✅ $(basename "$NEWEST")"
    ;;
  *)
    echo "用法: bash mail_read.sh {inbox路径} [--unread|--all|--mark-read]" >&2
    exit 1
    ;;
esac
