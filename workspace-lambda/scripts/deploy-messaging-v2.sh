#!/bin/bash
# deploy-messaging-v2.sh — 部署即时通讯 v2.1 到所有 Agent workspace
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
AGENTS=(alpha beta gamma delta epsilon zeta eta theta iota kappa lambda gang)
SCRIPTS=("send-and-notify.sh" "ack-processor.sh" "delivery-status.sh" "inbox-scan.sh")
DIRS=("inbox" "outbox" "inbox/archive")

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 即时通讯 v2.1 部署"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

for AGENT in "${AGENTS[@]}"; do
  WORKSPACE="/home/gang/.openclaw/workspace-${AGENT}"
  [ -d "$WORKSPACE" ] || { echo "⏭️  ${AGENT}: workspace 不存在"; continue; }
  echo "📦 ${AGENT}:"
  for DIR in "${DIRS[@]}"; do
    [ -d "${WORKSPACE}/${DIR}" ] || { mkdir -p "${WORKSPACE}/${DIR}"; echo "   📁 ${DIR}/"; }
  done
  for SCRIPT in "${SCRIPTS[@]}"; do
    SOURCE="${SCRIPT_DIR}/${SCRIPT}"
    TARGET="${WORKSPACE}/${SCRIPT}"
    [ -f "$SOURCE" ] || { echo "   ⚠️  ${SCRIPT} 源文件不存在"; continue; }
    cp "$SOURCE" "$TARGET"
    chmod +x "$TARGET"
    echo "   📥 ${SCRIPT}"
  done
  LAST_READ="${WORKSPACE}/inbox/.last-read"
  [ -f "$LAST_READ" ] || { echo "" > "$LAST_READ"; echo "   📝 .last-read"; }
  echo ""
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 部署验证："
for AGENT in "${AGENTS[@]}"; do
  WORKSPACE="/home/gang/.openclaw/workspace-${AGENT}"
  [ -d "$WORKSPACE" ] || continue
  OK=0; MISS=0
  for SCRIPT in "${SCRIPTS[@]}"; do
    [ -x "${WORKSPACE}/${SCRIPT}" ] && ((OK++)) || ((MISS++))
  done
  INBOX="❌"; [ -d "${WORKSPACE}/inbox" ] && INBOX="✅"
  STATUS="✅"; [ "$MISS" -gt 0 ] && STATUS="⚠️"
  echo "   ${STATUS} ${AGENT}: ${OK}/${#SCRIPTS[@]} scripts, inbox ${INBOX}"
done
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
