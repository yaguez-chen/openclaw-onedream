#!/bin/bash
# mail_write.sh — 邮件原子操作：写入inbox
# 用法: bash mail_write.sh {inbox路径} {来源} {目标} {标题} {内容} [优先级]
INBOX="${1:?必须指定inbox路径}"
FROM="${2:?必须指定来源}"
TARGET="${3:?必须指定目标}"
SUBJECT="${4:-无标题}"
BODY="${5:?必须指定内容}"
PRIORITY="${6:-normal}"

TIMESTAMP=$(date -Iseconds)
FILETIME=$(date +%Y%m%d-%H%M%S)
SAFE_SUBJECT=$(echo "$SUBJECT" | tr ' ' '-' | head -c 30)
ID="msg-${FILETIME}-${FROM}-${SAFE_SUBJECT}"

if [ ! -d "$INBOX" ]; then
  echo "❌ inbox不存在: ${INBOX}" >&2
  exit 1
fi

json_body=$(echo "$BODY" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))')

printf '{\n  "id": "%s",\n  "timestamp": "%s",\n  "from": "%s",\n  "to": "%s",\n  "priority": "%s",\n  "type": "message",\n  "subject": "%s",\n  "body": %s,\n  "read": false,\n  "ack_required": true\n}\n' \
  "$ID" "$TIMESTAMP" "$FROM" "$TARGET" "$SUBJECT" "$json_body" > "${INBOX}/${ID}.json"

if [ -f "${INBOX}/${ID}.json" ]; then
  echo "${INBOX}/${ID}.json"
else
  echo "❌ 写入失败" >&2
  exit 1
fi
