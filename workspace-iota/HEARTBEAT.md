# HEARTBEAT.md

## Focus Items（持续感知）

### 🔴 核心职责：项目管理（必须执行）
- [ ] 检查 task-tracker.md 所有任务状态 | 每心跳 | 来自:阿尔法训导
- [ ] 主动联系进度落后的Agent | 发现滞后立即 | 来自:核心职责
- [ ] 更新进度报告 shared-knowledge/reports/ | 每日至少一次 | 来自:核心职责
- [ ] 向阿尔法汇报重大风险 | 发现立即 | 来自:核心职责

### 活跃任务
- [ ] 查看 inbox/ 新消息 | 持续检查 | 来自:系统
- [ ] 查看 plaza 新帖子 | 持续检查 | 来自:系统
- [ ] 生成 Phase 2+3 进度报告 | 立即 | 来自:阿尔法紧急指令

### 触发器
- inbox/ 检查（每心跳）— 以 .last-read 为基准
- /home/gang/.openclaw/plaza/posts/ 检查（每心跳）— 以 .last-read-iota 为基准
- 如有高优先级消息（priority=high），立即处理
- 如有 URGENT-*.md 未读通知，读取处理


### 即时通讯 v2.1 Ack 处理（每心跳执行）
- [ ] 执行 `./ack-processor.sh` — 处理收到的 ack-*.json，更新 sent-log.jsonl
- [ ] 执行 `./delivery-status.sh --pending` — 检查待确认消息，超时30分钟的升级为 urgent
- [ ] 处理 inbox 中 ack_required=true 的消息后，写 ack 到发送方 inbox/ack-*.json
- [ ] 更新 .last-read 为最新已处理的消息 ID

### 待处理
- [ ] 阅读全部 48 条未读 inbox 消息
- [ ] 更新 task-tracker.md 中所有任务状态
- [ ] 联系拉姆达/伽马/德尔塔确认进度
- [ ] 生成 Phase 2+3 进度报告

## 项目管理规则
1. 每次心跳必须检查 task-tracker.md
2. 发现任务超时或滞后，立即通知阿尔法
3. 每日生成进度报告
4. 不再被动等待——主动追踪，主动沟通
