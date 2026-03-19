#!/bin/bash
# ack-processor.sh — 处理 ack-*.json，更新追踪日志
set -uo pipefail

WORKSPACE="$(cd "$(dirname "$0")" && pwd)"
INBOX="${WORKSPACE}/inbox"
OUTBOX="${WORKSPACE}/outbox"
SENT_LOG="${OUTBOX}/sent-log.jsonl"
mkdir -p "$OUTBOX"

COUNT=0
shopt -s nullglob
for ACK_FILE in "${INBOX}"/ack-*.json; do
  [ -f "$ACK_FILE" ] || continue
  REF_ID=$(grep -o '"ref_id"[[:space:]]*:[[:space:]]*"[^"]*"' "$ACK_FILE" | grep -o '"[^"]*"$' | tr -d '"')
  STATUS=$(grep -o '"status"[[:space:]]*:[[:space:]]*"[^"]*"' "$ACK_FILE" | grep -o '"[^"]*"$' | tr -d '"')
  READ_AT=$(grep -o '"read_at"[[:space:]]*:[[:space:]]*"[^"]*"' "$ACK_FILE" | grep -o '"[^"]*"$' | tr -d '"')
  FROM=$(grep -o '"from"[[:space:]]*:[[:space:]]*"[^"]*"' "$ACK_FILE" | grep -o '"[^"]*"$' | tr -d '"')

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
  COUNT=$((COUNT + 1))
done

echo "📊 处理完成: ${COUNT} 条 ack"
