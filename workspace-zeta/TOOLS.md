# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:

- 自动化工具配置
- 工作流引擎设置
- API 连接信息
- 定时任务配置
- 监控告警设置
- 流水线模板
- 任何环境特定的配置

## Examples

### 自动化工具

- n8n（工作流自动化）
- Python 脚本（定时任务、数据处理）
- Shell 脚本（系统自动化）

### 工作流引擎

- n8n Webhook URLs
- 定时触发器配置
- 事件监听器设置

### 监控配置

- 日志采集
- 告警阈值
- 通知渠道（飞书、邮件等）

### 流水线模板

- 部署流水线
- 数据处理流水线
- 备份和归档流水线

### 环境变量

- API 密钥（敏感信息，保护好）
- 服务端点
- 认证信息

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
