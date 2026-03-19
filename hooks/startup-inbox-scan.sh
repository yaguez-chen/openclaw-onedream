#!/bin/bash
# startup-inbox-scan.sh — Gateway 启动后扫描所有 Agent inbox，触发未读消息处理
# Trigger: gateway:startup

set -euo pipefail

echo "🔍 Gateway 启动，开始扫描所有 Agent inbox..."

HOOKS_TOKEN="8d54e4627c496b7c2c0fc8abab6fa5a8cbf4ddbb85cfa42e39b83c30e6b4d9a3"
GATEWAY_URL="http://127.0.0.1:18789"

# 所有 Agent 列表
AGENTS=("alpha" "beta" "gamma" "delta" "epsilon" "zeta" "eta" "theta" "iota" "kappa" "lambda")

for AGENT in "${AGENTS[@]}"; do
    WORKSPACE="/home/gang/.openclaw/workspace-${AGENT}"
    INBOX="${WORKSPACE}/inbox"
    LAST_READ="${INBOX}/.last-read"
    
    # 检查 inbox 目录是否存在
    if [ ! -d "$INBOX" ]; then
        continue
    fi
    
    # 检查是否有 .last-read 文件
    if [ ! -f "$LAST_READ" ]; then
        # 没有 .last-read 文件，检查是否有任何消息文件
        if find "$INBOX" -name "msg-*.json" -maxdepth 1 2>/dev/null | grep -q .; then
            echo "⚠️  ${AGENT}: 有消息但无 .last-read，创建初始指针"
            touch "$LAST_READ"
        else
            continue
        fi
    fi
    
    # 查找比 .last-read 新的消息文件
    NEW_MESSAGES=$(find "$INBOX" -name "msg-*.json" -newer "$LAST_READ" 2>/dev/null | head -1)
    
    if [ -n "$NEW_MESSAGES" ]; then
        echo "📬 ${AGENT}: 发现未读消息，触发处理"
        
        # 调用 webhook 触发该 Agent
        curl -s -X POST "${GATEWAY_URL}/hooks/agent" \
            -H "Authorization: Bearer ${HOOKS_TOKEN}" \
            -d "{\"message\":\"Gateway 重启后扫描到未读消息，请检查 inbox/\",\"agentId\":\"${AGENT}\",\"name\":\"StartupScan\",\"deliver\":false,\"timeoutSeconds\":30}" \
            > /dev/null 2>&1 || echo "⚠️  ${AGENT}: webhook 调用失败"
    else
        echo "✅ ${AGENT}: 无未读消息"
    fi
done

echo "🎯 Gateway 启动扫描完成！"