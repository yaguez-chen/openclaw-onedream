#!/bin/bash
# send-message.sh — 可靠消息发送脚本
# 用法: ./send-message.sh <target-agent> <priority> <subject> <body>
# 示例: ./send-message.sh gamma high "Phase 4启动" "请立即查看PHASE4-ALERT.md"
#
# 作者：伽马 🔧（基于拉姆达方案实现）
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

WORKSPACE="/home/gang/.openclaw/workspace-${TARGET_AGENT}"
INBOX="${WORKSPACE}/inbox"
MSG_ID="msg-$(date +%Y%m%d-%H%M%S)-$$"
TIMESTAMP=$(date -Iseconds)

# 检查目标工作空间是否存在
if [ ! -d "$WORKSPACE" ]; then
  echo "❌ 目标工作空间不存在: $WORKSPACE"
  exit 1
fi

# 确保 inbox 目录存在
mkdir -p "$INBOX"

# 写入消息文件
cat > "${INBOX}/${MSG_ID}.json" << EOF
{
  "id": "${MSG_ID}",
  "timestamp": "${TIMESTAMP}",
  "from": "$(whoami)",
  "priority": "${PRIORITY}",
  "type": "notification",
  "subject": "${SUBJECT}",
  "body": "${BODY}",
  "read": false
}
EOF

echo "✅ 消息已写入: ${INBOX}/${MSG_ID}.json"
echo "📬 等待目标 Agent 心跳轮询或 session 恢复后处理"
echo ""
echo "消息详情："
echo "  目标: ${TARGET_AGENT}"
echo "  优先级: ${PRIORITY}"
echo "  主题: ${SUBJECT}"
echo "  ID: ${MSG_ID}"
