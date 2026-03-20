#!/bin/bash
# mail_write.sh — 写入任意inbox（协议层原子能力）
# 用法: bash mail_write.sh {inbox路径} {来源} {目标} {标题} {内容} [优先级]
# 示例:
#   bash mail_write.sh /home/gang/.openclaw/workspace/inbox gamma alpha "任务完成" "技能已部署" normal
#   bash mail_write.sh /home/gang/.openclaw/workspace-lambda/inbox gamma lambda "测试请求" "请验证" high

INBOX="${1:?必须指定inbox路径}"
FROM="${2:?必须指定来源}"
TO="${3:?必须指定目标}"
SUBJECT="${4:?必须指定标题}"
BODY="${5:?必须指定内容}"
PRIORITY="${6:-normal}"

TIMESTAMP=$(date -Iseconds)
FILETIME=$(date +%Y%m%d-%H%M%S)
ID="msg-${FILETIME}-${FROM}-$(echo "$SUBJECT" | tr ' ' '-' | sed 's/["\\\/\n\r]//g' | head -c 30)"
FILE="${INBOX}/${ID}.json"

mkdir -p "$INBOX"

# JSON安全转义所有字段
SAFE_FROM=$(python3 -c "import json,sys; print(json.dumps(sys.argv[1]))" "$FROM")
SAFE_TO=$(python3 -c "import json,sys; print(json.dumps(sys.argv[1]))" "$TO")
SAFE_SUBJECT=$(python3 -c "import json,sys; print(json.dumps(sys.argv[1]))" "$SUBJECT")
SAFE_PRIORITY=$(python3 -c "import json,sys; print(json.dumps(sys.argv[1]))" "$PRIORITY")
SAFE_ID=$(python3 -c "import json,sys; print(json.dumps(sys.argv[1]))" "$ID")

cat > "$FILE" << EOF
{
  "id": ${SAFE_ID},
  "timestamp": "${TIMESTAMP}",
  "from": ${SAFE_FROM},
  "to": ${SAFE_TO},
  "priority": ${SAFE_PRIORITY},
  "type": "message",
  "subject": ${SAFE_SUBJECT},
  "body": $(echo "$BODY" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))'),
  "read": false,
  "ack_required": true
}
EOF

if [ -f "$FILE" ]; then
  echo "✅ 已写入: ${FILE}"
else
  echo "❌ 写入失败！"
  exit 1
fi
