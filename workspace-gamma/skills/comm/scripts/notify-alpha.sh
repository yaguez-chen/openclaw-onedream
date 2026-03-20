#!/bin/bash
# notify-alpha.sh — 📧+💬 通知阿尔法
# 用法: bash notify-alpha.sh {来源} {标题} {内容} [优先级]
# 示例: bash notify-alpha.sh gamma "任务完成" "技能已部署完毕" normal
# 流程: 写入阿尔法inbox(📧) → sessions_send通知阿尔法(💬)

FROM="${1:?必须指定来源}"
SUBJECT="${2:?必须指定标题}"
BODY="${3:?必须指定内容}"
PRIORITY="${4:-normal}"

INBOX="/home/gang/.openclaw/workspace/inbox"

# 📧 写入阿尔法inbox
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
bash "${SCRIPT_DIR}/mail_write.sh" "$INBOX" "$FROM" "alpha" "$SUBJECT" "$BODY" "$PRIORITY"

# 💬 sessions_send通知阿尔法
sessions_send(label: "alpha", message: "[📨 ${FROM}] ${SUBJECT}")

echo "✅ 📧+💬 已通知阿尔法"
