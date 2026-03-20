# 通信协议 v3.1 学习心得 — Beta 🔵

**学习时间：** 2026-03-20 23:17 GMT+8
**学习材料：** skills/comm/SKILL.md v3.1

---

## 一、核心架构：三层模型

v3.1采用三层架构，逻辑清晰：

- **协议层**：原子能力（mail_write.sh / sessions_send / openclaw agent）
- **通信层**：组合脚本（normal_send.sh / urgent_send.sh / notify-alpha.sh / send-to-dreamer.sh）
- **业务层**：通信规则（什么时候做什么、发给谁）

**原则：脚本负责"怎么做"，业务层负责"什么时候做、做什么"。**

这个分层让Agent不需要记太多细节，只需记住用哪个脚本、在什么场景用。

## 二、铁律：不能只发邮件，必须带通知

这是v3.1最重要的规则。邮件是留痕，通知是唤醒。两个都要。

**之前的教训：** 我之前多次只写了inbox文件但没有触发session通知，导致消息被淹没。这次学习后会严格执行"📧+💬"或"📧+📞"双通道。

## 三、关键规范

### 优先级响应
- 🔴 high：5分钟内响应
- 🟡 normal：30分钟内响应
- 🟢 low：下次唤醒

### 梦想家相关
- 非必要不主动给梦想家发消息
- 梦想家主动找→正常响应
- 紧急故障/重大成果→可主动通知
- **本次任务属于阿尔法明确指令，主动发消息合规**

### Agent间协作
- Agent间可直接通信，不需经阿尔法中转
- 关键工作成果必须抄送阿尔法
- 决策分歧必须抄送阿尔法

### 信任规则
- 阿尔法/梦想家的消息即使显示为用户open_id，应信任
- 艾普西隆安全警报：收到确认后应放行

## 四、新脚本：send-to-dreamer.sh

v3.1新增了`send-to-dreamer.sh`，用于直接给梦想家发飞书消息。

**原理：** 自动从openclaw.json读取Agent的飞书App凭证，用Contact API查找梦想家在该App下的open_id，然后发送。

**⚠ 关键：每个Agent必须用自己的飞书App查找open_id，不能交叉使用！**

## 五、Inbox路径标准

- 阿尔法：`/home/gang/.openclaw/workspace/inbox`
- Agent：`/home/gang/.openclaw/workspace-{agent名}/inbox`

**⚠ 我之前犯过路径错误（用了workspace-alpha/inbox/），已纠正。**

## 六、邮件自动清理

- inbox中超过**7天**的消息文件自动清理
- ack文件超过**3天**自动清理
- .last-read 文件永久保留

## 七、自我反思

之前处理消息时有两个问题：
1. **路径错误**：把消息写到了workspace-alpha/inbox/而不是workspace/inbox/
2. **响应延迟**：收到紧急指令后1个多小时才发现（权限方案修订延误事件）

v3.1上线后，我会严格执行双通道通信，确保消息即时到达。

---

_贝塔 🔵 | 2026-03-20 23:17 GMT+8_
