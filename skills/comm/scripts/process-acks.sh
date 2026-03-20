#!/bin/bash
# process-acks.sh — 心跳时自动发送 ack 给发送方
# 用法：./process-acks.sh <my-agent-name>

MY_AGENT=${1:-$(whoami)}
INBOX="/home/gang/.openclaw/workspace-${MY_AGENT}/inbox"

[ -d "$INBOX" ] || { echo "❌ Inbox not found: $INBOX"; exit 1; }

for msg_file in "$INBOX"/msg-*.json; do
  [ -f "$msg_file" ] || continue
  
  # 检查是否需要确认且未确认
  ack_required=$(grep -o '"ack_required": [^,}]*' "$msg_file" 2>/dev/null | head -1 | awk '{print $2}' | tr -d ' ,')
  acked=$(grep -o '"acked": [^,}]*' "$msg_file" 2>/dev/null | head -1 | awk '{print $2}' | tr -d ' ,')
  
  if [ "$ack_required" = "true" ] && [ "$acked" != "true" ]; then
    ack_to=$(grep -o '"from": "[^"]*"' "$msg_file" | head -1 | cut -d'"' -f4)
    msg_id=$(grep -o '"id": "[^"]*"' "$msg_file" | head -1 | cut -d'"' -f4)
    
    if [ -n "$ack_to" ]; then
      ACK_INBOX="/home/gang/.openclaw/workspace-${ack_to}/inbox"
      mkdir -p "$ACK_INBOX"
      ACK_ID="ack-$(date +%Y%m%d-%H%M%S)-${msg_id##*-}"
      
      # JSON安全转义
      SAFE_MSG_ID=$(python3 -c "import json,sys; print(json.dumps(sys.argv[1]))" "$msg_id")
      SAFE_MY_AGENT=$(python3 -c "import json,sys; print(json.dumps(sys.argv[1]))" "$MY_AGENT")

      cat > "${ACK_INBOX}/${ACK_ID}.json" << EOF
{
  "id": "${ACK_ID}",
  "timestamp": "$(date -Iseconds)",
  "from": ${SAFE_MY_AGENT},
  "type": "ack",
  "ref_id": ${SAFE_MSG_ID},
  "status": "read",
  "read_at": "$(date -Iseconds)"
}
EOF
      # 标记原消息已确认
      sed -i 's/"read": false/"read": true, "acked": true/' "$msg_file"
      echo "✅ Ack sent: ${msg_id} → ${ack_to}"
    fi
  fi
done
