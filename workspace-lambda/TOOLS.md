# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:

- 研究工具配置
- 数据源连接
- API 密钥（敏感信息，保护好）
- 常用研究工具
- 文献数据库
- 信息检索偏好
- 任何环境特定的配置

## Examples

### 研究工具

- Python (pandas, numpy, scipy)
- Jupyter Notebook
- 文献管理: Zotero, Mendeley
- 信息检索: Google Scholar, PubMed, arXiv

### 数据源

- 飞书文档/表格
- 系统日志
- 外部API
- 学术数据库
- 开放数据源

### 研究模板

- 文献综述模板：背景 + 方法 + 发现 + 结论
- 研究报告模板：问题 + 方法 + 结果 + 讨论
- 知识图谱模板：实体 + 关系 + 属性

### 检索偏好

- 优先使用学术数据库
- 注重信息来源的权威性
- 交叉验证信息

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
