# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:

- 设计偏好（色彩方案、字体风格）
- 图表工具和模板位置
- 创意工作流程笔记
- 灵感来源和参考
- 飞书文档格式偏好

## 待安装技能

- **frontend-design-3** — 前端设计工具（待安装）
- **graphic-design** — 平面设计工具（待安装）
- **diagram-generator** — 图表生成器（待安装）

## 设计偏好

- **色彩方案：** _(待填写你的偏好)_
- **字体风格：** _(待填写你的偏好)_
- **排版风格：** _(待填写你的偏好)_

## 创意工作流

1. 理解需求和目标
2. 收集灵感和参考
3. 草图构思
4. 精细化设计
5. 优化和迭代
6. 输出和交付

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

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
