#!/bin/bash
# inbox-scan.sh — 支持 qmd fallback 的 inbox 扫描
set -euo pipefail

INBOX="/home/gang/.openclaw/workspace-$(whoami)/inbox"
LAST_READ=$(cat "${INBOX}/.last-read" 2>/dev/null || echo "")

if [ ! -d "$INBOX" ]; then
  echo "📭 inbox 目录不存在"
  exit 0
fi

# L1: 尝试 qmd
if command -v qmd &>/dev/null && qmd status &>/dev/null 2>&1; then
  echo "🔍 使用 qmd 语义搜索"
  if [ -n "$LAST_READ" ]; then
    qmd search "最近的未读消息" --after "$LAST_READ" --path "$INBOX" 2>/dev/null || {
      echo "⚠️ qmd 搜索失败，降级到 grep"
      find "$INBOX" -name "msg-*.json" -newer "${INBOX}/${LAST_READ}.json" 2>/dev/null | sort
    }
  else
    qmd search "未读消息" --path "$INBOX" 2>/dev/null || {
      echo "⚠️ qmd 搜索失败，降级到 ls"
      ls -t "$INBOX"/msg-*.json 2>/dev/null || echo "📭 inbox 为空"
    }
  fi
# L2: grep 兜底
elif [ -n "$LAST_READ" ] && [ -f "${INBOX}/${LAST_READ}.json" ]; then
  echo "📂 qmd 不可用，使用 find 扫描"
  find "$INBOX" -name "msg-*.json" -newer "${INBOX}/${LAST_READ}.json" 2>/dev/null | sort || echo "📭 无新消息"
# L3: ls 排序兜底
else
  echo "📂 按时间排序扫描"
  ls -t "$INBOX"/msg-*.json 2>/dev/null || echo "📭 inbox 为空"
fi

# 统计未读
UNREAD=$(find "$INBOX" -name "msg-*.json" -exec grep -l '"read":false' {} \; 2>/dev/null | wc -l)
echo ""
echo "📊 未读消息: ${UNREAD} 条"
