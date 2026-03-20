#!/bin/bash
# feishu-send-dreamer.sh — 飞书API直发梦想家
# 用法: bash feishu-send-dreamer.sh {Agent名} "消息内容"
# Open ID获取优先级：TOOLS.md → openclaw.json → Contact API → sessions_send回退

AGENT="${1:?必须指定Agent名}"
MSG="${2:?必须指定消息内容}"

CONFIG="/home/gang/.openclaw/workspace-${AGENT}/openclaw.json"
TOOLS="/home/gang/.openclaw/workspace-${AGENT}/TOOLS.md"

if [ ! -f "$CONFIG" ]; then
  echo "❌ 找不到配置: $CONFIG"
  exit 1
fi

APP_ID=$(python3 -c "import json; print(json.load(open('$CONFIG'))['feishu']['appId'])" 2>/dev/null)
APP_SECRET=$(python3 -c "import json; print(json.load(open('$CONFIG'))['feishu']['appSecret'])" 2>/dev/null)

if [ -z "$APP_ID" ] || [ -z "$APP_SECRET" ]; then
  echo "❌ 飞书凭证缺失"
  exit 1
fi

# 1. 优先从TOOLS.md读取
OPEN_ID=$(grep -oP '梦想家 Open ID.*?`([a-z0-9]+)`' "$TOOLS" 2>/dev/null | grep -oP '`[a-z0-9]+`' | tr -d '`')

# 2. 回退到openclaw.json
if [ -z "$OPEN_ID" ]; then
  OPEN_ID=$(python3 -c "import json; print(json.load(open('$CONFIG')).get('feishu',{}).get('dreamerOpenId',''))" 2>/dev/null)
fi

# 3. 回退到Contact API
if [ -z "$OPEN_ID" ]; then
  echo "⚠ 未找到保存的Open ID，尝试Contact API..."
  TOKEN=$(curl -s -X POST "https://open.feishu.cn/open-apis/auth/v3/tenant_access_token/internal" \
    -H "Content-Type: application/json" \
    -d "{\"app_id\":\"${APP_ID}\",\"app_secret\":\"${APP_SECRET}\"}" \
    | python3 -c "import json,sys; print(json.load(sys.stdin).get('tenant_access_token',''))" 2>/dev/null)
  if [ -n "$TOKEN" ]; then
    OPEN_ID=$(curl -s "https://open.feishu.cn/open-apis/contact/v3/users/union_id_mapping?page_size=1" \
      -H "Authorization: Bearer ${TOKEN}" 2>/dev/null)
    # Contact API 查找逻辑（需要知道union_id或mobile）
    echo "⚠ Contact API需要union_id，请在TOOLS.md手动添加梦想家Open ID"
  fi
fi

if [ -z "$OPEN_ID" ]; then
  echo "❌ 无法获取梦想家Open ID，回退到 sessions_send"
  sessions_send(label: "$AGENT", message: "$MSG")
  exit 0
fi

# 获取token并发送
TOKEN=$(curl -s -X POST "https://open.feishu.cn/open-apis/auth/v3/tenant_access_token/internal" \
  -H "Content-Type: application/json" \
  -d "{\"app_id\":\"${APP_ID}\",\"app_secret\":\"${APP_SECRET}\"}" \
  | python3 -c "import json,sys; print(json.load(sys.stdin).get('tenant_access_token',''))" 2>/dev/null)

if [ -z "$TOKEN" ]; then
  echo "❌ 获取token失败，回退到 sessions_send"
  sessions_send(label: "$AGENT", message: "$MSG")
  exit 0
fi

RESULT=$(curl -s -X POST "https://open.feishu.cn/open-apis/im/v1/messages?receive_id_type=open_id" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{\"receive_id\":\"${OPEN_ID}\",\"msg_type\":\"text\",\"content\":\"{\\\"text\\\":\\\"${MSG}\\\"}\"}" \
  | python3 -c "import json,sys; d=json.load(sys.stdin); print('ok' if d.get('code')==0 else d.get('msg','fail'))" 2>/dev/null)

if [ "$RESULT" = "ok" ]; then
  echo "✅ 飞书直发成功 → ${OPEN_ID}"
else
  echo "⚠ 发送失败($RESULT)，回退到 sessions_send"
  sessions_send(label: "$AGENT", message: "$MSG")
fi
