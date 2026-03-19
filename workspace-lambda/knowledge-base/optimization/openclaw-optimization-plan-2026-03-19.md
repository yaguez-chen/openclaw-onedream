# 梦想家乐园 OpenClaw 完整优化方案

> 基于 2026-03-19 Token 消耗分析 + 《OpenClaw 完全优化指南》定制
> 制定者：拉姆达 🔬 | 状态：待执行

---

## 📊 当前状态快照

| 指标 | 当前值 | 问题等级 |
|------|--------|---------|
| 总 Session 数 | 364 | 🔴 Beta 299 个 cron session |
| 总 Input Tokens | 12,912,014 | 🟡 Beta 占 67% |
| Beta Cron Session | 297 (清理后仍多) | 🔴 需要清理历史文件 |
| Lambda Inbox 轮询 | 每 1 分钟 | 🟡 频率过高 |
| Memory Search | 基础模式 | 🔴 缺少混合搜索 |
| Memory Flush 阈值 | 6000 tokens | 🔴 太低，压缩前无法触发 |
| Session Memory 索引 | 未启用 | 🔴 无法回忆历史对话 |
| 模型路由 | 单一 DeepSeek | 🟢 免费，但缺任务分级 |
| 心跳间隔 | 30 分钟 | 🟡 可优化为 55 分钟 |
| Prompt 缓存 | 未显式启用 | 🟡 需检查 provider 支持 |

---

## 🎯 优化目标

1. **减少 50%+ 不必要的 token 消耗**（主要是 cron session 和心跳）
2. **启用记忆系统全套功能**（混合搜索、会话索引、记忆刷写优化）
3. **建立长效 session 管理机制**（自动清理、监控告警）

---

## 第一部分：紧急修复（立即执行）

### 1.1 清理 Beta 历史 Cron Session

**问题：** Beta 的 sessions/ 目录有 297 个 cron session 文件 + 7.4MB 的 sessions.json

**操作：**
```bash
# 清理 Beta 的历史 cron session 文件
cd /home/gang/.openclaw/agents/beta/sessions

# 备份 sessions.json
cp sessions.json sessions.json.bak.$(date +%Y%m%d)

# 删除 cron session 的 .jsonl 文件（保留普通 session）
for f in *.jsonl; do
  sid="${f%.jsonl}"
  if grep -q "cron" sessions.json | grep -q "$sid"; then
    rm -f "$f"
  fi
done

# 或者更直接：删除所有 3 天前的 session 文件
find . -name "*.jsonl" -mtime +3 -delete
find . -name "*.deleted.*" -delete
find . -name "*.reset.*" -delete
```

**预估效果：** 释放 ~5MB 磁盘空间，sessions.json 从 7.4MB 降到 <1MB

### 1.2 调整 Lambda Inbox 轮询频率

**问题：** 全局 Inbox 高频轮询 cron 任务每 1 分钟执行一次

**操作：**
```bash
# 查看当前 cron
openclaw cron list

# 修改轮询频率（从 1m 改为 5m）
openclaw cron set <cron-id> --schedule "every 5m"
```

**预估效果：** 减少 80% 的轮询 session 创建

### 1.3 清理 Beta 的 cron 任务：Session健康检测

**状态：** ✅ 已完成（贝塔已处理）

---

## 第二部分：记忆系统优化（核心）

### 2.1 启用混合搜索（Hybrid Search）

**当前状态：** memorySearch 为空 `{}`，只有基础语义搜索

**需要添加到 openclaw.json：**
```json
{
  "memorySearch": {
    "enabled": true,
    "sources": ["memory", "sessions"],
    "query": {
      "hybrid": {
        "enabled": true,
        "vectorWeight": 0.7,
        "textWeight": 0.3
      }
    }
  }
}
```

**效果：** BM25 能捕获向量搜索遗漏的精确匹配（项目名称、错误代码、特定术语）

### 2.2 启用 Session Memory 索引

**当前状态：** experimental.sessionMemory 未设置

**需要添加到 openclaw.json：**
```json
{
  "experimental": {
    "sessionMemory": true
  }
}
```

**效果：** 将过去的对话分块并索引，可以回答"我们上周二做了什么决定？"这类问题

### 2.3 优化 Memory Flush 阈值

**当前状态：** softThresholdTokens = 6000（太低，压缩已经开始才触发）

**需要修改 openclaw.json 中 compaction.memoryFlush：**
```json
{
  "compaction": {
    "memoryFlush": {
      "enabled": true,
      "softThresholdTokens": 40000,
      "prompt": "将本会话的关键信息写入 memory/YYYY-MM-DD.md。重点记录：决策、状态变更、经验教训、待处理事项。如果没有值得记录的内容，回复 NO_FLUSH。",
      "systemPrompt": "会话即将压缩。立即存储持久记忆。只记录值得记住的内容，不要废话。"
    }
  }
}
```

**效果：** 在压缩开始之前触发记忆保存，防止上下文压缩摧毁未保存的知识

### 2.4 优化上下文修剪

**当前状态：** ttl = 5m（太短，可能丢失有用上下文）

**建议修改：**
```json
{
  "contextPruning": {
    "mode": "cache-ttl",
    "ttl": "6h",
    "keepLastAssistants": 3,
    "softTrimRatio": 0.3,
    "hardClearRatio": 0.5,
    "minPrunableToolChars": 50000
  }
}
```

**效果：** 保留 6 小时的消息（而非 5 分钟），避免丢失最近的对话上下文

---

## 第三部分：成本与 Token 优化

### 3.1 模型分级路由

**当前状态：** 所有 agent 使用 DeepSeek v3.2（免费），无任务分级

**方案：** 虽然 DeepSeek 免费，但不同任务的 token 消耗差异巨大。建议：

| 任务类型 | 推荐模型 | 理由 |
|---------|---------|------|
| 心跳检测 | xiaomi/mimo-claw-0301 | 免费，响应快，简单任务够用 |
| Cron 任务 | xiaomi/mimo-claw-0301 | 免费，多数 cron 是简单操作 |
| 飞书对话 | custom/deepseek-v3.2 | 免费，质量更好 |
| 子代理任务 | custom/deepseek-v3.2 | 需要更好的推理能力 |
| 复杂分析 | custom/deepseek-v3.2 | 需要最大能力 |

**需要修改的配置：**
```json
{
  "heartbeat": {
    "every": "30m",
    "target": "last",
    "model": "xiaomi/mimo-claw-0301"
  }
}
```

### 3.2 心跳间隔优化

**当前状态：** 每 30 分钟

**方案选项：**
- **保守方案：** 保持 30m（稳定，已验证）
- **优化方案：** 改为 55m（配合 prompt 缓存 TTL，每次心跳命中缓存）
- **激进方案：** 改为 60m（进一步减少调用次数）

**建议：** 先保持 30m，等 prompt 缓存确认生效后再改为 55m

### 3.3 Cron 任务 token 预算

**为每个 cron 任务设置最大 token 限制：**
```bash
# 查看当前 cron 任务
openclaw cron list

# 为简单 cron 设置较小的 maxTokens
openclaw cron set <cron-id> --max-tokens 4096
```

---

## 第四部分：长效管理机制

### 4.1 Session 自动清理

创建一个 cron 任务，定期清理过期 session：

```bash
# 创建 session 清理 cron（每周执行）
openclaw cron add \
  --name "Session 定期清理" \
  --schedule "cron 0 3 * * 0" \
  --agent lambda \
  --task "清理所有 agent 超过 7 天的 cron session 文件：
1. 遍历 /home/gang/.openclaw/agents/*/sessions/
2. 删除超过 7 天的 cron-*.jsonl 文件
3. 保留普通 session（feishu:direct, main 等）
4. 报告清理结果" \
  --target isolated
```

### 4.2 Token 使用监控增强

**扩展现有的每日 token 监控：**
```bash
# 当前已有：Beta 的每日 token 使用监控
# 增加：所有 agent 的汇总 + 告警阈值

# 创建增强版监控 cron
openclaw cron add \
  --name "Token 消耗周报" \
  --schedule "cron 0 21 * * 1" \
  --agent lambda \
  --task "生成周度 token 消耗报告：
1. 统计过去 7 天各 agent 的 input/output tokens
2. 识别 top 5 token 消耗 session
3. 检查是否有异常增长
4. 输出到 memory/YYYY-MM-DD-token-report.md" \
  --target isolated
```

### 4.3 QMD 知识库集成（可选进阶）

**当前状态：** QMD 已安装（`/home/gang/.bun/bin/qmd`），但未配置

**方案：** 用 QMD 索引所有 agent 的 MEMORY.md 和 memory/ 目录
```bash
# 配置 QMD 索引
qmd index /home/gang/.openclaw/workspace-lambda/memory/
qmd index /home/gang/.openclaw/workspace-beta/memory/
qmd index /home/gang/.openclaw/workspace-lambda/MEMORY.md

# 设置定期更新
# （需要创建对应的脚本和 cron）
```

---

## 📋 执行优先级

| 优先级 | 任务 | 预估效果 | 复杂度 |
|--------|------|---------|--------|
| P0 | 清理 Beta 历史 cron session | 释放 5MB+ 空间 | ⭐ 简单 |
| P0 | 调整 Lambda 轮询频率 1m→5m | 减少 80% 轮询 session | ⭐ 简单 |
| P1 | 优化 Memory Flush 阈值 6K→40K | 防止记忆丢失 | ⭐ 简单 |
| P1 | 启用混合搜索 | 提升记忆检索质量 | ⭐⭐ 中等 |
| P1 | 启用 Session Memory 索引 | 回忆历史对话 | ⭐⭐ 中等 |
| P2 | 优化上下文修剪 TTL 5m→6h | 保留更多上下文 | ⭐ 简单 |
| P2 | Cron session 自动清理 | 长效防止堆积 | ⭐⭐ 中等 |
| P2 | 心跳模型分级 | 进一步优化 token | ⭐ 简单 |
| P3 | QMD 知识库集成 | 跨 agent 搜索 | ⭐⭐⭐ 复杂 |
| P3 | Token 周报监控 | 持续优化依据 | ⭐⭐ 中等 |

---

## ⚠️ 注意事项

1. **修改 openclaw.json 前先备份**
2. **记忆刷写阈值不要太高** — 太高会导致压缩已经开始才触发，失去意义
3. **上下文 TTL 不要太短** — 5m 太激进，6h 是推荐值
4. **混合搜索需要 QMD 运行中** — 如果 QMD 未启动，会 fallback 到基础搜索
5. **session 清理只删 cron session** — 普通 session（飞书对话、main 等）不能删

---

*方案制定时间：2026-03-19 18:55 GMT+8*
*数据来源：Token 消耗分析 + 《OpenClaw 完全优化指南》*
*执行人：待梦想家确认*
