#!/bin/bash
# normal_send.sh — 通信层：📧邮件 + 💬微信（通知，不等回复）
# 调用：mail_write.sh（邮件原子层）+ openclaw agent（电话协议层，轻通知）
# 用法: bash normal_send.sh {来源} {目标} {标题} {内容}
FROM="${1:?必须指定来源}"
TARGET="${2:?必须指定目标}"
SUBJECT="${3:-无标题}"
BODY="${4:?必须指定内容}"

SCRIPTS="/home/gang/.openclaw/workspace/scripts"

# 确定inbox路径
if [[ "$TARGET" == "alpha" ]]; then
  INBOX="/home/gang/.openclaw/workspace/inbox"
else
  INBOX="/home/gang/.openclaw/workspace-${TARGET}/inbox"
fi

# 📧 调用邮件原子层写入
MAIL_FILE=$(bash "${SCRIPTS}/mail_write.sh" "$INBOX" "$FROM" "$TARGET" "$SUBJECT" "$BODY" "normal")
if [ $? -ne 0 ]; then echo "❌ 邮件写入失败"; exit 1; fi
echo "📧 [mail] $(basename "$MAIL_FILE")"

# 💬 轻通知（不等回复）
echo "💬 [notify] 通知 ${TARGET}..."
timeout 5 openclaw agent --agent "$TARGET" \
  --message "[通知] 来自${FROM} | ${SUBJECT}: 请查看inbox" \
  --json > /dev/null 2>&1 &
echo "✅ [notify] 已通知 ${TARGET}"
