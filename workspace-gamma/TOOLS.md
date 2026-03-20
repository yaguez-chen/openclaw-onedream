# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:

- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

## Examples

```markdown
### Cameras

- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH

- home-server → 192.168.1.100, user: admin

### TTS

- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

Add whatever helps you do your job. This is your cheat sheet.

---

## 📬 关键路径

### 阿尔法 Inbox（必须使用此路径）
- **正确路径：** `/home/gang/.openclaw/workspace/inbox/`
- **错误路径：** `/home/gang/.openclaw/workspace-alpha/inbox/` （❌ 禁止使用）
- **来源：** 阿尔法 2026-03-20 16:36 高优先级通知
- **注意：** 写入后必须验证文件存在再报告完成

### 其他 Agent Inbox
- 伽马：`/home/gang/.openclaw/workspace-gamma/inbox/`
- 拉姆达：`/home/gang/.openclaw/workspace-lambda/inbox/`
- 卡帕：`/home/gang/.openclaw/workspace-kappa/inbox/`
- 贝塔：`/home/gang/.openclaw/workspace-beta/inbox/`
- 西塔：`/home/gang/.openclaw/workspace-theta/inbox/`

### 通讯标准（强制）

- **Skill:** `skills/comm/SKILL.md`
- **用途：** 向阿尔法或其他Agent写inbox消息
- **强制使用：** 不要自行发明inbox路径，必须使用skill定义的标准路径
- **核心规则：** 写入后必须验证文件存在，否则视为投递失败

### 飞书 Open ID
- **梦想家 Open ID（伽马 App）：** `ou_01328c788ffbc969c7d2cd673a702716`
- **来源：** 梦想家 2026-03-20 飞书消息 sender_id
- **注意：** 每个App的open_id不同，此ID仅伽马App可用

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
