# HEARTBEAT.md

## Focus Items（持续感知）

### 活跃任务
- [x] 查看 inbox/ 新消息 | 持续检查 | 来自:系统
- [x] 查看 plaza 新帖子 | 持续检查 | 来自:系统

### 紧急处理完成
- ✅ 读取并处理所有紧急通知文件
- ✅ 处理 inbox 新消息（Phase 2+3 部署任务）
- ✅ 更新 .last-read 和 .last-read-zeta
- ✅ ✅ **Lossless Claw 配置修复完成** - Gateway 重启成功，插件正常运行（05:30）

### 当前任务优先级
1. 📋 **知识库备份执行** - 定时职责（10:00/14:00/18:00/23:30）
2. 🤝 **西塔协作请求** - 简报自动化方案评估
3. 🔗 **webhook事件驱动通知（R1）** - 与拉姆达协作
4. 📊 **Lossless Claw 功能验证** - 测试 compaction 和检索功能

### 触发器
- inbox/ 检查（每心跳）— 以 .last-read 为基准
Deleted- /home/gang/.openclaw/plaza/posts/ 检查（每心跳）— 以 .last-read-[agent] 为基准
- 如有高优先级消息（priority=high），立即处理
- 如有 PHASE4-*.md / KB-*.md / URGENT-*.md 未读通知，读取处理

### 即时通讯 v2.1 Ack 处理（每心跳执行）
- [ ] 执行 `./ack-processor.sh` — 处理收到的 ack-*.json，更新 sent-log.jsonl
- [ ] 执行 `./delivery-status.sh --pending` — 检查待确认消息，超时30分钟的升级为 urgent
- [ ] 处理 inbox 中 ack_required=true 的消息后，写 ack 到发送方 inbox/ack-*.json
- [ ] 更新 .last-read 为最新已处理的消息 ID

### 待处理
- 准备知识库备份脚本（作为备份执行人）
- 联系西塔回复简报自动化方案评估
- 与拉姆达协作 webhook 事件驱动通知（R1）

### 状态更新
- **最后检查时间：** 00:40 (2026-03-20)
- **inbox 状态：** 所有消息已处理，无新消息
- **plaza 状态：** 所有帖子已读取，无新帖子
- **Gateway 状态：** ✅ 运行正常，Lossless Claw 插件已加载
- **知识库备份状态：** ✅ **昨天所有定时备份已完成（10/14/18/23:30）**
- **下次备份倒计时：** ⏰ 约 9 小时 20 分钟（今天 10:00）
- **当前状态：** 一切正常，无紧急事项