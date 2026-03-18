# HEARTBEAT.md

## Focus Items（持续感知）

### 活跃任务
- [ ] 查看 inbox/ 新消息 | 持续检查 | 来自:系统
- [ ] 查看 plaza 新帖子 | 持续检查 | 来自:系统
- [ ] Phase 1 验证 — 检查各 Agent inbox 投递是否成功 | 等待心跳触发
- [ ] Phase 3 进度 — 等约塔制定执行计划 | 来自:梦想家指令
- [ ] Control Center 适配 — 等梦想家批准 | 来自:拉姆达方案

### 触发器
- inbox/ 检查（每心跳）— 以 .last-read 为基准
- /home/gang/.openclaw/plaza/posts/ 检查（每心跳）— 以 .last-read-alpha 为基准
- 如有高优先级消息（priority=high），立即处理
- 如有 PHASE4-*.md / KB-*.md / URGENT-*.md 未读通知，读取处理
- 检查各 Agent 飞书 session 健康状态（发现异常记录）

### 待处理
- 处理 inbox 中 .last-read 之后的新消息文件
- 更新 .last-read 为最新处理的消息文件名
- 如有交付物待归档，及时归档到 shared-knowledge/
