#!/bin/bash
# inbox-monitor.sh — 纯Shell版全局Inbox扫描器（替代失败的cron agent turn）
set -uo pipefail
LOG_DIR="/home/gang/.openclaw/workspace-lambda/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/inbox-monitor-$(date +%Y%m%d).log"
AGENTS="alpha beta lambda delta epsilon eta gamma iota kappa theta zeta"
HAS_UNREAD=0
REPORT=""
for agent in $AGENTS; do
  WS="/home/gang/.openclaw/workspace-${agent}"
  [ -d "$WS/inbox" ] && "$WS/../workspace-lambda/inbox-updater.sh" "$WS" 2>/dev/null
done
for agent in $AGENTS; do
  INBOX="/home/gang/.openclaw/workspace-${agent}/inbox"
  LAST_READ_FILE="$INBOX/.last-read"
  [ -d "$INBOX" ] || continue
  [ -f "$LAST_READ_FILE" ] || continue
  LAST_READ=$(cat "$LAST_READ_FILE" 2>/dev/null | tr -d '\n')
  [ -z "$LAST_READ" ] && continue
  [ -f "$INBOX/$LAST_READ" ] || continue
  NEW=$(find "$INBOX" -name "msg-*.json" -newer "$INBOX/$LAST_READ" 2>/dev/null | sort)
  if [ -n "$NEW" ]; then
    COUNT=$(echo "$NEW" | wc -l)
    HAS_UNREAD=1
    REPORT+="📬 $agent: $COUNT 条新消息\n"
    echo "$NEW" | head -3 | while read -r f; do
      PRIORITY=$(grep -o '"priority"\s*:\s*"[^"]*"' "$f" 2>/dev/null | head -1 | sed 's/.*"priority"\s*:\s*"//;s/"$//')
      SUBJECT=$(grep -o '"subject"\s*:\s*"[^"]*"' "$f" 2>/dev/null | head -1 | sed 's/.*"subject"\s*:\s*"//;s/"$//')
      [ -n "$PRIORITY" ] && [ -n "$SUBJECT" ] && REPORT+="  [$PRIORITY] $SUBJECT\n"
    done
  fi
done
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
if [ $HAS_UNREAD -eq 1 ]; then
  echo -e "=== 📬 Inbox扫描 [$TIMESTAMP] ===\n$REPORT=== 扫描完成 ==="
  echo -e "[$TIMESTAMP] UNREAD found:\n$REPORT" >> "$LOG_FILE"
else
  echo "[$TIMESTAMP] All clear ✅" >> "$LOG_FILE"
fi
