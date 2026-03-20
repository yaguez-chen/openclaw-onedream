#!/bin/bash
# check-acks.sh — 检查发出的消息是否被对方确认收到
# 用法: bash check-acks.sh {Agent名}
# 示例: bash check-acks.sh theta
# 
# 原理：对比自己发出的inbox文件和对方的ack文件

AGENT="${1:?必须指定Agent名}"
MY_INBOX="/home/gang/.openclaw/workspace-${AGENT}/inbox"
ALPHA_INBOX="/home/gang/.openclaw/workspace/inbox"

echo "=== ${AGENT} 消息送达确认 ==="
echo ""

# 1. 检查发给阿尔法的消息是否有ack
echo "📤 发给阿尔法的消息（在阿尔法inbox中）:"
SENT_TO_ALPHA=$(ls -1t "$ALPHA_INBOX"/msg-*-${AGENT}-*.json 2>/dev/null)
if [ -z "$SENT_TO_ALPHA" ]; then
  echo "   没有找到${AGENT}发给阿尔法的消息"
else
  for f in $SENT_TO_ALPHA; do
    bn=$(basename "$f")
    echo "   📄 ${bn}"
    
    # 检查该消息是否要求ack
    ACK_REQ=$(cat "$f" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('ack_required',False))" 2>/dev/null)
    MSG_ID=$(cat "$f" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('id',''))" 2>/dev/null)
    
    if [ "$ACK_REQ" = "True" ]; then
      # 检查是否有对应的ack文件
      ACK_FILE=$(ls "$MY_INBOX"/ack-${MSG_ID}*.json 2>/dev/null | head -1)
      if [ -n "$ACK_FILE" ]; then
        echo "      ⚡ 已确认收到 (ack: $(basename $ACK_FILE))"
      else
        echo "      ⏳ 等待确认中..."
      fi
    else
      echo "      📋 未要求确认 (ack_required=false)"
    fi
  done
fi

echo ""

# 2. 检查收件箱中的未读消息
echo "📥 ${AGENT}收到但未读的消息:"
NEW_MSGS=$(bash /home/gang/.openclaw/workspace/scripts/check-inbox.sh "$AGENT" --unread 2>/dev/null | grep "^📄" | wc -l)
if [ "$NEW_MSGS" -gt 0 ]; then
  echo "   ⚠️  ${NEW_MSGS}条未读消息！"
  bash /home/gang/.openclaw/workspace/scripts/check-inbox.sh "$AGENT" --unread 2>/dev/null | grep "^📄"
else
  echo "   ✅ 没有未读消息"
fi
