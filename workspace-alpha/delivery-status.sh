#!/bin/bash
# delivery-status.sh — 查询消息投递状态
# 用法: ./delivery-status.sh [message-id] [--pending] [--all] [--json]
set -euo pipefail

OUTBOX="/home/gang/.openclaw/workspace-$(basename "$(cd "$(dirname "$0")" && pwd)" | sed 's/^workspace-//')/outbox"
SENT_LOG="${OUTBOX}/sent-log.jsonl"

if [ ! -f "$SENT_LOG" ]; then
  echo "📭 没有发送记录"
  exit 0
fi

MODE="all"
TARGET_ID=""
JSON_OUTPUT=false
for arg in "$@"; do
  case "$arg" in
    --pending) MODE="pending" ;;
    --all) MODE="all" ;;
    --json) JSON_OUTPUT=true ;;
    *) TARGET_ID="$arg" ;;
  esac
done

if [ -n "$TARGET_ID" ]; then
  RESULT=$(grep "$TARGET_ID" "$SENT_LOG" 2>/dev/null || echo "")
  if [ -z "$RESULT" ]; then
    echo "❌ 未找到消息: $TARGET_ID"
    exit 1
  fi
  if $JSON_OUTPUT; then
    echo "$RESULT"
  else
    STATUS=$(echo "$RESULT" | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
    TO=$(echo "$RESULT" | grep -o '"to":"[^"]*"' | cut -d'"' -f4)
    SENT=$(echo "$RESULT" | grep -o '"sent_at":"[^"]*"' | cut -d'"' -f4)
    ACKED=$(echo "$RESULT" | grep -o '"acked_at":"[^"]*"' | cut -d'"' -f4)
    SUBJECT=$(echo "$RESULT" | grep -o '"subject":"[^"]*"' | cut -d'"' -f4)
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📨 消息: $TARGET_ID"
    echo "   收件人: $TO"
    echo "   主题: $SUBJECT"
    echo "   发送时间: $SENT"
    case "$STATUS" in
      pending) echo "   状态: ⏳ 待确认" ;;
      read)    echo "   状态: ✅ 已读 ($ACKED)" ;;
      failed)  echo "   状态: ❌ 投递失败" ;;
      *)       echo "   状态: $STATUS" ;;
    esac
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  fi
  exit 0
fi

TOTAL=$(wc -l < "$SENT_LOG")
PENDING=$(grep -c '"status":"pending"' "$SENT_LOG" 2>/dev/null || echo 0)
ACKED=$(grep -c '"status":"read"' "$SENT_LOG" 2>/dev/null || echo 0)
FAILED=$(grep -c '"status":"failed"' "$SENT_LOG" 2>/dev/null || echo 0)

if $JSON_OUTPUT; then
  echo "{\"total\":$TOTAL,\"pending\":$PENDING,\"acked\":$ACKED,\"failed\":$FAILED}"
  exit 0
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 投递状态总览 ($(basename "$(cd "$(dirname "$0")" && pwd)" | sed 's/^workspace-//'))"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "   总发送: $TOTAL"
echo "   ✅ 已确认: $ACKED"
echo "   ⏳ 待确认: $PENDING"
echo "   ❌ 失败: $FAILED"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$MODE" = "pending" ] && [ "$PENDING" -gt 0 ]; then
  echo ""
  echo "⏳ 待确认消息："
  grep '"status":"pending"' "$SENT_LOG" | while read -r line; do
    ID=$(echo "$line" | grep -o '"id":"[^"]*"' | cut -d'"' -f4)
    TO=$(echo "$line" | grep -o '"to":"[^"]*"' | cut -d'"' -f4)
    SENT=$(echo "$line" | grep -o '"sent_at":"[^"]*"' | cut -d'"' -f4)
    echo "   $ID → $TO ($SENT)"
  done
fi
