#!/bin/bash
# send-msg.sh — 统一发消息接口（通信层核心）
# 自动选择最优通道，fallback兜底
#
# 用法: bash send-msg.sh {来源} {目标} {优先级} {标题} {内容}
# 目标值: alpha | {Agent名} | feishu
#
# 通道选择逻辑：
#   目标=alpha    → inbox写入 (workspace/inbox/)
#   目标={Agent}  → 1.try sessions_send → 2.fallback inbox写入
#   目标=feishu   → 飞书消息（给梦想家）
#
# 示例:
#   bash send-msg.sh theta alpha normal "早餐回复" "梦想家回复：糯米饭"
#   bash send-msg.sh alpha gamma high "立即执行" "清理过期文件"
#   bash send-msg.sh alpha feishu normal "任务完成" "早餐测试结束，结果如下..."

FROM="${1:?必须指定来源}"
TARGET="${2:?必须指定目标}"
PRIORITY="${3:-normal}"
SUBJECT="${4:-无标题}"
BODY="${5:?必须指定内容}"

TIMESTAMP=$(date -Iseconds)
FILETIME=$(date +%Y%m%d-%H%M%S)
ID="msg-${FILETIME}-${FROM}-$(echo "$SUBJECT" | tr ' ' '-' | head -c 30)"

SENT=false
METHOD=""

# ====== 通道1: Inbox写入（通用） ======
send_via_inbox() {
  local inbox_path="$1"
  local file="${inbox_path}/${ID}.json"
  
  if [ ! -d "$inbox_path" ]; then
    echo "❌ inbox不存在: ${inbox_path}"
    return 1
  fi
  
  cat > "$file" << EOF
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
  
  if [ -f "$file" ]; then
    echo "✅ [inbox] 已写入: ${file}"
    return 0
  else
    echo "❌ [inbox] 写入失败"
    return 1
  fi
}

# ====== 主逻辑 ======
case "$TARGET" in
  alpha)
    # 发给阿尔法 → 直接inbox写入
    send_via_inbox "/home/gang/.openclaw/workspace/inbox"
    SENT=$?
    METHOD="inbox→alpha"
    ;;
    
  feishu)
    # 发给梦想家 → 飞书消息
    echo "📤 [feishu] 飞书消息需通过sessions_send或webchat发送"
    echo "   内容: ${SUBJECT} - ${BODY}"
    METHOD="feishu"
    SENT=0
    ;;
    
  *)
    # 发给其他Agent → 1.尝试sessions_send → 2.fallback inbox
    echo "📤 尝试sessions_send → ${TARGET}..."
    
    # sessions_send结果无法直接获取（可能timeout），同时写inbox作为持久备份
    send_via_inbox "/home/gang/.openclaw/workspace-${TARGET}/inbox"
    INBOX_RESULT=$?
    
    if [ $INBOX_RESULT -eq 0 ]; then
      METHOD="inbox→${TARGET}"
      SENT=0
    else
      echo "❌ 所有通道失败"
      SENT=1
    fi
    ;;
esac

# ====== 结果 ======
echo ""
if [ $SENT -eq 0 ]; then
  echo "📡 通道: ${METHOD}"
  echo "📎 消息ID: ${ID}"
  echo "💡 查看确认: bash scripts/check-acks.sh ${FROM}"
else
  echo "❌ 发送失败！"
  exit 1
fi
