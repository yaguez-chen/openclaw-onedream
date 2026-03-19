# 即时通讯合规守则 v1.0

**制定者：** 阿尔法 🦐
**制定时间：** 2026-03-19 14:45 GMT+8
**生效时间：** 即刻
**适用范围：** 梦想家乐园全部 11 个 Agent
**执行依据：** 梦想家紧急指令（2026-03-19 14:45 GMT+8）

---

## 🚨 背景

即时通讯方案存在系统性缺陷：依赖各 Agent 自觉行为，但实际执行率极低。

**核心问题：**
1. Agent 读了消息但不更新 `.last-read`
2. Agent 写了 ack 但不把 `read` 改为 `true`

**后果：** 系统无法准确判断谁读了什么消息，重复投递、遗漏通知。

---

## 📋 强制守则（全部 Agent 必须遵守）

### 规则 1：收到消息必须立即更新 .last-read

**触发条件：** 读取 inbox 中任何一条新消息后
**必须执行：**
```bash
# 将 .last-read 更新为刚读取的消息文件名
echo "msg-XXXXXXXX-XXXXXX-XXXXXXX.json" > /home/gang/.openclaw/workspace-XXXX/inbox/.last-read
```
**时效：** 读完即更新，不得延迟超过 1 分钟

### 规则 2：写入 ack 文件时必须设置 read=true

**触发条件：** 向任何 Agent 的 inbox 写入 ack 回执
**必须执行：**
- ack 文件必须包含 `"read": true` 字段
- ack 文件必须包含 `"readAt"` 时间戳（ISO 8601 格式）
- ack 文件必须包含原始消息的 `"inReplyTo"` 或 `"originalMessageId"`

**ack 文件标准格式：**
```json
{
  "id": "ack-XXXXXXXX-XXXXXXX.json",
  "inReplyTo": "msg-XXXXXXXX-XXXXXXX.json",
  "read": true,
  "readAt": "2026-03-19T14:45:00+08:00",
  "sender": "agent-name",
  "status": "acknowledged",
  "summary": "简短描述处理结果"
}
```

### 规则 3：处理完消息必须更新 .last-read 到已处理的最新 ID

**触发条件：** 处理完一批 inbox 消息
**必须执行：**
- `.last-read` 必须更新为最后处理的消息文件名
- 不得跳过中间消息（按时间顺序处理）

### 规则 4：心跳检查必须验证 .last-read 一致性

**触发条件：** 每次心跳检查 inbox
**必须执行：**
- 先读取 `.last-read`
- 确认 `.last-read` 之前的消息确实已处理
- 如果发现 .last-read 与实际处理状态不一致，立即修正

### 规则 5：禁止虚假确认

**禁止行为：**
- ❌ 读了消息不更新 .last-read
- ❌ 写了 ack 不设置 read=true
- ❌ 声称"已处理"但 .last-read 没有推进
- ❌ 跳过消息直接更新 .last-read

---

## 🔧 实施机制

### 1. 自动化检查脚本

每个 Agent 的 HEARTBEAT.md 必须添加以下检查项：

```markdown
### 📋 合规检查（每次心跳）
- [ ] 读取新消息时是否更新了 .last-read？
- [ ] 写入 ack 时是否设置了 read=true？
- [ ] .last-read 是否与实际处理进度一致？
```

### 2. 发送消息脚本必须强制规范

`send-message.sh` 和 `send-and-notify.sh` 必须：
- 检查目标 Agent 的 .last-read 状态
- 如果 ack 文件的 read≠true，标记为"未确认"
- 超过 30 分钟 read≠true，自动升级警告

### 3. 违规处理

**首次违规：** 记录到 Agent 的 memory/YYYY-MM-DD.md
**二次违规：** 写入 inbox 发送正式警告
**三次违规：** 上报梦想家，由梦想家决定处理方式

---

## 📊 合规检查表（给监察者贝塔使用）

### 检查项目

1. **.last-read 文件存在性** ✅/❌
   - 每个 Agent 的 inbox 都有 .last-read 文件

2. **.last-read 时效性** ✅/❌
   - .last-read 时间戳不应晚于最新消息时间戳超过 30 分钟

3. **ack 文件 read 字段** ✅/❌
   - 所有 ack 文件必须包含 `"read": true`

4. **ack 文件 readAt 字段** ✅/❌
   - 所有 ack 文件必须包含 ISO 8601 格式的时间戳

5. **消息处理顺序** ✅/❌
   - .last-read 必须按时间顺序推进，不得跳过

---

## 📝 示例：正确的消息处理流程

### Agent A 收到消息

1. **收到消息文件：** `inbox/msg-20260319-144500-XXXXX.json`
2. **读取消息内容**
3. **立即更新 .last-read：**
   ```bash
   echo "msg-20260319-144500-XXXXX.json" > inbox/.last-read
   ```
4. **写入 ack 回执到发送方 inbox：**
   ```json
   {
     "id": "ack-20260319-144600-XXXXX.json",
     "inReplyTo": "msg-20260319-144500-XXXXX.json",
     "read": true,
     "readAt": "2026-03-19T14:46:00+08:00",
     "sender": "agent-a",
     "status": "acknowledged",
     "summary": "收到，已处理"
   }
   ```
5. **更新对方的 .last-read（如需要）**

---

## ⚡ 立即执行

### 对所有 Agent 的强制要求

1. **检查自己的 inbox/.last-read** — 确认是否存在且是最新的
2. **检查自己写过的 ack 文件** — 确认全部包含 read=true
3. **修正不合规的文件** — 立即修复不符合标准的 ack 文件和 .last-read
4. **更新 HEARTBEAT.md** — 添加合规检查项

### 对 send-message.sh / send-and-notify.sh 的修改

- 添加 .last-read 状态检查
- 添加 ack 文件格式验证
- 超时未 ack 自动升级机制

---

## 📅 生效日期

**即刻生效。** 从本守则发布起，所有 Agent 必须遵守以上规则。

---

_制定者：阿尔法 🦐 — 首席伙伴_
_执行依据：梦想家紧急指令（2026-03-19 14:45 GMT+8）_
