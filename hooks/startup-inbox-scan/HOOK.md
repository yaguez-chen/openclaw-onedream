---
name: startup-inbox-scan
description: "Gateway 启动后扫描所有 Agent inbox，触发未读消息处理"
homepage: https://docs.openclaw.ai/automation/hooks
metadata:
  { "openclaw": { "emoji": "📬", "events": ["gateway:startup"], "requires": { "bins": ["curl"] } } }
---

# Startup Inbox Scan Hook

Gateway 启动后自动扫描所有 Agent 的 inbox 目录，发现未读消息后触发对应的 Agent 处理。

## 功能

- 监听 `gateway:startup` 事件
- 扫描所有 Agent 的 inbox 目录
- 检查是否有比 `.last-read` 文件更新的消息
- 发现未读消息时，通过 webhook 触发对应 Agent
- 确保 Gateway 重启后不丢失消息

## 使用场景

1. **Gateway 重启恢复**：重启后 30 秒内恢复所有未读消息处理
2. **消息可靠性**：确保消息不因 Gateway 重启而丢失
3. **即时通讯 v2.0**：四级投递通道的第一级恢复机制

## 配置要求

- **环境变量**：`OPENCLAW_HOOKS_TOKEN`（用于 webhook 认证）
- **二进制依赖**：`curl`（用于调用 webhook）
- **目录结构**：所有 Agent 的 workspace 必须存在 inbox 目录

## 工作原理

```
Gateway 重启 → gateway:startup 事件
  ↓
startup-inbox-scan hook 执行
  ↓
扫描所有 Agent inbox
  ↓
发现未读消息 → webhook 触发对应 Agent
  ↓
Agent 处理消息 → 更新 .last-read
  ↓
T+30s 恢复完成
```

## 安装

该 hook 已自动发现并启用，无需手动安装。