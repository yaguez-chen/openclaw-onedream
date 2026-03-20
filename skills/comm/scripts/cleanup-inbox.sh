#!/bin/bash
# cleanup-inbox.sh — 自动清理过期邮件文件
# 用法: bash cleanup-inbox.sh {Agent名}
# 示例: bash cleanup-inbox.sh gamma

AGENT="${1:?必须指定Agent名}"
MY_INBOX="/home/gang/.openclaw/workspace-${AGENT}/inbox"
OUTBOX="/home/gang/.openclaw/workspace-${AGENT}/outbox"

MSG_DAYS=7    # 消息保留天数
ACK_DAYS=3    # ack保留天数
LOG_DAYS=7    # 发送日志保留天数

deleted=0

if [ ! -d "$MY_INBOX" ]; then
  echo "❌ inbox不存在: ${MY_INBOX}"
  exit 1
fi

echo "🧹 清理 ${AGENT} 的inbox..."

# 清理过期消息（msg-*.json，超过7天）
for f in "$MY_INBOX"/msg-*.json; do
  [ -f "$f" ] || continue
  if [ $(find "$f" -mtime +${MSG_DAYS} 2>/dev/null | wc -l) -gt 0 ]; then
    rm -f "$f"
    deleted=$((deleted + 1))
  fi
done

# 清理过期ack（ack-*.json，超过3天）
for f in "$MY_INBOX"/ack-*.json; do
  [ -f "$f" ] || continue
  if [ $(find "$f" -mtime +${ACK_DAYS} 2>/dev/null | wc -l) -gt 0 ]; then
    rm -f "$f"
    deleted=$((deleted + 1))
  fi
done

# 清理outbox发送日志（超过7天的记录）
SENT_LOG="$OUTBOX/sent-log.jsonl"
if [ -f "$SENT_LOG" ]; then
  cutoff=$(date -d "-${LOG_DAYS} days" +%Y-%m-%d 2>/dev/null || date -v-${LOG_DAYS}d +%Y-%m-%d 2>/dev/null)
  if [ -n "$cutoff" ]; then
    total=$(wc -l < "$SENT_LOG")
    python3 -c "
import json, sys
cutoff = '$cutoff'
kept = []
for line in sys.stdin:
    line = line.strip()
    if not line: continue
    try:
        d = json.loads(line)
        sent_at = d.get('sent_at','')[:10]
        if sent_at >= cutoff:
            kept.append(line)
    except:
        kept.append(line)
for l in kept:
    print(l)
" < "$SENT_LOG" > "${SENT_LOG}.tmp" 2>/dev/null && mv "${SENT_LOG}.tmp" "$SENT_LOG"
    kept=$(wc -l < "$SENT_LOG")
    trimmed=$((total - kept))
    if [ "$trimmed" -gt 0 ]; then
      echo "📋 outbox日志清理: ${trimmed}条过期记录"
    fi
  fi
fi

echo "✅ 清理完成，删除 ${deleted} 个过期文件"
