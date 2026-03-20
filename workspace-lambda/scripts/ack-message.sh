#!/bin/bash
# ack-message.sh — 自动确认收到消息并写ack
# 用法: bash ack-message.sh {接收方Agent名} {消息文件路径}
# 示例: bash ack-message.sh theta /home/gang/.openclaw/workspace-theta/inbox/msg-20260320-1743-alpha-通知.json

RECEIVER="${1:?必须指定接收方Agent名}"
MSG_FILE="${2:?必须指定消息文件路径}"

if [ ! -f "$MSG_FILE" ]; then
  echo "❌ 消息文件不存在: ${MSG_FILE}"
  exit 1
fi

# 读取消息信息
MSG_ID=$(cat "$MSG_FILE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('id',''))" 2>/dev/null)
MSG_FROM=$(cat "$MSG_FILE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('from',''))" 2>/dev/null)
ACK_REQ=$(cat "$MSG_FILE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('ack_required',False))" 2>/dev/null)

if [ -z "$MSG_ID" ]; then
  echo "❌ 无法读取消息ID"
  exit 1
fi

echo "📩 确认消息: ${MSG_ID}"
echo "   来自: ${MSG_FROM}"
echo "   ack_required: ${ACK_REQ}"

# 确定ack目标路径（发给消息的发送方）
if [ "$MSG_FROM" = "alpha" ] || [ "$MSG_FROM" = "main" ]; then
  ACK_TARGET="/home/gang/.openclaw/workspace/inbox"
else
  ACK_TARGET="/home/gang/.openclaw/workspace-${MSG_FROM}/inbox"
fi

# 写ack文件
ACK_FILE="${ACK_TARGET}/ack-${MSG_ID}.json"
TIMESTAMP=$(date -Iseconds)

# JSON安全转义
SAFE_REF=$(python3 -c "import json,sys; print(json.dumps(sys.argv[1]))" "$MSG_ID")
SAFE_FROM=$(python3 -c "import json,sys; print(json.dumps(sys.argv[1]))" "$RECEIVER")
SAFE_TO=$(python3 -c "import json,sys; print(json.dumps(sys.argv[1]))" "$MSG_FROM")

cat > "$ACK_FILE" << EOF
{
  "id": "ack-${MSG_ID}",
  "timestamp": "${TIMESTAMP}",
  "from": ${SAFE_FROM},
  "to": ${SAFE_TO},
  "type": "ack",
  "ref_id": ${SAFE_REF},
  "status": "processed"
}
EOF

# 验证ack写入
if [ -f "$ACK_FILE" ]; then
  echo "   ✅ ack已写入: ${ACK_FILE}"
else
  echo "   ❌ ack写入失败！"
  exit 1
fi
