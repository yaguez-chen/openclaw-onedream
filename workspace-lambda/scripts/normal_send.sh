#!/bin/bash
# normal_send.sh — 📧+💬 通知不等回复
# 用法: bash normal_send.sh {来源} {目标} {标题} {内容} [优先级]
# 示例: bash normal_send.sh gamma lambda "测试请求" "请验证通讯脚本"
# 示例: bash normal_send.sh gamma alpha "任务完成" "技能已部署" normal
# 流程: 写入inbox(📧) → openclaw agent通知(💬)

FROM="${1:?必须指定来源}"
TO="${2:?必须指定目标}"
SUBJECT="${3:?必须指定标题}"
BODY="${4:?必须指定内容}"
PRIORITY="${5:-normal}"

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
bash "${SCRIPT_DIR}/mail_write.sh" "$INBOX" "$FROM" "$TO" "$SUBJECT" "$BODY" "$PRIORITY"

# 💬 叫醒对方，不等回复（后台执行不阻塞）
MSG="📨 [${FROM}] ${SUBJECT}"
openclaw agent --agent "$TO" --message "$MSG" --json --timeout 30 2>/dev/null &

echo "✅ 📧+💬 已发送给 ${TO}（通知后台执行中）"
