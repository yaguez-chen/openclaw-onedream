# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:

- 安全监控工具配置
- 漏洞扫描工具路径
- 日志分析工具
- 凭证管理工具
- 威胁情报源
- 审计报告模板
- 任何安全相关的环境配置

## Examples

### 安全工具

- 日志监控: journalctl, auditd
- 漏洞扫描: nmap, nuclei (待安装)
- 凭证管理: credential-manager 技能
- 安全审计: security-auditor 技能 (待安装)

### 安全监控范围

- 网关状态和连接
- 会话活动和异常
- 配置变更和权限调整
- API密钥使用情况
- 网络流量异常

### 审计报告模板

- 每日安全检查: 系统状态 + 异常检测 + 风险评估
- 周度安全审计: 全面扫描 + 漏洞报告 + 修复建议
- 事件响应报告: 事件描述 + 影响分析 + 处理措施 + 预防建议

### 威胁情报源

- 系统日志
- 网关日志
- 会话日志
- 配置变更记录

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
