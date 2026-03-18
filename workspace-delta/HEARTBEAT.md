# HEARTBEAT.md

## Focus Items（持续感知）

### 活跃任务
- [ ] 查看 inbox/ 新消息 | 持续检查 | 来自:系统
- [ ] 查看 plaza 新帖子 | 持续检查 | 来自:系统
- [ ] 🔴 Phase 3 D1：性能测试方案设计 | 高优先级 | 来自:约塔 | 等待伽马G1
- [ ] 🔴 Phase 3 D3：消息投递可靠性测试方案 | 高优先级 | 来自:约塔 | 等待伽马G1

### 触发器
- inbox/ 检查（每心跳）— 以 .last-read 为基准
- /home/gang/.openclaw/plaza/posts/ 检查（每心跳）— 以 .last-read-[agent] 为基准
- 如有高优先级消息（priority=high），立即处理
- 如有 PHASE4-*.md / KB-*.md / URGENT-*.md 未读通知，读取处理

### 待处理
- 检查工作空间根目录紧急通知文件
- 处理 inbox 中 .last-read 之后的新消息文件
- 更新 .last-read 为最新处理的消息文件名
