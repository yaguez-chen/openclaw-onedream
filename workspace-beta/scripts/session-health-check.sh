#!/usr/bin/env bash
# session-health-check.sh — Phase 2: Session 健康检测 (FIXED v2 + RECOVER v3)
# 作者：贝塔 🔵
# 创建：2026-03-18
# 修复：改用 jsonl 文件内时间戳检测活跃度，而非文件 mtime
# 新增：--recover 自动恢复卡死 session（发送唤醒消息到 inbox）
# 用法：./scripts/session-health-check.sh [--notify] [--json] [--recover]

set -uo pipefail

AGENTS_DIR="/home/gang/.openclaw/agents"
WORKSPACE_BASE="/home/gang/.openclaw"
NOW_HUMAN=$(date '+%Y-%m-%d %H:%M:%S %Z')
STALE_THRESHOLD_S=1800  # 30 minutes
STREAM_ERROR_WINDOW_S=600  # 10 minutes
NOTIFY=false
JSON_OUTPUT=false
RECOVER=false
HEALTHY=0
STALE=0
ERRORS=0
RECOVERED=0
RECOVER_FAILED=0
REPORT=""
ALERTS=""
RECOVER_LOG=""

for arg in "$@"; do
  case "$arg" in
    --notify) NOTIFY=true ;;
    --json) JSON_OUTPUT=true ;;
    --recover) RECOVER=true ;;
  esac
done

AGENTS=(main beta gamma delta epsilon eta theta iota kappa lambda zeta)

check_session_health() {
  local agent="$1"
  local sessions_dir="$AGENTS_DIR/$agent/sessions"
  
  [[ -d "$sessions_dir" ]] || { REPORT+="  $agent: ⚫ 无sessions目录\n"; return; }
  
  # Find the most recent .jsonl file by reading timestamps from inside files
  local latest_session=""
  local latest_ts_epoch=0
  local latest_ts_human="N/A"
  
  for f in "$sessions_dir"/*.jsonl; do
    [[ -f "$f" ]] || continue
    [[ "$f" == *".deleted."* || "$f" == *".reset."* ]] && continue
    
    # Get last activity time: use file mtime (reliable for compacted sessions)
    # Note: jsonl timestamps are unreliable for compacted sessions where the file
    # is rewritten but entries retain original timestamps. File mtime correctly
    # reflects when the session was last written to.
    local result
    result=$(python3 -c "
import os, json
from datetime import datetime, timezone

# Primary: use file mtime (works for compacted sessions)
mtime = os.path.getmtime('$f')

# Secondary: also read last jsonl timestamp for display
last_ts = None
try:
    for line in open('$f'):
        try:
            d = json.loads(line.strip())
            ts = d.get('timestamp', '')
            if ts:
                last_ts = ts
        except:
            pass
except:
    pass

# Use mtime as the activity indicator (most reliable)
print(f'{int(mtime)} {last_ts or \"compacted\"}')
" 2>/dev/null)
    
    if [[ -n "$result" ]]; then
      local epoch
      epoch=$(echo "$result" | awk '{print $1}')
      if (( epoch > latest_ts_epoch )); then
        latest_ts_epoch=$epoch
        latest_ts_human=$(echo "$result" | awk '{$1=""; print $0}' | xargs)
        latest_session="$f"
      fi
    fi
  done
  
  if [[ -z "$latest_session" ]]; then
    REPORT+="  $agent: ⚫ 无活跃session\n"
    return
  fi
  
  local now_epoch
  now_epoch=$(date +%s)
  local age_s=$(( now_epoch - latest_ts_epoch ))
  local age_min=$(( age_s / 60 ))
  
  # Check for stream errors in last 10 minutes
  local cutoff_s=$(( now_epoch - STREAM_ERROR_WINDOW_S ))
  local stream_errors
  stream_errors=$(tail -50 "$latest_session" 2>/dev/null | python3 -c "
import json, sys
errors = 0
for line in sys.stdin:
    try:
        d = json.loads(line.strip())
        msg = d.get('message', {})
        if msg.get('isError'):
            errors += 1
        content = msg.get('content', '')
        if isinstance(content, list):
            for c in content:
                if isinstance(c, dict):
                    text = c.get('text', '')
                    if any(kw in text.lower() for kw in ['chunks', 'delta before', 'message_start', 'stream error']):
                        errors += 1
    except:
        pass
print(errors)
" 2>/dev/null || echo 0)
  
  # Get context usage from last entry
  local ctx_usage
  ctx_usage=$(tail -5 "$latest_session" 2>/dev/null | python3 -c "
import json, sys
for line in reversed(sys.stdin.readlines()):
    try:
        d = json.loads(line.strip())
        usage = d.get('message', {}).get('usage', {})
        if usage:
            total = usage.get('totalTokens', usage.get('total', 0))
            pct = int(total / 262144 * 100)
            print(f'{pct}% ({total}/262144)')
            break
    except:
        pass
" 2>/dev/null || echo "N/A")
  
  # Determine status
  local status_icon status_text
  if (( age_s > STALE_THRESHOLD_S )); then
    status_icon="🔴"
    status_text="STALE ${age_min}min"
    STALE=$((STALE + 1))
    ALERTS+="\n🔴 [$agent] 停滞 ${age_min} 分钟 (最后活动: $(echo "$latest_ts_human" | cut -c1-19))"
  elif (( stream_errors > 2 )); then
    status_icon="🟡"
    status_text="STREAM_ERR x${stream_errors}"
    ERRORS=$((ERRORS + 1))
    ALERTS+="\n🟡 [$agent] 最近10分钟 ${stream_errors} 个流式错误"
  else
    status_icon="🟢"
    status_text="OK ${age_min}min ago"
    HEALTHY=$((HEALTHY + 1))
  fi
  
  REPORT+="  $status_icon $agent: $status_text | ctx: $ctx_usage\n"
}

# Main
REPORT="🔵 Session 健康检测 v2 — $NOW_HUMAN\n"
REPORT+="━━━━━━━━━━━━━━━━━━━━━━━━\n"

for agent in "${AGENTS[@]}"; do
  check_session_health "$agent"
done

REPORT+="\n📊 汇总: 🟢${HEALTHY} 🟡${ERRORS} 🔴${STALE}\n"

echo -e "$REPORT"
if [[ -n "$ALERTS" ]]; then
  echo -e "⚠️ 异常:$ALERTS"
fi

# Notify if requested and issues found
if $NOTIFY && (( STALE > 0 || ERRORS > 0 )); then
  echo "📬 检测到异常，建议通知梦想家"
fi

# Auto-recover stale sessions if --recover flag set
recover_session() {
  local agent="$1"
  local sessions_dir="$AGENTS_DIR/$agent/sessions"
  [[ -d "$sessions_dir" ]] || return
  
  # Find latest session and check if stale
  local latest_ts_epoch=0
  
  for f in "$sessions_dir"/*.jsonl; do
    [[ -f "$f" ]] || continue
    [[ "$f" == *".deleted."* || "$f" == *".reset."* ]] && continue
    
    local epoch
    epoch=$(python3 -c "import os; print(int(os.path.getmtime('$f')))" 2>/dev/null)
    
    if [[ -n "$epoch" ]] && (( epoch > latest_ts_epoch )); then
      latest_ts_epoch=$epoch
    fi
  done
  
  if (( latest_ts_epoch > 0 )); then
    local now_epoch=$(date +%s)
    local age_s=$(( now_epoch - latest_ts_epoch ))
    if (( age_s > STALE_THRESHOLD_S )); then
      # Recovery: send wakeup message to agent's inbox
      local inbox_dir="$WORKSPACE_BASE/workspace-$agent/inbox"
      local wakeup_file="$inbox_dir/msg-recovery-$(date +%Y%m%d-%H%M%S)-beta.json"
      
      mkdir -p "$inbox_dir" 2>/dev/null
      
      cat > "$wakeup_file" << WAKEUP
{
  "id": "msg-recovery-$(date +%Y%m%d-%H%M%S)-beta",
  "timestamp": "$(date -Iseconds)",
  "from": "beta",
  "priority": "high",
  "type": "wakeup",
  "subject": "🔔 自动恢复唤醒",
  "body": "$agent 你好！Session 健康检测发现你已停滞超过30分钟。请立即处理 inbox 消息并更新 .last-read。— 贝塔 🔵（自动恢复）"
}
WAKEUP
      
      if [[ -f "$wakeup_file" ]]; then
        RECOVER_LOG+="  ✅ $agent: 唤醒消息已投递 (停滞$((age_s/60))min)\n"
        RECOVERED=$((RECOVERED + 1))
      else
        RECOVER_LOG+="  ❌ $agent: 唤醒消息投递失败\n"
        RECOVER_FAILED=$((RECOVER_FAILED + 1))
      fi
    fi
  fi
}

if $RECOVER && (( STALE > 0 )); then
  RECOVER_LOG="\n🔧 自动恢复开始 — $NOW_HUMAN\n"
  RECOVER_LOG+="━━━━━━━━━━━━━━━━━━━━━━━━\n"
  
  for agent in "${AGENTS[@]}"; do
    recover_session "$agent"
  done
  
  RECOVER_LOG+="\n📊 恢复结果: ✅${RECOVERED} 成功 / ❌${RECOVER_FAILED} 失败\n"
  echo -e "$RECOVER_LOG"
fi

(( STALE == 0 && ERRORS == 0 )) || exit 1
