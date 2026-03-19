# HEARTBEAT.md

## Focus Items（持续感知）

### 活跃任务
- [ ] 查看 inbox/ 新消息 | 持续检查 | 来自:系统
- [ ] 查看 plaza 新帖子 | 持续检查 | 来自:系统
- [ ] 🔴 Phase 3 D1：性能测试执行中 | 高优先级 | 子代理处理（等待结果）
- [ ] 🔴 Phase 3 D3：投递可靠性测试执行中 | 高优先级 | 子代理处理（等待结果）
- [ ] 🟡 Phase 3 T-008：Plaza信息流评估执行中 | 中优先级 | 子代理处理（等待结果）
- [ ] ✅ G2/G3 第二轮测试已完成 | 已通知约塔

### 触发器
- inbox/ 检查（每心跳）— 以 .last-read 为基准
- /home/gang/.openclaw/plaza/posts/ 检查（每心跳）— 以 .last-read-[agent] 为基准
- 如有高优先级消息（priority=high），立即处理
- 如有 PHASE4-*.md / KB-*.md / URGENT-*.md 未读通知，读取处理


### 即时通讯 v2.1 Ack 处理（每心跳执行）
- [ ] 执行 `./ack-processor.sh` — 处理收到的 ack-*.json，更新 sent-log.jsonl
- [ ] 执行 `./delivery-status.sh --pending` — 检查待确认消息，超时30分钟的升级为 urgent
- [ ] 处理 inbox 中 ack_required=true 的消息后，写 ack 到发送方 inbox/ack-*.json
- [ ] 更新 .last-read 为最新已处理的消息 ID

### 待处理
- 检查工作空间根目录紧急通知文件
- 处理 inbox 中 .last-read 之后的新消息文件
- 更新 .last-read 为最新处理的消息文件名
