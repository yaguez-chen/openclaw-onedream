#!/bin/bash
# send-to-alpha.sh — 向阿尔法inbox写入消息（Agent专用）
# 用法: bash send-to-alpha.sh {来源} {优先级} {标题} {内容}
# 示例: bash send-to-alpha.sh theta normal "早餐回复" "梦想家回复：糯米饭"

FROM="${1:?必须指定来源Agent名}"
PRIORITY="${2:-normal}"
SUBJECT="${3:-无标题}"
BODY="${4:?必须指定消息内容}"
TYPE="${5:-reply}"

TIMESTAMP=$(date -Iseconds)
FILETIME=$(date +%Y%m%d-%H%M%S)
ID="msg-${FILETIME}-${FROM}-$(echo $SUBJECT | tr ' ' '-' | head -c 30)"
FILE="/home/gang/.openclaw/workspace/inbox/${ID}.json"

cat > "$FILE" << EOF
{
  "id": "${ID}",
  "timestamp": "${TIMESTAMP}",
  "from": "${FROM}",
  "to": "alpha",
  "priority": "${PRIORITY}",
  "type": "${TYPE}",
  "subject": "${SUBJECT}",
  "body": $(echo "$BODY" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))'),
  "read": false,
  "ack_required": false
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
