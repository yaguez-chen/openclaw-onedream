#!/bin/bash
# send-to-dreamer.sh — 通过飞书 API 给梦想家发消息
# 用法: ./send-to-dreamer.sh <消息内容>
# 原理: 每个 Agent 用自己的飞书 App 凭证，通过 Contact API 查找梦想家的 open_id，然后发消息
# 注意: 每个飞书 App 生成的 open_id 不同，必须用自己的 App 查找！

set -e

MESSAGE="$1"
if [ -z "$MESSAGE" ]; then
  echo "用法: $0 <消息内容>"
  exit 1
fi

OPENCLAW_CONFIG="/home/gang/.openclaw/openclaw.json"

# Step 0: 获取当前 Agent 名（从 workspace 路径推断）
# 脚本位置: workspace-{agent}/skills/comm/scripts/send-to-dreamer.sh
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# 从路径中提取 workspace-{agent} 部分
WORKSPACE_DIR=$(echo "$SCRIPT_DIR" | grep -oP '/home/[^/]+/\.openclaw/workspace[^/]*/' | head -1 | sed 's|/$||')
AGENT_NAME=$(basename "$WORKSPACE_DIR" | sed 's/workspace-//')
[ "$AGENT_NAME" = "workspace" ] && AGENT_NAME="main"

echo "🔧 Agent: $AGENT_NAME"

# Step 1: 从 openclaw.json 读取飞书 App 凭证
APP_ID=$(python3 -c "
import json,sys
with open('$OPENCLAW_CONFIG') as f:
    data = json.load(f)
accounts = data.get('channels',{}).get('feishu',{}).get('accounts',{})
acc = accounts.get('$AGENT_NAME', {})
print(acc.get('appId',''))
" 2>/dev/null)

APP_SECRET=$(python3 -c "
import json,sys
with open('$OPENCLAW_CONFIG') as f:
    data = json.load(f)
accounts = data.get('channels',{}).get('feishu',{}).get('accounts',{})
acc = accounts.get('$AGENT_NAME', {})
print(acc.get('appSecret',''))
" 2>/dev/null)

if [ -z "$APP_ID" ] || [ -z "$APP_SECRET" ]; then
  echo "❌ 未找到 $AGENT_NAME 的飞书 App 凭证"
  echo "   请检查 openclaw.json 中 channels.feishu.accounts.$AGENT_NAME"
  exit 1
fi

echo "✅ App ID: $APP_ID"

# Step 2: 获取 tenant_access_token
TOKEN_RESP=$(curl -s -X POST "https://open.feishu.cn/open-apis/auth/v3/tenant_access_token/internal" \
  -H "Content-Type: application/json" \
  -d "{\"app_id\":\"$APP_ID\",\"app_secret\":\"$APP_SECRET\"}")

TOKEN=$(echo "$TOKEN_RESP" | grep -o '"tenant_access_token":"[^"]*"' | cut -d'"' -f4)
if [ -z "$TOKEN" ]; then
  echo "❌ 获取 token 失败: $TOKEN_RESP"
  exit 1
fi
echo "✅ Token 获取成功"

# Step 3: 通过 Contact API 查找梦想家的 open_id（每个 App 的 open_id 不同！）
DREAMER_OPEN_ID=$(curl -s "https://open.feishu.cn/open-apis/contact/v3/users?user_id_type=open_id&page_size=50" \
  -H "Authorization: Bearer $TOKEN" | python3 -c "
import json,sys
data = json.load(sys.stdin)
items = data.get('data',{}).get('items',[])
# 按名字找梦想家（陈刚意）
for user in items:
    if user.get('name') == '陈刚意':
        print(user.get('open_id',''))
        break
" 2>/dev/null)

if [ -z "$DREAMER_OPEN_ID" ]; then
  echo "❌ 未找到梦想家（陈刚意）的 open_id"
  echo "   请确认该飞书 App 已添加梦想家为联系人"
  exit 1
fi

echo "✅ 梦想家 open_id: $DREAMER_OPEN_ID"

# Step 4: 发送飞书消息
SEND_RESP=$(curl -s -X POST "https://open.feishu.cn/open-apis/im/v1/messages?receive_id_type=open_id" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"receive_id\":\"$DREAMER_OPEN_ID\",\"msg_type\":\"text\",\"content\":\"{\\\"text\\\":\\\"$MESSAGE\\\"}\"}")

MSG_ID=$(echo "$SEND_RESP" | python3 -c "import json,sys; print(json.load(sys.stdin).get('data',{}).get('message_id',''))" 2>/dev/null)

if [ -n "$MSG_ID" ]; then
  echo "✅ 消息发送成功! 消息ID: $MSG_ID"
else
  echo "❌ 发送失败: $SEND_RESP"
  exit 1
fi
