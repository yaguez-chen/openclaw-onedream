#!/bin/bash
# mail_read.sh — 读邮件（协议层原子能力）
# 用法: bash mail_read.sh {inbox路径} --unread|--all|--mark-read

INBOX="${1:?必须指定inbox路径}"
MODE="${2:---unread}"

# 读取 .last-read
LAST_READ_FILE="${INBOX}/.last-read"
LAST_READ=""
[ -f "$LAST_READ_FILE" ] && LAST_READ=$(cat "$LAST_READ_FILE")

case "$MODE" in
  --unread)
    count=0
    for f in $(ls "$INBOX"/msg-*.json 2>/dev/null | sort); do
      fname=$(basename "$f")
      if [ -z "$LAST_READ" ] || [[ "$fname" > "$LAST_READ" ]]; then
        echo "📨 $fname"
        python3 -c "
import json,sys
d=json.load(open('$f'))
print(f\"  From: {d.get('from','?')} | {d.get('subject','?')} | {d.get('priority','normal')}\")
print(f\"  {d.get('body','')[:100]}\")
print()
" 2>/dev/null
        count=$((count+1))
      fi
    done
    [ "$count" -eq 0 ] && echo "📭 没有未读消息"
    ;;
  --all)
    for f in $(ls "$INBOX"/msg-*.json 2>/dev/null | sort); do
      fname=$(basename "$f")
      read_mark=""
      [ -n "$LAST_READ" ] && [[ "$fname" <= "$LAST_READ" ]] && read_mark=" ✅"
      echo "📨 ${fname}${read_mark}"
      python3 -c "
import json,sys
d=json.load(open('$f'))
print(f\"  From: {d.get('from','?')} | {d.get('subject','?')} | {d.get('priority','normal')}\")
print(f\"  {d.get('body','')[:100]}\")
print()
" 2>/dev/null
    done
    ;;
  --mark-read)
    newest=$(ls "$INBOX"/msg-*.json 2>/dev/null | sort | tail -1 | xargs basename 2>/dev/null)
    if [ -n "$newest" ]; then
      echo "$newest" > "$LAST_READ_FILE"
      echo "✅ 已标记读到: $newest"
    else
      echo "📭 inbox为空"
    fi
    ;;
  *)
    echo "用法: mail_read.sh {inbox} --unread|--all|--mark-read"
    exit 1
    ;;
esac
