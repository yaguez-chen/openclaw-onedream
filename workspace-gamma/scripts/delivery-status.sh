#!/bin/bash
# delivery-status.sh — 查看发送消息的投递状态
# 用法：./delivery-status.sh [agent-name]

AGENT=${1:-$(whoami)}
OUTBOX="/home/gang/.openclaw/workspace-${AGENT}/outbox"
SENT_LOG="$OUTBOX/sent-log.jsonl"

if [ ! -f "$SENT_LOG" ]; then
  echo "📭 暂无发送记录"
  exit 0
fi

echo "📬 投递状态报告 — ${AGENT}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

total=0
pending=0
acked=0
timeout=0

while IFS= read -r line; do
  total=$((total + 1))
  id=$(echo "$line" | grep -o '"id":"[^"]*"' | cut -d'"' -f4)
  to=$(echo "$line" | grep -o '"to":"[^"]*"' | cut -d'"' -f4)
  subject=$(echo "$line" | grep -o '"subject":"[^"]*"' | cut -d'"' -f4)
  sent_at=$(echo "$line" | grep -o '"sent_at":"[^"]*"' | cut -d'"' -f4)
  
  # 检查是否有对应的 ack
  ack_found=false
  for ack_file in "/home/gang/.openclaw/workspace-${AGENT}/inbox"/ack-*.json; do
    [ -f "$ack_file" ] || continue
    ref=$(grep -o '"ref_id": "[^"]*"' "$ack_file" 2>/dev/null | cut -d'"' -f4)
    if [ "$ref" = "$id" ]; then
      ack_found=true
      read_at=$(grep -o '"read_at": "[^"]*"' "$ack_file" | cut -d'"' -f4)
      echo "  ✅ [$id] → $to | $subject | 已读于 $read_at"
      acked=$((acked + 1))
      break
    fi
  done
  
  if [ "$ack_found" = "false" ]; then
    # 检查是否超时（>30分钟）
    if command -v date >/dev/null 2>&1; then
      sent_epoch=$(date -d "$sent_at" +%s 2>/dev/null || echo 0)
      now_epoch=$(date +%s)
      age=$(( (now_epoch - sent_epoch) / 60 ))
      if [ $age -gt 30 ]; then
        echo "  ⚠️ [$id] → $to | $subject | 超时(${age}分钟)"
        timeout=$((timeout + 1))
      else
        echo "  ⏳ [$id] → $to | $subject | 等待中(${age}分钟)"
        pending=$((pending + 1))
      fi
    else
      echo "  ⏳ [$id] → $to | $subject | 状态未知"
      pending=$((pending + 1))
    fi
  fi
done < "$SENT_LOG"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 统计：总计 $total | ✅已读 $acked | ⏳等待中 $pending | ⚠️超时 $timeout"
