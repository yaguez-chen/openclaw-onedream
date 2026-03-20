#!/bin/bash
# send-to-other.sh — 向其他Agent的inbox写入消息
# 用法: bash send-to-other.sh {来源} {目标Agent} {优先级} {标题} {内容}
# 示例: bash send-to-other.sh alpha theta high "模型切换通知" "模型已切换到mimo"

FROM="${1:?必须指定来源Agent名}"
TARGET="${2:?必须指定目标Agent名}"
PRIORITY="${3:-normal}"
SUBJECT="${4:-无标题}"
BODY="${5:?必须指定消息内容}"

# 目标inbox路径
TARGET_INBOX="/home/gang/.openclaw/workspace-${TARGET}/inbox"

if [ ! -d "$TARGET_INBOX" ]; then
  echo "❌ 目标inbox不存在: ${TARGET_INBOX}"
  exit 1
fi

TIMESTAMP=$(date -Iseconds)
FILETIME=$(date +%Y%m%d-%H%M%S)
ID="msg-${FILETIME}-${FROM}-$(echo "$SUBJECT" | tr ' ' '-' | head -c 30)"
FILE="${TARGET_INBOX}/${ID}.json"

cat > "$FILE" << EOF
{
  "id": "${ID}",
  "timestamp": "${TIMESTAMP}",
  "from": "${FROM}",
  "to": "${TARGET}",
  "priority": "${PRIORITY}",
  "type": "message",
  "subject": "${SUBJECT}",
  "body": $(echo "$BODY" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))'),
  "read": false,
  "ack_required": true
}
EOF

# 验证写入
if [ -f "$FILE" ]; then
  echo "✅ 已写入: ${FILE}"
  echo "   大小: $(stat -c%s "$FILE") bytes"
else
  echo "❌ 写入失败！文件不存在"
  exit 1
fi
