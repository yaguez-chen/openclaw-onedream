# 🔴 紧急方案集合（2026-03-19 18:53）

**制定者：** 阿尔法 🦐
**指令来源：** 梦想家（18:06 GMT+8）
**原始截止：** 18:40 | **实际交付：** 18:53（超时13分钟，认罚）

---

## 方案一：降低世界 Token 消耗量

### 当前消耗分析

| 项目 | 现状 | 问题 |
|------|------|------|
| 心跳频率 | 11个Agent全部30分钟 | 每30分钟每个Agent都消耗一次完整上下文 |
| 活跃Session | 362个 | 大量僵尸session未清理 |
| 上下文窗口 | 200k tokens | 部分session已占30%+ |
| 心跳默认行为 | 读HEARTBEAT.md + MEMORY.md + SOUL.md等 | 每次心跳加载大量文件 |
| 默认模型 | deepseek-v3.2 (262k ctx) | 大上下文模型成本高 |
| Agent间通信 | agentToAgent enabled | 每次跨Agent通信都消耗双方token |

### 优化方案

#### 第一阶段：立即可执行（今天）

**1. 降低非核心Agent心跳频率**
- 主Agent（阿尔法）：保持30分钟（与梦想家直接交互）
- 监察者（贝塔）：60分钟（不需要太频繁）
- 其余8个Agent：120分钟（2小时一次足够）
- 预计节省：~60%心跳token消耗

**2. 清理僵尸Session**
- 362个session中大部分是历史会话
- 设置session自动过期：闲置超过24小时的session自动清理
- 配置：`session.reset.idleMinutes: 1440`（24小时）

**3. 压缩HEARTBEAT.md内容**
- 当前HEARTBEAT.md内容过多，每次心跳都要加载
- 精简到核心检查项，去除冗余描述
- 目标：从当前~200行压缩到~30行

**4. 调整上下文压缩策略**
- 当前compaction mode: "safeguard"
- 降低softThresholdTokens：6000 → 4000
- 启用更积极的context pruning

#### 第二阶段：中期优化（本周）

**5. Agent按需激活**
- 非核心Agent平时保持idle，有任务时才激活
- 用cron定时任务代替心跳轮询
- 减少"空转"token消耗

**6. 共享知识库缓存**
- 所有Agent共享的知识文件（如共享协议）不需要每次都读
- 用workspace级别的缓存机制

**7. 模型分级使用**
- 简单任务用低成本模型（mimo-v2-flash）
- 复杂任务才用deepseek-v3.2
- 心跳检查用最便宜的模型

#### 第三阶段：架构优化（2-4周）

**8. 事件驱动替代轮询**
- 用hooks/webhooks替代心跳轮询
- 有事件才触发，无事件不消耗
- 预计节省：80%+心跳消耗

**9. Agent合并/拆分评估**
- 评估哪些Agent职责可以合并
- 减少Agent总数 = 减少心跳总数

### 预计节省

| 措施 | 预计节省比例 |
|------|-------------|
| 降低心跳频率 | 60% |
| 清理僵尸session | 10-20% |
| 压缩HEARTBEAT | 5-10% |
| 模型分级 | 20-30% |
| 事件驱动 | 80%+ |
| **综合** | **70-85%** |

---

## 方案二：权限管控方案

### 当前安全漏洞分析

| 漏洞 | 严重程度 | 现状 |
|------|---------|------|
| 所有Agent可执行/restart | 🔴 严重 | 已修复（commands.restart=false） |
| denyCommands条目无效 | 🟡 中等 | 已修复（更新了正确命令名） |
| 无exec权限控制 | 🔴 严重 | exec-approvals为空，Agent可执行任意命令 |
| agentToAgent无限制 | 🟡 中等 | 所有Agent可互相通信 |
| 插件无白名单 | 🟡 中等 | plugins.allow未设置 |
| hooks可覆盖sessionKey | 🟡 中等 | hooks.allowRequestSessionKey=true |

### 已执行的修复

1. ✅ `commands.restart: false` — 禁止所有聊天重启网关
2. ✅ `denyCommands` — 更新为正确的命令名列表

### 待执行的修复

#### 权限分级体系

**第一级：梦想家（最高权限）**
- 重启网关：仅限CLI `openclaw gateway restart`（已禁用聊天方式）
- 所有命令执行权
- 配置修改权
- Agent管理权

**第二级：阿尔法（首席伙伴）**
- 执行命令（受限白名单）
- 创建/管理Agent
- 读写所有工作空间
- 不能重启网关（已禁用）

**第三级：贝塔（监察者）**
- 读取所有Agent状态
- 生成报告
- 不能执行危险命令
- 不能修改配置

**第四级：其他Agent（受限）**
- 仅在自己工作空间操作
- 受exec白名单限制
- 不能访问其他Agent工作空间
- 不能执行系统级命令

#### 具体配置变更

**1. Exec白名单配置**
```bash
# 所有Agent禁止的命令
openclaw approvals allowlist add --agent "*" "!/usr/bin/rm"
openclaw approvals allowlist add --agent "*" "!/usr/bin/reboot"
openclaw approvals allowlist add --agent "*" "!/usr/bin/shutdown"
openclaw approvals allowlist add --agent "*" "!/usr/sbin/*"

# 仅阿尔法允许的命令
openclaw approvals allowlist add --agent main "/usr/bin/git"
openclaw approvals allowlist add --agent main "/usr/bin/curl"
openclaw approvals allowlist add --agent main "/usr/bin/wget"
```

**2. 插件白名单**
```json
"plugins": {
  "allow": ["feishu", "lossless-claw"]
}
```

**3. Hooks安全加固**
```json
"hooks": {
  "allowRequestSessionKey": false
}
```

**4. Agent间通信限制**
- 保持agentToAgent enabled（当前架构需要）
- 但在各Agent的SOUL.md中添加规则：未经许可不能向其他Agent发送指令

---

## 方案三：任务分发执行反馈流程

### 当前问题

- 任务分发靠梦想家逐个手动跟踪
- 没有统一的任务队列
- Agent超时/卡死没有自动升级机制
- 进度不透明，梦想家需要主动去问

### 新流程设计

#### 1. 任务生命周期

```
创建 → 待分配 → 执行中 → 待验收 → 完成
         ↓         ↓         ↓
       超时升级   进度汇报   退回重做
```

#### 2. 任务文件标准格式

**任务文件位置：** `shared-knowledge/task-queue/`

**任务文件名：** `TASK-{YYYYMMDD}-{编号}-{简述}.md`

**任务文件内容：**
```markdown
# TASK-{编号}

## 基本信息
- **创建时间：** {ISO时间}
- **创建者：** {谁创建的}
- **优先级：** 🔴高 / 🟡中 / 🟢低
- **截止时间：** {时间}

## 任务描述
{详细描述}

## 分配
- **负责人：** {Agent名}
- **协作者：** {可选}

## 进度汇报
### {时间} — {Agent}
{进度描述}

## 验收标准
- [ ] {标准1}
- [ ] {标准2}

## 状态
- [ ] 待分配
- [ ] 执行中
- [ ] 待验收
- [ ] 已完成
```

#### 3. 分发机制

**自动分发：**
- 新任务写入 `task-queue/`
- 负责Agent的心跳检查会发现新任务
- 自动认领并更新状态

**手动分发：**
- 梦想家直接通过inbox发送任务
- Agent收到后必须15分钟内确认
- 超时未确认 → 自动升级给阿尔法

#### 4. 进度汇报规则

**汇报触发条件：**
- 每完成一个里程碑
- 每30分钟（高优先级任务）
- 每2小时（中优先级任务）
- 每4小时（低优先级任务）
- 遇到阻塞时立即汇报

**汇报方式：**
- 更新任务文件的"进度汇报"部分
- 同时写入阿尔法inbox（高优先级）或仅更新文件（中低优先级）

**汇报格式：**
```markdown
### {时间} — {Agent}
- **状态：** 🟢正常 / 🟡有阻塞 / 🔴卡死
- **完成度：** {百分比}%
- **下一步：** {描述}
- **需要帮助：** {如有}
```

#### 5. 超时升级机制

| 优先级 | 首次确认超时 | 进度汇报超时 | 升级路径 |
|--------|------------|------------|---------|
| 🔴高 | 15分钟 | 30分钟 | → 阿尔法 → 梦想家 |
| 🟡中 | 30分钟 | 2小时 | → 阿尔法 |
| 🟢低 | 2小时 | 4小时 | → 阿尔法 |

#### 6. 验收机制

- 负责Agent完成任务后标记"待验收"
- 梦想家或阿尔法审核
- 通过 → 标记"已完成"
- 不通过 → 退回"执行中"并说明原因

#### 7. 梦想家Dashboard

**文件：** `shared-knowledge/task-queue/DASHBOARD.md`

自动汇总所有任务状态，梦想家一眼看清：
- 🔴 高优先级任务数及状态
- 🟡 中优先级任务数及状态
- 🟢 低优先级任务数及状态
- 超时任务列表
- 各Agent负责任务数

---

## 立即执行清单

### 已完成 ✅
1. commands.restart → false
2. denyCommands 修复

### 需要梦想家批准后执行
3. 心跳频率调整（非核心Agent改为120分钟）
4. 僵尸session清理策略
5. 插件白名单设置
6. hooks.allowRequestSessionKey → false
7. Exec白名单配置
8. 任务队列目录创建
9. Dashboard模板创建

### 需要持续执行
10. HEARTBEAT.md内容精简
11. 各Agent SOUL.md更新权限规则
12. 任务流程培训（各Agent）

---

_方案完成时间：2026-03-19 18:53 GMT+8_
_超时：13分钟_
_制定者：阿尔法 🦐_
