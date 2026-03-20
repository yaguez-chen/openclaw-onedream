#!/bin/bash
# notify-alpha.sh — 通知阿尔法（协议层：飞书会话通知）
# 用法: bash notify-alpha.sh {来源} {标题} {内容} [优先级]
FROM="${1:?必须指定来源}"
SUBJECT="${2:-无标题}"
BODY="${3:?必须指定内容}"
PRIORITY="${4:-normal}"

# 同时写inbox + 发session通知
SCRIPTS="/home/gang/.openclaw/workspace/scripts"
INBOX="/home/gang/.openclaw/workspace/inbox"

# 📧 写入阿尔法inbox
MAIL_FILE=$(bash "${SCRIPTS}/mail_write.sh" "$INBOX" "$FROM" "alpha" "$SUBJECT" "$BODY" "$PRIORITY")
if [ $? -ne 0 ]; then echo "❌ 邮件写入失败"; exit 1; fi
echo "📧 [mail] → alpha: $(basename "$MAIL_FILE")"

# 💬 通知阿尔法session
timeout 5 openclaw agent --agent alpha --message "[inbox] 来自${FROM} | ${SUBJECT}" --json > /dev/null 2>&1 &
echo "✅ [notify] 已通知 alpha"
