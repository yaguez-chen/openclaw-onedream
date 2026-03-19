#!/bin/bash
# ack-processor.sh — 处理 ack-*.json，更新追踪日志
set -euo pipefail

INBOX="/home/gang/.openclaw/workspace-$(whoami)/inbox"
OUTBOX="/home/gang/.openclaw/workspace-$(whoami)/outbox"
SENT_LOG="${OUTBOX}/sent-log.jsonl"
mkdir -p "$OUTBOX"

COUNT=0
for ACK_FILE in "${INBOX}"/ack-*.json 2>/dev/null; do
  [ -f "$ACK_FILE" ] || continue
  REF_ID=$(grep -o '"ref_id":"[^"]*"' "$ACK_FILE" | cut -d'"' -f4)
  STATUS=$(grep -o '"status":"[^"]*"' "$ACK_FILE" | cut -d'"' -f4)
  READ_AT=$(grep -o '"read_at":"[^"]*"' "$ACK_FILE" | cut -d'"' -f4)
  FROM=$(grep -o '"from":"[^"]*"' "$ACK_FILE" | cut -d'"' -f4)

  echo "✅ ${REF_ID} ← ${FROM} (${STATUS})"

  # 更新 sent-log
  if [ -f "$SENT_LOG" ] && grep -q "$REF_ID" "$SENT_LOG" 2>/dev/null; then
    OLD=$(grep "$REF_ID" "$SENT_LOG")
    NEW=$(echo "$OLD" | sed "s/\"acked_at\":null/\"acked_at\":\"${READ_AT}\"/" | sed "s/\"status\":\"pending\"/\"status\":\"${STATUS}\"/")
    sed -i "s|${OLD}|${NEW}|" "$SENT_LOG"
  fi

  # 归档
  mkdir -p "${INBOX}/archive"
  mv "$ACK_FILE" "${INBOX}/archive/"
  ((COUNT++))
done

echo "📊 处理完成: ${COUNT} 条 ack"
