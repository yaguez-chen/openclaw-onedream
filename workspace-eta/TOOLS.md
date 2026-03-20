# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:

- 知识源配置
- 索引数据库连接
- 搜索引擎配置
- 分类标签系统
- 知识图谱工具
- 文档管理偏好
- 任何环境特定的配置

## Examples

### 知识管理工具

- 飞书 Wiki（feishu-wiki 技能）
- 自我改进（self-improvement 技能）
- Agent Memory（agent-memory 技能，待安装）

### 知识源

- 飞书文档/知识库
- 系统日志和文档
- 外部知识库

### 分类标签系统

- 按主题分类
- 按时间排序
- 按重要程度分级
- 关键词索引

### 可视化偏好

- 知识图谱：清晰的节点和边
- 索引列表：简洁易读
- 搜索结果：相关性排序

### 工作空间

- 工作空间路径：`/home/gang/.openclaw/workspace-eta`
- 飞书配置：待配置（参考贝塔账号方式）
- 技能：feishu-wiki, self-improvement, agent-memory（后续由伽马安装）

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
