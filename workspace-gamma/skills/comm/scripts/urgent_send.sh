#!/bin/bash
# urgent_send.sh — 📧+📞 紧急等回复
# 用法: bash urgent_send.sh {来源} {目标} {标题} {内容}
# 示例: bash urgent_send.sh gamma alpha "紧急故障" "XX系统异常"
# 流程: 写入inbox(📧) → openclaw agent强制叫醒(📞)

FROM="${1:?必须指定来源}"
TO="${2:?必须指定目标}"
SUBJECT="${3:?必须指定标题}"
BODY="${4:?必须指定内容}"

# 自动解析inbox路径
case "$TO" in
  alpha)
    INBOX="/home/gang/.openclaw/workspace/inbox"
    ;;
  *)
    INBOX="/home/gang/.openclaw/workspace-${TO}/inbox"
    ;;
esac

# 📧 写入inbox
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
bash "${SCRIPT_DIR}/mail_write.sh" "$INBOX" "$FROM" "$TO" "$SUBJECT" "$BODY" high

# 📞 openclaw agent 强制叫醒
openclaw agent --agent "$TO" --message "[🚨urgent from ${FROM}] ${SUBJECT}: ${BODY}" --json 2>/dev/null

echo "✅ 📧+📞 紧急消息已发送给 ${TO}"
