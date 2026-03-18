#!/bin/bash
# adaptive-trigger.sh — Agent 自适应触发器管理
# 用法：./adaptive-trigger.sh <任务描述> <优先级> [依赖ID] [协作方]
#
# 作者：伽马 🔧 | 日期：2026-03-18 | 修复：none 判断 bug

TASK_DESC=$1
PRIORITY=${2:-normal}
DEPENDENCY=$3
COLLABORATOR=$4

[ -z "$TASK_DESC" ] && { echo "用法: $0 \"任务描述\" [优先级] [依赖ID] [协作方]"; exit 1; }

FOCUS_CLI="/home/gang/.openclaw/workspace-gamma/scripts/focus-cli.sh"

# 决策引擎：根据任务特征选择触发器
if [ "$PRIORITY" = "urgent" ] || [ "$PRIORITY" = "high" ]; then
  TRIGGER="heartbeat"
  NOTE="紧急任务，每次心跳检查"
elif [ -n "$DEPENDENCY" ] && [ "$DEPENDENCY" != "none" ]; then
  TRIGGER="dep:$DEPENDENCY"
  NOTE="等待依赖 $DEPENDENCY 完成"
elif [ -n "$COLLABORATOR" ] && [ "$COLLABORATOR" != "none" ]; then
  TRIGGER="event:${COLLABORATOR}_done"
  NOTE="等待 $COLLABORATOR 完成"
else
  TRIGGER="heartbeat"
  NOTE="默认心跳触发"
fi

# 添加到 focus items
bash "$FOCUS_CLI" add "$TASK_DESC" "$TRIGGER" "${DEPENDENCY:-none}" "adaptive"

echo "🤖 自适应触发器已创建："
echo "  任务: $TASK_DESC"
echo "  触发器: $TRIGGER"
echo "  原因: $NOTE"
