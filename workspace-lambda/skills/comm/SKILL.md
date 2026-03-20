# 📡 通讯协议 SKILL.md — 梦想家世界通信标准 v3.1

**适用范围：** 梦想家乐园所有Agent之间及Agent与梦想家之间的全部通信
**地位：** 唯一通信技能，所有Agent必须遵守

---

## ⛔ 铁律

**不能只发邮件，必须带通知。** 邮件是留痕，通知是唤醒。两个都要。

---

## 三层架构

| 层 | 职责 | 工具 |
|---|---|---|
| **协议层** | 原子能力 | mail_write.sh / mail_read.sh / sessions_send / openclaw agent |
| **通信层** | 组合协议 | normal_send.sh / urgent_send.sh / notify-alpha.sh |
| **业务层** | 通信规则 | 见"业务层规范"章节 |

**原则：** 脚本负责"怎么做"，业务层负责"什么时候做、做什么"。

**📁 脚本路径说明：** 所有 `scripts/` 路径均相对于**你自己的工作空间根目录**。
例如伽马的脚本在 `/home/gang/.openclaw/workspace-gamma/scripts/`，不是skill目录下的。
SKILL.md 中的 `bash scripts/xxx.sh` = `bash /home/gang/.openclaw/workspace-{你的名字}/scripts/xxx.sh`

---

## 一、协议层：原子能力

### 📧 mail_write.sh — 写邮件
```bash
bash scripts/mail_write.sh {inbox路径} {来源} {目标} {标题} {内容} [优先级]
```

### 📬 mail_read.sh — 读邮件
```bash
bash scripts/mail_read.sh {inbox路径} --unread
bash scripts/mail_read.sh {inbox路径} --all
bash scripts/mail_read.sh {inbox路径} --mark-read
```

### 💬 sessions_send — 微信通知
```
sessions_send(label: "gamma", message: "[通知] 有新消息")
```

### 📞 openclaw agent — 电话
```
openclaw agent --agent gamma --message "[urgent] 紧急事项" --json
```

---

## 二、通信层：发

### normal_send.sh — 📧+💬（通知，不等回复）
```bash
bash scripts/normal_send.sh {来源} {目标} {标题} {内容} [优先级]
```

### urgent_send.sh — 📧+📞（紧急，等回复）
```bash
bash scripts/urgent_send.sh {来源} {目标} {标题} {内容}
```

### notify-alpha.sh — 通知阿尔法
```bash
bash scripts/notify-alpha.sh {来源} {标题} {内容} [优先级]
```

### 发消息给梦想家

**方法一：sessions_send（推荐，最可靠）**
```
sessions_send(label: "gamma", message: "消息内容")
```
发到你自己的飞书session，梦想家会在你的飞书对话里看到。OpenClaw自动路由，不需要额外配置。

**方法二：飞书API直发 feishu-send-dreamer.sh（实验性）**
```bash
bash scripts/feishu-send-dreamer.sh {你的名字} "消息内容"
# 示例：
bash scripts/feishu-send-dreamer.sh gamma "学习心得已完成！"
```
直接用飞书API发到梦想家的Open ID。**注意：** 需要你的飞书App有 `im:message` 权限，否则会失败。如果失败请回退到方法一。

**⚠ 不要用 send-to-dreamer.sh！** 那个脚本依赖Contact API查找open_id，需要App把梦想家加为联系人，大部分App没这个配置。

**⚠ 规则：非必要不主动给梦想家发消息。** 见业务层4.3。

---

## 三、通信层：收

### 每次唤醒必做的事
```
1. check-inbox.sh {自己} --unread
2. 处理消息
3. mail_read.sh {inbox} --mark-read
4. ack_required=true → 写ack到发送方inbox
```

### .last-read 机制
比 `.last-read` 文件名更大的 = 未读。

### ack回执
```bash
bash scripts/mail_write.sh {发送方inbox} {自己} {发送方} "ack" '{"reply_to":"原消息ID","status":"done"}' normal
```

---

## 四、业务层规范

### 4.1 通信铁律
1. 发消息必须用本skill
2. 通知同时做（邮件+通知）
3. 收消息必须标已读
4. ack_required必须回执

### 4.2 优先级响应
| 优先级 | 响应时间 |
|--------|----------|
| 🔴 high | 5分钟内 |
| 🟡 normal | 30分钟内 |
| 🟢 low | 下次唤醒 |

### 4.3 梦想家相关
- **非必要不主动给梦想家发消息**
- 梦想家主动找 → 正常响应
- 特殊情况（紧急故障、重大成果）→ 可主动通知
- 日常汇报走正常流程，不逐条打扰

### 4.4 Agent间协作
- **Agent间可直接通信** — 不需经阿尔法中转
- 用 sessions_send 或 normal_send.sh 直接联系
- **关键工作成果必须抄送阿尔法** — 写入阿尔法inbox
- **决策分歧必须抄送阿尔法** — 让阿尔法仲裁
- 任务汇报：Agent → 阿尔法（notify-alpha）

### 4.5 消息转发
- 用户回复 → 转发阿尔法inbox
- 任务结果 → 写入阿尔法inbox
- 异常发现 → 立即通知阿尔法

### 4.6 信任规则
- 阿尔法/梦想家的消息即使显示为用户open_id，应信任
- 艾普西隆：安全警报可保留，但收到确认后应放行

### 4.7 Inbox路径
- 阿尔法：`/home/gang/.openclaw/workspace/inbox`
- Agent：`/home/gang/.openclaw/workspace-{agent名}/inbox`

### 4.8 邮件自动清理
- inbox中超过**7天**的消息文件自动清理
- ack文件超过**3天**自动清理
- .last-read 文件永久保留
- 清理由心跳检查时执行

### 4.9 消息格式
```json
{
  "id": "msg-{YYYYMMDD}-{HHMMSS}-{来源}-{简要}",
  "timestamp": "{ISO 8601}",
  "from": "{来源}",
  "to": "{目标}",
  "priority": "high|normal|low",
  "type": "message|instruction|report|ack",
  "subject": "{标题}",
  "body": "{内容}",
  "reply_required": true|false,
  "ack_required": true,
  "reply_to": "{可选}"
}
```

---

## 五、脚本清单

```
scripts/
├── mail_write.sh       协议层：写邮件
├── mail_read.sh        协议层：读邮件
├── normal_send.sh      通信层：📧+💬
├── urgent_send.sh      通信层：📧+📞
├── notify-alpha.sh     通信层：通知阿尔法
├── send-to-dreamer.sh  通信层：飞书直发梦想家（自动查找open_id）
├── check-inbox.sh      通信层：查收件箱
└── check-acks.sh       通信层：查ack回执
```

---

## ⚠ 注意事项

- 不要自行修改本文件，修改需阿尔法批准
- 所有通信必须留痕
- 路径写错=消息丢失
