#!/usr/bin/env bash
# task-overdue-check.sh — 任务超时自动检查
# 由 cron 每15分钟运行一次
# 检查 task-tracker.md 中的超时任务，写告警到阿尔法 inbox

set -uo pipefail

TRACKER="/home/gang/.openclaw/shared-knowledge/task-tracker.md"
ALPHA_INBOX="/home/gang/.openclaw/workspace/inbox"
NOW=$(date '+%Y-%m-%d %H:%M')
NOW_EPOCH=$(date +%s)

# 解析任务跟踪板，检查超时
ALERTS=""
OVERDUE_COUNT=0

while IFS='|' read -r _ id task owner created deadline status deliverable note; do
  # 跳过表头和空行
  [[ "$id" =~ ^[[:space:]]*$ ]] && continue
  [[ "$id" =~ ID ]] && continue
  [[ "$deadline" =~ "已完成" ]] && continue
  [[ "$deadline" =~ "已取消" ]] && continue
  [[ "$deadline" =~ "已过期" ]] && continue
  
  # 解析截止时间（格式：HH:MM 或 已过期）
  deadline=$(echo "$deadline" | xargs)
  id=$(echo "$id" | xargs)
  task=$(echo "$task" | xargs)
  owner=$(echo "$owner" | xargs)
  status=$(echo "$status" | xargs)
  
  # 跳过已完成的
  echo "$status" | grep -q "已完成" && continue
  echo "$status" | grep -q "已取消" && continue
  
  # 检查是否超时
  if [[ "$deadline" =~ ^[0-9]{2}:[0-9]{2}$ ]]; then
    # 今天的 deadline
    deadline_epoch=$(date -d "today $deadline" +%s 2>/dev/null || echo 0)
    if (( NOW_EPOCH > deadline_epoch )); then
      overdue_min=$(( (NOW_EPOCH - deadline_epoch) / 60 ))
      if (( overdue_min > 0 )); then
        OVERDUE_COUNT=$((OVERDUE_COUNT + 1))
        ALERTS+="🔴 [$id] $task（负责人：$owner）— 已超时 ${overdue_min} 分钟\n"
      fi
    fi
  fi
done < "$TRACKER"

# 如果有超时任务，写入阿尔法 inbox
if (( OVERDUE_COUNT > 0 )); then
  MSG_ID="msg-$(date +%Y%m%d-%H%M%S)-task-overdue-alert"
  cat > "$ALPHA_INBOX/${MSG_ID}.json" << ALERT
{
  "id": "${MSG_ID}",
  "timestamp": "$(date -Iseconds)",
  "from": "task-tracker-cron",
  "priority": "high",
  "type": "task_overdue_alert",
  "subject": "⏰ 任务超时告警（${OVERDUE_COUNT}项）",
  "body": "任务跟踪板发现超时任务：\n\n$(echo -e "$ALERTS")\n请及时催促相关负责人。\n\n— 任务跟踪系统自动检查（${NOW}）"
}
ALERT
  echo "⏰ 发现 ${OVERDUE_COUNT} 项超时任务，已写入阿尔法 inbox"
else
  echo "✅ 所有任务正常（${NOW}）"
fi
