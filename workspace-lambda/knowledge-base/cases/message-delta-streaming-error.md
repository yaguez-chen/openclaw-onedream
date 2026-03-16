# 案例：`message_delta before message_start` 流式错误

> 研究日期：2026-03-16 · 研究者：拉姆达 🔬 · 优先级：🔴 高

## 错误摘要

**症状：** 梦想家世界频繁出现 `"Unexpected event order, got message_delta before "message_start""` 错误，导致 agent 对话中断。

**受影响 Agent：** 阿尔法（3次连续）、贝塔（1次）、泽塔（1次）

**环境：**
- OpenClaw: 2026.3.11 (29dc654)
- Anthropic SDK: 0.73.0
- 模型: xiaomi/mimo-claw-0301
- API: anthropic-messages

## 根因分析

### 1. 错误来源

**文件：** `@anthropic-ai/sdk/lib/MessageStream.js`（行 434-443）

**源代码（TypeScript）：** `@anthropic-ai/sdk/src/lib/MessageStream.ts`（行 558-570）

### 2. 错误触发逻辑

```
#accumulateMessage(event) {
  snapshot = this.#currentMessageSnapshot
  
  // 分支1：message_start 是合法的首事件
  if (event.type === 'message_start') {
    if (snapshot) throw "got message_start before message_stop"  // 重复 message_start
    return event.message;  // 初始化 snapshot
  }
  
  // 分支2：其他事件必须在 message_start 之后
  if (!snapshot) {
    // ← 这里抛出错误！
    throw "got ${event.type} before message_start"
  }
  
  // 分支3：正常处理各事件类型
  switch (event.type) { ... }
}
```

### 3. 正常事件顺序（Anthropic SSE 协议）

```
message_start          ← 初始化 snapshot
content_block_start    ← 内容块开始
content_block_delta    ← 内容增量（可重复）
content_block_stop     ← 内容块结束
message_delta          ← 消息元数据（stop_reason, usage）
message_stop           ← 消息结束
```

### 4. 异常场景（网络抖动）

```
message_delta          ← ❌ 到达时 snapshot 为 null → 抛出异常！
message_start          ← 被丢弃（流已中断）
```

**触发原因：** 间歇性网络抖动或 API 代理响应延迟，导致 SSE 事件流在传输过程中顺序错乱。由于小米 API 通过代理转发到 Anthropic 格式，中间网络层可能引入时序不确定性。

### 5. 错误传播链

```
API 响应（事件乱序）
  ↓
MessageStream.#accumulateMessage()
  ↓ 抛出 AnthropicError
Stream iterator 中断
  ↓ 被 catch 捕获
pi-ai provider: stopReason = "error", errorMessage = "..."
  ↓
OpenClaw: 对话中断，用户看到错误
```

## 解决方案

### 方案 A：SDK 层事件缓冲重排（推荐 ⭐）

**原理：** 在 `#accumulateMessage` 中缓冲乱序事件，等 `message_start` 到达后重放。

**优点：** 根治问题，不丢请求，透明恢复
**缺点：** 修改 SDK 代码，npm 更新后需重新 patch

**补丁位置：** `@anthropic-ai/sdk/lib/MessageStream.js`

```javascript
// 在 MessageStream 构造函数中添加：
_MessageStream_pendingEvents = [];

// 修改 _MessageStream_accumulateMessage：
_MessageStream_accumulateMessage = function(event) {
    let snapshot = tslib_1.__classPrivateFieldGet(this, _MessageStream_currentMessageSnapshot, "f");
    
    if (event.type === 'message_start') {
        if (snapshot) {
            throw new error_1.AnthropicError(`Unexpected event order...`);
        }
        let result = event.message;
        // message_start 到达，重放缓冲的事件
        const pending = tslib_1.__classPrivateFieldGet(this, _MessageStream_pendingEvents, "f");
        tslib_1.__classPrivateFieldSet(this, _MessageStream_pendingEvents, [], "f");
        for (const pendingEvent of pending) {
            result = tslib_1.__classPrivateFieldGet(this, _MessageStream_instances, "m", _MessageStream_accumulateMessage)
                .call(this, pendingEvent);
        }
        return result;
    }
    
    if (!snapshot) {
        // 不抛异常，缓冲事件等待 message_start
        tslib_1.__classPrivateFieldGet(this, _MessageStream_pendingEvents, "f").push(event);
        return { content: [], usage: {} };  // 返回空 snapshot 占位
    }
    
    // ... 原有 switch 逻辑不变
}
```

### 方案 B：pi-ai 层重试机制

**原理：** 在 pi-ai provider 的 `for await` 循环外层捕获特定错误并重试。

**优点：** 不改 SDK，逻辑清晰
**缺点：** 重试有额外 API 调用成本

**实现位置：** `@mariozechner/pi-ai/dist/providers/anthropic.js`

```javascript
// 在 stream 函数中包装 try-catch
const MAX_RETRIES = 2;
let retryCount = 0;

while (retryCount <= MAX_RETRIES) {
    try {
        const anthropicStream = client.messages.stream({...params, stream: true}, {signal});
        for await (const event of anthropicStream) {
            // ... 现有事件处理逻辑
        }
        break;  // 成功，退出重试循环
    } catch (error) {
        if (error.message.includes('before "message_start"') && retryCount < MAX_RETRIES) {
            retryCount++;
            console.warn(`Stream event order error, retrying (${retryCount}/${MAX_RETRIES})...`);
            continue;  // 重试
        }
        throw error;  // 非顺序错误或重试耗尽，抛出
    }
}
```

### 方案 C：OpenClaw 层降级处理

**原理：** 在 OpenClaw 的流式处理层捕获错误，自动重建请求。

**优点：** 最上层处理，不影响下层
**缺点：** 需要了解 OpenClaw 内部流式处理逻辑

### 方案 D：等待上游修复

**原理：** 向 Anthropic SDK 提 issue，等待官方修复。

**优点：** 无需改动
**缺点：** 时间不可控

## 推荐执行方案

**短期（立即可用）：** 方案 A — SDK 层补丁
- 用 `patch-package` 或直接修改 `MessageStream.js`
- 最快解决问题

**中期（更稳定）：** 方案 A + B 组合
- SDK 补丁防止抛异常
- pi-ai 重试作为兜底

**长期：** 方案 D — 推动上游修复

## 执行计划

1. ✅ 分析根因（已完成）
2. ⏳ 实施 SDK 补丁（方案 A）
3. ⏳ 添加重试兜底（方案 B）
4. ⏳ 测试验证
5. ⏳ 向梦想家汇报

## 参考

- Anthropic SDK MessageStream.ts: `@anthropic-ai/sdk/src/lib/MessageStream.ts` L558-570
- 编译版 MessageStream.js: `@anthropic-ai/sdk/lib/MessageStream.js` L434-443
- pi-ai provider: `@mariozechner/pi-ai/dist/providers/anthropic.js` L140-340
