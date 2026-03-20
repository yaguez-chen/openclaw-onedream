#!/bin/bash
# check-inbox.sh — 检查inbox中的未读消息
# 用法: bash check-inbox.sh {Agent名} [--unread] [--all] [--mark-read]
# 示例: bash check-inbox.sh theta --unread

AGENT="${1:?必须指定Agent名}"
FLAG="${2:---unread}"

# Agent的inbox路径（阿尔法和其他Agent发给你的消息在你的workspace inbox）
MY_INBOX="/home/gang/.openclaw/workspace-${AGENT}/inbox"

LAST_READ_FILE="${MY_INBOX}/.last-read"

if [ ! -d "$MY_INBOX" ]; then
  echo "❌ inbox目录不存在: ${MY_INBOX}"
  exit 1
fi

# 获取上次读取的位置
if [ -f "$LAST_READ_FILE" ]; then
  LAST_READ=$(cat "$LAST_READ_FILE")
else
  LAST_READ=""
fi

# 列出所有json消息文件（排除.文件和ack文件）
FILES=$(ls -1t "$MY_INBOX"/msg-*.json 2>/dev/null)
if [ -z "$FILES" ]; then
  echo "📭 ${AGENT}的inbox为空，没有消息"
  exit 0
fi

case "$FLAG" in
  --unread)
    if [ -z "$LAST_READ" ]; then
      echo "📬 ${AGENT}的inbox — 全部 ${MY_INBOX} 中的消息（首次检查）:"
      echo "---"
      for f in $FILES; do
        echo "📄 $(basename $f)"
        # 显示关键字段
        cat "$f" | python3 -c "
import sys, json
try:
  d = json.load(sys.stdin)
  print(f'   来自: {d.get(\"from\", \"未知\")}')
  print(f'   时间: {d.get(\"timestamp\", \"未知\")}')
  print(f'   优先级: {d.get(\"priority\", \"normal\")}')
  print(f'   标题: {d.get(\"subject\", \"无标题\")}')
  print(f'   ack: {d.get(\"ack_required\", False)}')
  print(f'   内容: {d.get(\"body\", \"\")[:100]}')
  if d.get('type') == 'ack':
    print(f'   ⚡ 这是ack确认，ref={d.get(\"ref_id\", \"未知\")}')
except:
  print('   ⚠️  文件格式错误')
" 2>/dev/null
        echo
      done
    else
      # 只显示LAST_READ之后的文件
      NEW_FILES=$(ls -1t "$MY_INBOX"/msg-*.json 2>/dev/null | while read f; do
        bn=$(basename "$f")
        if [[ "$bn" > "$LAST_READ" ]]; then
          echo "$f"
        fi
      done)

      if [ -z "$NEW_FILES" ]; then
        echo "📭 ${AGENT}的inbox — 没有新消息（上次读到: ${LAST_READ}）"
        exit 0
      fi

      COUNT=$(echo "$NEW_FILES" | wc -l)
      echo "📬 ${AGENT}的inbox — ${COUNT}条新消息（上次: ${LAST_READ}）:"
      echo "---"
      for f in $NEW_FILES; do
        echo "📄 $(basename $f)"
        cat "$f" | python3 -c "
import sys, json
try:
  d = json.load(sys.stdin)
  print(f'   来自: {d.get(\"from\", \"未知\")}')
  print(f'   时间: {d.get(\"timestamp\", \"未知\")}')
  print(f'   优先级: {d.get(\"priority\", \"normal\")}')
  print(f'   标题: {d.get(\"subject\", \"无标题\")}')
  print(f'   ack: {d.get(\"ack_required\", False)}')
  print(f'   内容: {d.get(\"body\", \"\")[:100]}')
  if d.get('type') == 'ack':
    print(f'   ⚡ 这是ack确认，ref={d.get(\"ref_id\", \"未知\")}')
except:
  print('   ⚠️  文件格式错误')
" 2>/dev/null
        echo
      done

      # 显示最新文件名，方便标记已读
      NEWEST=$(echo "$NEW_FILES" | head -1)
      echo "---"
      echo "💡 处理完后执行: echo \"$(basename $NEWEST)\" > ${LAST_READ_FILE}"
    fi
    ;;

  --all)
    echo "📬 ${AGENT}的inbox — 全部消息:"
    echo "---"
    for f in $FILES; do
      echo "📄 $(basename $f)"
    done
    echo "共 $(echo "$FILES" | wc -l) 条消息"
    ;;

  --mark-read)
    # 标记所有为已读
    NEWEST=$(ls -1t "$MY_INBOX"/msg-*.json 2>/dev/null | head -1)
    if [ -n "$NEWEST" ]; then
      echo "$(basename "$NEWEST")" > "$LAST_READ_FILE"
      echo "✅ 已标记已读: $(basename "$NEWEST")"
    else
      echo "📭 没有消息可标记"
    fi
    ;;

  *)
    echo "用法: bash check-inbox.sh {Agent名} [--unread|--all|--mark-read]"
    exit 1
    ;;
esac
