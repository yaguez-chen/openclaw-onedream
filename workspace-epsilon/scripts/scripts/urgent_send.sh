#!/bin/bash
# urgent_send.sh — 通信层：📧邮件 + 📞电话（紧急，等回复）
# 调用：mail_write.sh（邮件原子层）+ openclaw agent（电话协议层）
# 用法: bash urgent_send.sh {来源} {目标} {标题} {内容}
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
MAIL_FILE=$(bash "${SCRIPTS}/mail_write.sh" "$INBOX" "$FROM" "$TARGET" "$SUBJECT" "$BODY" "high")
if [ $? -ne 0 ]; then echo "❌ 邮件写入失败"; exit 1; fi
echo "📧 [mail] $(basename "$MAIL_FILE")"

# 📞 调用电话协议层叫醒
echo "📞 [call] 叫醒 ${TARGET}..."
result=$(timeout 15 openclaw agent --agent "$TARGET" \
  --message "[urgent] 来自${FROM} | ${SUBJECT}: ${BODY}" \
  --json 2>/dev/null)
if [ $? -eq 0 ]; then
  echo "✅ [call] ${TARGET} 已回复"
  echo "$result" | python3 -c "
import sys,json
try:
    d=json.loads(sys.stdin.read())
    for p in d.get('result',{}).get('payloads',[]):
        print('💬 回复: '+p.get('text',''))
except: pass
" 2>/dev/null
else
  echo "⚠️ [call] ${TARGET} 未响应（邮件已留痕）"
fi
