# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:

- 项目管理工具配置
- 任务追踪系统
- 报告模板
- 截止日期提醒设置
- 资源配置
- 任何环境特定的配置

## Examples

### 项目管理工具

- 任务看板（Trello/Notion/飞书多维表格）
- 甘特图工具
- 燃尽图

### 任务追踪

- 待办 (Pending)
- 进行中 (In Progress)
- 已完成 (Done)
- 阻塞 (Blocked)

### 报告模板

- 日报：今日完成 + 明日计划 + 风险
- 周报：本周进度 + 下周计划 + 资源需求
- 月报：整体进展 + 关键里程碑 + 风险评估

### 里程碑管理

- 项目启动 → 规划 → 执行 → 监控 → 收尾
- 每个里程碑设定明确的验收标准

### 资源协调

- 伙伴列表：阿尔法、贝塔、德尔塔、伽马、约塔
- 技能矩阵：每个伙伴的专业能力
- 工作负载：当前任务分配情况

---

Add whatever helps you do your job. This is your cheat sheet.

### 通讯标准（强制）

- **Skill:** `skills/comm/SKILL.md`
- **用途：** 向阿尔法或其他Agent写inbox消息
- **强制使用：** 不要自行发明inbox路径，必须使用skill定义的标准路径
- **核心规则：** 写入后必须验证文件存在，否则视为投递失败

### 📡 通讯协议（2026-03-20 部署）
- **SKILL位置：** skills/comm/SKILL.md
- **脚本位置：** /home/gang/.openclaw/workspace/scripts/
  - `mail_write.sh` — 写邮件（原子）
  - `mail_read.sh` — 读邮件（原子）
  - `normal_send.sh` — 📧+💬 通知
  - `urgent_send.sh` — 📧+📞 紧急
  - `notify-alpha.sh` — 通知阿尔法
  - `check-inbox.sh` — 查收件箱
  - `check-acks.sh` — 查ack回执
- **铁律：** 不能只发邮件，必须带通知
- **每次唤醒必查inbox**
