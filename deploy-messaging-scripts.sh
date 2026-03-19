#!/bin/bash
# deploy-messaging-scripts.sh — 部署即时通讯 v2.0 脚本到所有 Agent workspace
# 包括：send-and-notify.sh、process-acks.sh、delivery-status.sh

set -euo pipefail

echo "🚀 开始部署即时通讯 v2.0 脚本到所有 Agent workspace..."

# 源脚本目录（伽马 workspace）
SOURCE_DIR="/home/gang/.openclaw/workspace-gamma/scripts"
SCRIPTS=("send-and-notify.sh" "process-acks.sh" "delivery-status.sh")

# 所有 Agent 列表
AGENTS=("alpha" "beta" "gamma" "delta" "epsilon" "zeta" "eta" "theta" "iota" "kappa" "lambda")

# 检查源脚本是否存在
for SCRIPT in "${SCRIPTS[@]}"; do
    if [ ! -f "${SOURCE_DIR}/${SCRIPT}" ]; then
        echo "❌ 错误：源脚本 ${SCRIPT} 不存在于 ${SOURCE_DIR}"
        exit 1
    fi
done

# 部署到每个 Agent
for AGENT in "${AGENTS[@]}"; do
    WORKSPACE="/home/gang/.openclaw/workspace-${AGENT}"
    TARGET_DIR="${WORKSPACE}/scripts"
    INBOX_DIR="${WORKSPACE}/inbox"
    OUTBOX_DIR="${WORKSPACE}/outbox"
    
    echo "📦 部署到 ${AGENT}..."
    
    # 创建目录
    mkdir -p "${TARGET_DIR}" "${INBOX_DIR}" "${OUTBOX_DIR}"
    
    # 复制脚本
    for SCRIPT in "${SCRIPTS[@]}"; do
        cp "${SOURCE_DIR}/${SCRIPT}" "${TARGET_DIR}/"
        chmod +x "${TARGET_DIR}/${SCRIPT}"
        echo "  ✅ ${SCRIPT}"
    done
    
    # 创建 .last-read 文件（如果不存在）
    if [ ! -f "${INBOX_DIR}/.last-read" ]; then
        touch "${INBOX_DIR}/.last-read"
        echo "  ✅ 创建 .last-read"
    fi
    
    # 创建示例 HEARTBEAT.md 集成（如果不存在）
    HEARTBEAT_FILE="${WORKSPACE}/HEARTBEAT.md"
    if [ -f "${HEARTBEAT_FILE}" ]; then
        # 检查是否已包含 ack 处理
        if ! grep -q "process-acks.sh" "${HEARTBEAT_FILE}"; then
            echo "  📝 更新 HEARTBEAT.md（添加 ack 处理）"
            echo -e "\n## 即时通讯 v2.0 Ack 处理（每心跳执行）" >> "${HEARTBEAT_FILE}"
            echo "- [ ] 执行 \`./scripts/process-acks.sh\` — 处理收到的 ack-*.json，更新追踪日志" >> "${HEARTBEAT_FILE}"
        fi
    fi
done

echo "🎯 部署完成！所有 Agent 已安装即时通讯 v2.0 脚本。"
echo ""
echo "📋 已部署脚本："
echo "  • send-and-notify.sh — 带确认支持的消息发送"
echo "  • process-acks.sh    — ack 消息处理"
echo "  • delivery-status.sh — 消息状态查询"
echo ""
echo "🚀 使用方法："
echo "  cd /home/gang/.openclaw/workspace-<agent>"
echo "  ./scripts/send-and-notify.sh <target> urgent \"测试主题\" \"测试内容\""
echo ""