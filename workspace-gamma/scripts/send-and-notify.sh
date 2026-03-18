#!/bin/bash
# send-and-notify.sh — 可靠消息发送 + Webhook 触发（整合拉姆达 R3 方案）
# 用法: ./send-and-notify.sh <target-agent> <priority> <subject> <body>
# 示例: ./send-and-notify.sh lambda high "G1完成" "消息投递确认机制已交付"
#
# 作者：伽马 🔧（整合拉姆达 v2.0 方案）
# 日期：2026-03-18

set -e

TARGET_AGENT=$1
PRIORITY=$2
SUBJECT=$3
BODY=$4

if [ -z "$TARGET_AGENT" ] || [ -z "$PRIORITY" ] || [ -z "$SUBJECT" ] || [ -z "$BODY" ]; then
  echo "用法: $0 <target-agent> <priority> <subject> <body>"
  echo "优先级: high | normal | low"
  exit 1
fi

FROM_AGENT=$(whoami)
WORKSPACE="/home/gang/.openclaw/workspace-${TARGET_AGENT}"
INBOX="${WORKSPACE}/inbox"
MSG_ID="msg-$(date +%Y%m%d-%H%M%S)-$$"
TIMESTAMP=$(date -Iseconds)
HOOKS_TOKEN=$(grep OPENCLAW_HOOKS_TOKEN ~/.openclaw/.env 2>/dev/null | cut -d= -f2 || echo "")

# 检查目标工作空间
if [ ! -d "$WORKSPACE" ]; then
  echo "❌ 目标工作空间不存在: $WORKSPACE"
  exit 1
fi

# Step 1: 写入 inbox 文件
mkdir -p "$INBOX"
cat > "${INBOX}/${MSG_ID}.json" << EOF
{
  "id": "${MSG_ID}",
  "timestamp": "${TIMESTAMP}",
  "from": "${FROM_AGENT}",
  "priority": "${PRIORITY}",
  "type": "notification",
  "subject": "${SUBJECT}",
  "body": "${BODY}",
  "read": false,
  "ack_required": true,
  "ack_to": "${FROM_AGENT}"
}
EOF
echo "✅ 消息已写入: ${MSG_ID}"

# Step 2: 记录到 outbox
OUTBOX="/home/gang/.openclaw/workspace-${FROM_AGENT}/outbox"
mkdir -p "$OUTBOX"
echo "{\"id\":\"${MSG_ID}\",\"to\":\"${TARGET_AGENT}\",\"subject\":\"${SUBJECT}\",\"sent_at\":\"${TIMESTAMP}\",\"status\":\"pending\"}" >> "$OUTBOX/sent-log.jsonl"

# Step 3: Webhook 触发（如果 token 可用）
if [ -n "$HOOKS_TOKEN" ]; then
  WEBHOOK_RESULT=$(curl -s -X POST http://127.0.0.1:18789/hooks/agent \
    -H "Authorization: Bearer ${HOOKS_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "{\"message\":\"收到来自 ${FROM_AGENT} 的新消息（${PRIORITY}）：${SUBJECT}。请立即检查 inbox/ 目录并处理。\",\"agentId\":\"${TARGET_AGENT}\",\"name\":\"InboxNotify\",\"deliver\":false,\"timeoutSeconds\":60}" \
    2>/dev/null || echo "webhook-failed")
  
  if echo "$WEBHOOK_RESULT" | grep -q "webhook-failed"; then
    echo "⚠️ Webhook 触发失败（消息已写入，对方心跳会处理）"
  else
    echo "🔔 Webhook 已触发 ${TARGET_AGENT}"
  fi
else
  echo "⚠️ 未配置 HOOKS_TOKEN，跳过 webhook 触发（消息已写入，对方心跳会处理）"
fi

echo ""
echo "📬 消息详情："
echo "  ID: ${MSG_ID}"
echo "  目标: ${TARGET_AGENT}"
echo "  优先级: ${PRIORITY}"
echo "  主题: ${SUBJECT}"
