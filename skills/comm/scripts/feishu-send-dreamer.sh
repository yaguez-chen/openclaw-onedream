#!/bin/bash
# feishu-send-dreamer.sh — 飞书API直发梦想家
# 用法: bash feishu-send-dreamer.sh {Agent名} "消息内容"
# Open ID获取优先级：TOOLS.md → openclaw.json → Contact API → openclaw agent回退

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

# openclaw agent回退函数
agent_fallback() {
  openclaw agent --agent "$AGENT" --message "$MSG" --json 2>/dev/null
  echo "🔄 回退到 openclaw agent 通知"
}

# 1. 优先从TOOLS.md读取
OPEN_ID=$(grep -oP '梦想家 Open ID.*?`([a-zA-Z0-9]+)`' "$TOOLS" 2>/dev/null | grep -oP '`[a-zA-Z0-9]+`' | tr -d '`')

# 2. 回退到openclaw.json
if [ -z "$OPEN_ID" ]; then
  OPEN_ID=$(python3 -c "import json; print(json.load(open('$CONFIG')).get('feishu',{}).get('dreamerOpenId',''))" 2>/dev/null)
fi

# 3. 回退到Contact API
if [ -z "$OPEN_ID" ]; then
  echo "⚠ 未找到保存的Open ID，尝试Contact API..."
  TOKEN=$(curl -s -X POST "https://open.feishu.cn/open-apis/auth/v3/tenant_access_token/internal" \
    -H "Content-Type: application/json" \
    -d "$(python3 -c "import json; print(json.dumps({'app_id':'${APP_ID}','app_secret':'${APP_SECRET}'}))")" \
    | python3 -c "import json,sys; print(json.load(sys.stdin).get('tenant_access_token',''))" 2>/dev/null)
  if [ -n "$TOKEN" ]; then
    OPEN_ID=$(curl -s "https://open.feishu.cn/open-apis/contact/v3/users/union_id_mapping?page_size=1" \
      -H "Authorization: Bearer ${TOKEN}" 2>/dev/null)
    echo "⚠ Contact API需要union_id，请在TOOLS.md手动添加梦想家Open ID"
  fi
fi

if [ -z "$OPEN_ID" ]; then
  echo "❌ 无法获取梦想家Open ID，回退到 openclaw agent"
  agent_fallback
  exit 0
fi

# 获取token并发送
TOKEN=$(curl -s -X POST "https://open.feishu.cn/open-apis/auth/v3/tenant_access_token/internal" \
  -H "Content-Type: application/json" \
  -d "$(python3 -c "import json; print(json.dumps({'app_id':'${APP_ID}','app_secret':'${APP_SECRET}'}))")" \
  | python3 -c "import json,sys; print(json.load(sys.stdin).get('tenant_access_token',''))" 2>/dev/null)

if [ -z "$TOKEN" ]; then
  echo "❌ 获取token失败，回退到 openclaw agent"
  agent_fallback
  exit 0
fi

# 构造JSON payload（安全转义）
PAYLOAD=$(python3 -c "
import json, sys
print(json.dumps({
    'receive_id': sys.argv[1],
    'msg_type': 'text',
    'content': json.dumps({'text': sys.argv[2]})
}))
" "$OPEN_ID" "$MSG")

RESULT=$(curl -s -X POST "https://open.feishu.cn/open-apis/im/v1/messages?receive_id_type=open_id" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" \
  | python3 -c "import json,sys; d=json.load(sys.stdin); print('ok' if d.get('code')==0 else d.get('msg','fail'))" 2>/dev/null)

if [ "$RESULT" = "ok" ]; then
  echo "✅ 飞书直发成功 → ${OPEN_ID}"
else
  echo "⚠ 发送失败($RESULT)，回退到 openclaw agent"
  agent_fallback
fi
