#!/bin/bash
# send-and-notify.sh — 带确认支持的发送脚本（优先级路由）
# 用法: ./send-and-notify.sh <agent-name> <subject> <body> [priority] [--no-ack]
set -euo pipefail

TARGET_AGENT="${1:?用法: $0 <agent> <subject> <body> [priority]}"
SUBJECT="${2:?缺少 subject}"
BODY="${3:?缺少 body}"
PRIORITY="${4:-normal}"
NO_ACK="${5:-}"

INBOX="/home/gang/.openclaw/workspace-${TARGET_AGENT}/inbox"
OUTBOX="/home/gang/.openclaw/workspace-$(basename "$(cd "$(dirname "$0")" && pwd)" | sed 's/^workspace-//')/outbox"
MSG_ID="msg-$(date +%Y%m%d-%H%M%S)-$$"
TIMESTAMP=$(date -Iseconds)
HOOKS_TOKEN=$(grep OPENCLAW_HOOKS_TOKEN ~/.openclaw/.env 2>/dev/null | cut -d= -f2 || echo "")

mkdir -p "$INBOX" "$OUTBOX"

ACK_REQUIRED="true"
[ "$NO_ACK" = "--no-ack" ] && ACK_REQUIRED="false"

# 写入消息
cat > "${INBOX}/${MSG_ID}.json" << EOF
{"id":"${MSG_ID}","timestamp":"${TIMESTAMP}","from":"$(basename "$(cd "$(dirname "$0")" && pwd)" | sed 's/^workspace-//')","to":"${TARGET_AGENT}","priority":"${PRIORITY}","type":"notification","subject":"${SUBJECT}","body":"${BODY}","read":false,"ack_required":${ACK_REQUIRED},"ack_to":"$(basename "$(cd "$(dirname "$0")" && pwd)" | sed 's/^workspace-//')"}
EOF
echo "✅ 消息已写入: ${MSG_ID}"

# Outbox 追踪
if [ "$ACK_REQUIRED" = "true" ]; then
  echo "{\"id\":\"${MSG_ID}\",\"to\":\"${TARGET_AGENT}\",\"subject\":\"${SUBJECT}\",\"sent_at\":\"${TIMESTAMP}\",\"acked_at\":null,\"status\":\"pending\"}" >> "${OUTBOX}/sent-log.jsonl"
fi

# Step 2: 优先级路由
case "$PRIORITY" in
  urgent|high)
    # 高优先级：立即 webhook 双通道
    echo "🔴 高优先级 — 双通道即时触发"
    [ -n "$HOOKS_TOKEN" ] && curl -s -X POST http://127.0.0.1:18789/hooks/agent \
      -H "Authorization: Bearer ${HOOKS_TOKEN}" \
      -d "{\"message\":\"⚡ 紧急消息来自 $(basename "$(cd "$(dirname "$0")" && pwd)" | sed 's/^workspace-//')：${SUBJECT}\",\"agentId\":\"${TARGET_AGENT}\",\"name\":\"UrgentNotify\",\"deliver\":false,\"timeoutSeconds\":60}" \
      > /dev/null 2>&1 && echo "🔔 Webhook 已触发" || echo "⚠️ Webhook 失败"
    ;;
  *)
    # 普通优先级：仅写 inbox（Cron 3分钟内会扫描到）
    echo "🟢 普通优先级 — inbox 持久化（Cron 兜底）"
    [ -n "$HOOKS_TOKEN" ] && curl -s -X POST http://127.0.0.1:18789/hooks/agent \
      -H "Authorization: Bearer ${HOOKS_TOKEN}" \
      -d "{\"message\":\"新消息来自 $(basename "$(cd "$(dirname "$0")" && pwd)" | sed 's/^workspace-//')，请检查 inbox/\",\"agentId\":\"${TARGET_AGENT}\",\"name\":\"InboxNotify\",\"deliver\":false,\"timeoutSeconds\":60}" \
      > /dev/null 2>&1 && echo "🔔 Webhook 已触发" || echo "💤 Webhook 未配置（Cron 兜底）"
    ;;
esac
