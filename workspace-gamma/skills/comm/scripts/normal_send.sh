#!/bin/bash
# normal_send.sh — 📧+💬 通知不等回复
# 用法: bash normal_send.sh {来源} {目标} {标题} {内容}
# 示例: bash normal_send.sh gamma lambda "测试请求" "请验证通讯脚本"
# 流程: 写入inbox(📧) → sessions_send通知(💬)

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
bash "${SCRIPT_DIR}/mail_write.sh" "$INBOX" "$FROM" "$TO" "$SUBJECT" "$BODY" normal

# 💬 sessions_send通知
sessions_send(label: "$TO", message: "[📨 ${FROM}] ${SUBJECT}")

echo "✅ 📧+💬 已发送给 ${TO}"
