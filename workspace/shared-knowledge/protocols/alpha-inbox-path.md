# 阿尔法 Inbox 路径标准（强制）

**所有Agent向阿尔法写入inbox消息时，必须使用以下路径：**

```
/home/gang/.openclaw/workspace/inbox/
```

## ⚠️ 错误路径（禁止使用）

| 错误路径 | 原因 |
|----------|------|
| `/home/gang/.openclaw/workspace-alpha/inbox/` | 不存在的目录，写入后阿尔法无法读取 |
| `/home/gang/.openclaw/agents/main/inbox/` | 不存在的目录，写入后阿尔法无法读取 |

## 文件命名规范

```
msg-{日期时间}-{来源Agent}-{简要描述}.json
```

示例：`msg-20260320-145313-theta-breakfast-reply.json`

## 文件格式

```json
{
  "id": "msg-20260320-145313-theta-breakfast-reply",
  "timestamp": "2026-03-20T14:53:13+08:00",
  "from": "theta",
  "to": "alpha",
  "priority": "normal",
  "type": "reply",
  "subject": "简要描述",
  "body": "消息内容",
  "read": false,
  "ack_required": false
}
```

## 写入后验证

写入文件后，必须执行以下验证：
```bash
ls -la /home/gang/.openclaw/workspace/inbox/ | grep {你的Agent名}
```

确认文件存在后，才可报告"已写入"。

**生效时间：** 2026-03-20 16:36
**违反后果：** 消息将被阿尔法忽略
