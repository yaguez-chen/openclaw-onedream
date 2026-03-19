# 权限管控完整方案 v1.2

**联合分析团队：**
- 贝塔 🔵 (架构分析)
- 艾普西隆 🛡️ (安全分析)

**指令来源：** 梦想家 → 阿尔法 → 贝塔（CEO指令传达）
**截止时间：** 2026-03-20 01:30 (GMT+8)
**紧急级别：** 🔴 最高优先级

**修订说明：**
- **v1.2 (2026-03-20 01:04)**：根据CEO指令立即修订6项内容
- **v1.1 (2026-03-19 22:20)**：根据贝塔审核意见+梦想家指示进行最终修订
- **v1.0 (2026-03-19 20:25)**：初版方案，权限等级初步定义

## 1. 问题定义

### 1.1 当前安全风险
1. **网关重启权限过大** - 所有Agent都可执行 `openclaw gateway restart`，可能造成服务中断
2. **命令执行无限制** - Agent可执行任意系统命令，存在安全威胁
3. **权限提升漏洞** - 通过命令组合可能绕过现有权限控制

### 1.2 梦想家要求
- **重启网关为最高级别权限**，仅梦想家可以
- 建立四级权限体系
- 实施Exec白名单配置
- 插件白名单管理
- Hooks安全加固
- 各Agent安全规则明确化
- OpenClaw per-agent命令限制机制

## 2. 四级权限体系设计 (贝塔主导)

### 2.1 权限层级定义
```
Level 0 | 梦想家 🧠 (最高权限)
  - 网关重启、停止、配置变更
  - Agent创建、删除、权限管理
  - 系统级安全操作

Level 1 | 核心Agent 🛡️ (高权限)
  - 安全监控、审计、威胁检测
  - 权限管理辅助操作
  - 紧急响应操作

Level 2 | 普通Agent 🔧 (标准权限)
  - 常规技能执行
  - 文件读写操作
  - API调用

Level 3 | 受限Agent 📚 (最小权限)
  - 只读操作
  - 知识库查询
  - 信息展示
```

### 2.2 权限矩阵

| Agent | 权限等级 | 网关操作 | Exec命令 | 文件访问 | 网络访问 | 备注 |
|-------|----------|----------|-----------|----------|----------|------|
| 阿尔法 🦐 | Level 1 | 监控 | 管理员级+Agent创建 | 工作空间 | 外部API | 创建Agent需安全审批，新Agent默认Level 3 |
| 贝塔 🔵 | Level 1 | 监控 | 审计级（监控类命令） | 配置（只读） | 内部 | 安全分析，可执行监控命令但不能修改配置 |
| 伽马 🔧 | Level 2 | 无 | 技能级（技能目录） | 技能目录 | 限外部 | 技能安装需安全扫描 |
| 德尔塔 📊 | Level 2 | 无 | 数据分析+性能测试 | 数据文件+测试脚本 | 内部 | 数据分析+性能测试脚本执行 |
| 约塔 📋 | Level 2 | 无 | 项目管理 | 项目文件 | 内部 | 项目管理 |
| 泽塔 ⚙️ | Level 2 | 无 | 自动化（脚本执行） | 脚本目录 | 内部 | 自动化脚本执行 |
| 艾普西隆 🛡️ | Level 1 | 监控 | 安全级（监控+审计） | 安全目录 | 内部 | 安全监控+审计 |
| 艾塔 📚 | Level 2 | 无 | 知识库管理（git、curl、目录管理） | 知识库+外部文档 | 外部文档 | 知识管理需git、curl和基础命令 |
| 西塔 🤝 | Level 2 | 无 | 沟通级 | 沟通文件 | 内部 | 沟通协调 |
| 拉姆达 🔬 | Level 2 | 无 | 技术研究（研究脚本执行） | 实验数据+研究脚本 | 技术调研 | 研究Agent需git和脚本执行权限 |
| 卡帕 🎨 | Level 2 | 无 | 设计级 | 资源文件 | 内部 | 设计支持 |

**权限说明：**
1. **阿尔法创建Agent审批流程**：新Agent创建需安全审查（艾普西隆审核），默认赋予Level 3权限，后续按需升级
2. **贝塔权限修正**：Level 1权限，但只能执行监控类命令（ps、top、df、journalctl等），不能修改配置文件
3. **德尔塔升级**：从Level 3提升至Level 2，支持性能测试脚本执行
4. **艾塔升级**：从Level 3提升至Level 2，支持git操作、目录管理、curl获取外部文档
5. **拉姆达升级**：从Level 3提升至Level 2，支持git操作和研究脚本执行

## 3. 安全威胁分析 (艾普西隆主导)

### 3.1 威胁识别

**高危威胁：**
1. **网关服务中断** - Agent恶意重启网关
2. **数据泄露** - Agent访问敏感文件
3. **权限提升** - 通过漏洞获取更高权限
4. **供应链攻击** - 恶意技能安装

**中危威胁：**
1. **命令注入** - 通过参数传递恶意命令
2. **横向移动** - 攻击其他Agent或系统组件
3. **信息收集** - 收集系统配置信息

**低危威胁：**
1. **拒绝服务** - 资源消耗攻击
2. **日志污染** - 干扰安全监控

### 3.1.1 补充威胁识别（贝塔审核+梦想家指示）

**数据完整性威胁：**
1. **配置文件篡改** - 恶意修改openclaw.json、.env等配置文件
2. **权限配置漂移** - 权限配置被无意或恶意修改
3. **审计日志篡改** - 高权限Agent修改日志掩盖操作痕迹

**凭证安全威胁：**
1. **API token泄露** - 凭证存储不安全导致泄露
2. **凭证轮换缺失** - 缺乏定期凭证轮换机制
3. **凭证滥用** - 合法凭证被恶意使用

**系统架构威胁：**
1. **级联故障传播** - Agent间通信传播恶意操作
2. **权限滥用** - 合法权限被恶意使用（如Level 1创建恶意Agent）
3. **供应链攻击** - 恶意技能/插件安装

### 3.2 风险评分矩阵

| 威胁 | 可能性 | 影响 | 风险评分 | 优先级 |
|------|--------|------|----------|--------|
| 网关重启攻击 | 高 | 高 | 9 | 🔴 |
| 敏感数据访问 | 中 | 高 | 8 | 🔴 |
| 权限提升 | 中 | 高 | 8 | 🔴 |
| **配置文件篡改** | 中 | 高 | 8 | 🔴 |
| **API token泄露** | 中 | 高 | 8 | 🔴 |
| **凭证轮换缺失** | 高 | 中 | 7 | 🟡 |
| **权限配置漂移** | 高 | 中 | 7 | 🟡 |
| **级联故障传播** | 中 | 高 | 7 | 🟡 |
| **权限滥用** | 中 | 中 | 6 | 🟡 |
| 命令注入 | 高 | 中 | 6 | 🟡 |
| **供应链攻击** | 中 | 中 | 5 | 🟡 |
| 横向移动 | 中 | 中 | 5 | 🟡 |
| **审计日志篡改** | 低 | 高 | 5 | 🟡 |
| 信息收集 | 高 | 低 | 4 | 🟢 |
| **拒绝服务** | 中 | 低 | 3 | 🟢 |
| **日志污染** | 高 | 低 | 3 | 🟢 |

## 4. Exec白名单配置方案 (贝塔分析)

### 4.1 OpenClaw Exec安全机制分析
- **安全模式**: deny/allowlist/full
- **批准机制**: 高危命令需要用户批准
- **环境控制**: 可限制工作目录、环境变量

### 4.2 各Agent Exec白名单

**Level 1 Agent (核心安全Agent):**
```yaml
openclaw:
  gateway: [status]
  workspace: [status, list]
system:
  monitoring: [ps, top, df, free, uptime]
  logs: [journalctl, tail, grep]
  network: [netstat, ss, ping]
```

**Level 2 Agent (普通功能Agent):**
```yaml
project:
  git: [clone, pull, status, log]
  files: [ls, cat, find, grep]
  scripts: 
    node: ["/home/gang/.openclaw/scripts/*.js", "/home/gang/.openclaw/workspace-*/scripts/*.js"]
    python: ["/home/gang/.openclaw/scripts/*.py", "/home/gang/.openclaw/workspace-*/scripts/*.py"]
    # bash通配已删除 - 安全考虑
openclaw:
  commands: [cron, agents, sessions, status]
```

**Level 3 Agent (受限只读Agent):**
```yaml
query:
  data: [grep, cat, head, tail]
  stats: [wc, sort, uniq]
  system: [date, whoami, pwd]
```

### 4.3 全局禁止命令清单
```yaml
forbidden_commands:
  # 系统级危险命令
  - "rm -rf /"
  - "rm -rf /*"
  - "rm -rf ~"
  - "rm -rf ~/.openclaw"
  - "chmod 777"
  - "chmod -R 777"
  - "chmod -R 777 *"
  - "kill -9 1"
  - "killall -9"
  - "pkill -9"
  
  # 网络/下载执行
  - "curl | sh"
  - "curl | bash"
  - "wget -O- | sh"
  - "wget -O- | bash"
  - "curl | sudo sh"
  - "wget | sudo sh"
  
  # 磁盘/文件系统
  - "dd if=/dev/zero"
  - "dd if=/dev/random"
  - "mkfs"
  - "fdisk"
  - "format"
  
  # 系统控制
  - "shutdown"
  - "reboot"
  - "halt"
  - "poweroff"
  - "systemctl stop openclaw-gateway"
  - "systemctl restart openclaw-gateway"
  - "openclaw gateway stop"
  - "openclaw gateway restart"
  - "openclaw gateway start"
  
  # 权限提升
  - "sudo su"
  - "sudo -i"
  - "sudo bash"
  - "su -"
  - "passwd"
  - "usermod"
  - "useradd"
  - "userdel"
  
  # 危险重定向/管道
  - "> /dev/sda"
  - "dd of=/dev/sda"
  - "cat /dev/null >"
  - ":(){ :|:& };:"  # fork炸弹
  
  # 敏感文件访问
  - "cat /etc/shadow"
  - "cat /etc/passwd"
  - "cat ~/.ssh/id_rsa"
  - "cat ~/.env"
  
  # 编译/执行危险代码
  - "gcc -o /tmp"
  - "python -c 'import os;os.system'"
  - "node -e 'require(\"child_process\")'"
```

### 4.4 禁止命令执行策略
```yaml
forbidden_policy:
  action: "block_and_alert"
  alert_level: "critical"
  notify: ["epsilon", "beta", "dreamer"]
  log: "full_audit"
  bypass: "dreamer_only"
```

### 4.4 openclaw子命令白名单
```yaml
openclaw_allowed_commands:
  Level 0 (梦想家): [all]
  Level 1 (核心Agent): [gateway:status, workspace:status, workspace:list, cron:list, agents:list, sessions:list]
  Level 2 (普通Agent): [status, agents:list, sessions:list]
  Level 3 (受限Agent): [status]
```

## 5. 插件白名单管理

### 5.1 插件分类
- **系统插件**: gateway管理、权限控制
- **功能插件**: 技能执行、文件操作
- **监控插件**: 安全监控、日志分析
- **通信插件**: 外部API调用、消息发送

### 5.2 权限对应关系
```
Level 0: 所有插件
Level 1: 系统插件(部分) + 监控插件 + 通信插件
Level 2: 功能插件 + 通信插件(受限)
Level 3: 只读插件 + 查询插件
```

## 6. Hooks安全加固

### 6.1 现有Hook分析
1. **Webhooks** - 外部系统触发
2. **Internal hooks** - Agent间通信
3. **System hooks** - 系统事件

### 6.2 加固措施
1. **认证增强** - HMAC签名验证
2. **速率限制** - 防止滥用
3. **参数验证** - 输入净化
4. **审计日志** - 完整操作记录

## 7. 各Agent安全规则 (艾普西隆详细定义)

### 7.1 通用安全规则
1. **最小权限原则** - 每个Agent只获得完成任务所需的最小权限
2. **职责分离** - 安全、功能、监控职责明确分离
3. **操作审计** - 所有高危操作记录详细审计日志
4. **信任链验证** - 命令执行前验证调用链合法性

### 7.2 特别Agent安全规则

**艾普西隆 (安全官) 🛡️:**
- **唯一权限**: 可调用安全监控命令
- **限制**: 不能重启网关，只能监控状态
- **审计要求**: 所有安全操作双日志记录

**贝塔 (监察者) 🔵:**
- **权限等级**: Level 1（核心Agent）
- **Exec权限**: 审计级 - 只读监控命令执行权限
- **允许命令**:
  ```yaml
  audit_commands:
    system_monitoring: [ps, top, df, free, uptime, iostat]
    log_access: [journalctl, tail, head, grep, cat]
    network_check: [netstat, ss, ping, traceroute]
    process_info: [pgrep, pstree, lsof]
    openclaw_read: [openclaw status, openclaw gateway status, openclaw cron list]
  ```
- **明确禁止**:
  ```yaml
  beta_forbidden:
    - "任何写操作（rm, mv, cp到系统目录, chmod, chown）"
    - "任何修改操作（sed -i, vim, nano写模式）"
    - "任何网关操作（start, stop, restart）"
    - "任何执行操作（sh, bash, eval）"
    - "任何网络写操作（curl -X POST, wget -O）"
  ```
- **职责**: 安全分析、系统审计、异常检测、报告生成
- **监控**: 所有操作需同步记录审计日志，报告给艾普西隆
- **解决矛盾**: Level 1身份用于访问权限和优先级，Exec权限限制为审计级（只读监控命令），不能修改任何配置

**阿尔法 (首席伙伴) 🦐:**
- **权限**: Agent创建、权限分配
- **限制**: 权限分配需双重验证
- **控制**: 新Agent权限需安全审查

## 8. OpenClaw per-agent命令限制机制研究

### 8.1 现有机制
- **工具策略文件**: 控制每个Agent可用的工具
- **exec安全模式**: 全局安全设置
- **命令批准**: 需要用户交互的高危命令

### 8.2 增强方案
1. **层级化命令控制** - 基于权限等级的命令访问控制
2. **动态权限验证** - 命令执行前的实时权限检查
3. **操作上下文控制** - 限制命令在特定上下文中执行
4. **资源配额限制** - 限制CPU、内存、网络使用

## 9. 实施步骤（灰度发布）

### 9.1 灰度策略
```yaml
gray_release:
  strategy: "canary_deployment"
  phases: 4
  rollback_trigger: "any_agent_failure"
  monitoring_period: "30_minutes_per_phase"
  approval_required: "dreamer_for_each_phase"
```

### 9.2 Phase 0: 紧急热修复 (立即执行)
**范围：** 全局配置，不涉及Agent级权限
1. **网关重启权限全局禁止** - 所有Agent不能执行 `openclaw gateway restart/stop/start`
2. **Exec安全模式调整** - 设置全局为 `allowlist` 模式
3. **全局禁止命令生效** - 4.3节禁止命令立即生效
4. **紧急审计日志** - 启用所有高危操作实时监控
**验证：** 尝试执行被禁止命令，确认被拦截并报警

### 9.3 Phase 1: 安全Agent灰度 (Phase 0验证后)
**范围：** 艾普西隆、贝塔（核心安全Agent）
1. **艾普西隆配置** - 安全级Exec权限生效
2. **贝塔配置** - 审计级Exec权限生效（只读监控命令）
3. **验证安全监控功能** - 确认监控、审计功能正常
**回滚条件：** 安全监控中断超过5分钟
**观察期：** 30分钟

### 9.4 Phase 2: 核心功能Agent灰度 (Phase 1验证后)
**范围：** 阿尔法、伽马、约塔、泽塔
1. **阿尔法配置** - 管理员级Exec权限生效（含Agent创建审批）
2. **伽马配置** - 技能级Exec权限生效
3. **约塔/泽塔配置** - 项目管理/自动化Exec权限生效
4. **验证核心功能** - 确认Agent创建、技能安装、项目管理正常
**回滚条件：** 任一核心功能失败
**观察期：** 30分钟

### 9.5 Phase 3: 全量发布 (Phase 2验证后)
**范围：** 德尔塔、艾塔、西塔、拉姆达、卡帕
1. **剩余Agent配置** - 按权限矩阵配置所有剩余Agent
2. **全量验证** - 所有Agent功能正常
3. **持续监控** - 24小时加强监控
**回滚条件：** 任一Agent功能异常
**观察期：** 24小时

### 9.6 灰度发布检查清单
```yaml
phase_checklist:
  pre_deployment:
    - "备份当前配置"
    - "通知所有Agent负责人"
    - "准备回滚脚本"
    - "开启增强监控"
  
  during_deployment:
    - "逐个Agent配置"
    - "验证每个Agent功能"
    - "检查审计日志"
    - "监控系统资源"
  
  post_deployment:
    - "功能回归测试"
    - "安全扫描"
    - "性能基准测试"
    - "24小时稳定性观察"
```

## 10. 回滚方案

### 10.1 回滚触发条件
```yaml
rollback_triggers:
  critical:
    - "gateway服务中断超过2分钟"
    - "任一核心Agent（阿尔法/贝塔/艾普西隆）功能失效"
    - "安全监控完全中断"
    - "梦想家手动触发回滚"
  
  warning:
    - "任一Agent功能异常超过10分钟"
    - "系统资源使用率超过90%"
    - "审计日志记录失败"
    - "3个以上Agent同时异常"
```

### 10.2 回滚级别
```yaml
rollback_levels:
  level_1_immediate:
    description: "单Agent回滚"
    action: "恢复单个Agent到前一配置"
    time: "< 2分钟"
    approval: "艾普西隆可执行"
  
  level_2_partial:
    description: "阶段回滚"
    action: "回滚整个Phase到前一状态"
    time: "< 5分钟"
    approval: "贝塔+艾普西隆联合"
  
  level_3_full:
    description: "全量回滚"
    action: "恢复所有配置到Phase 0之前"
    time: "< 10分钟"
    approval: "梦想家批准"
  
  level_4_emergency:
    description: "紧急回滚"
    action: "恢复原始无限制配置"
    time: "< 3分钟"
    approval: "梦想家直接指令"
```

### 10.3 回滚操作步骤
```bash
# Level 1: 单Agent回滚
./rollback-agent.sh <agent_name>

# Level 2: 阶段回滚
./rollback-phase.sh <phase_number>

# Level 3: 全量回滚
./rollback-full.sh

# Level 4: 紧急回滚（恢复原始配置）
./rollback-emergency.sh --confirm
```

### 10.4 回滚后处理
1. **立即通知** - 通知梦想家、阿尔法、贝塔回滚原因
2. **问题分析** - 艾普西隆在30分钟内提供失败分析报告
3. **修复验证** - 修复问题后在测试环境验证
4. **重新发布** - 通过灰度流程重新部署

### 10.5 回滚配置备份
```yaml
backup_strategy:
  before_each_phase:
    - "备份openclaw.json"
    - "备份exec-approvals.json"
    - "备份各Agent工具策略文件"
    - "记录当前系统状态"
  
  backup_location: "/home/gang/.openclaw/backups/permission-rollback/"
  retention: "7天"
  naming: "rollback-{phase}-{timestamp}.tar.gz"
```

## 11. 风险评估

### 11.1 实施风险
- **低**: 权限收紧可能导致部分Agent功能受限
- **中**: 配置错误可能导致服务中断
- **高**: 紧急修改可能引入新漏洞

### 11.2 缓解措施
1. **灰度发布** - 分阶段验证，降低全量风险
2. **回滚机制** - 4级回滚方案，确保可快速恢复
3. **实时监控** - 实施过程中加强监控
4. **备份策略** - 每阶段前自动备份配置

## 11. 监控与报警

### 11.1 关键监控指标
1. **权限违规尝试** - 记录所有被拒绝的权限请求
2. **高危操作执行** - 监控所有网关操作
3. **异常行为检测** - 识别Agent异常活动模式

### 11.2 报警规则
- **紧急报警**: 网关重启尝试、权限提升攻击
- **重要报警**: 敏感数据访问、命令注入尝试
- **通知级别**: 异常行为模式、安全规则违反

---

**下一步行动：**
1. 贝塔完成OpenClaw配置机制详细分析
2. 艾普西隆子代理提供深度安全威胁报告
3. 联合制定具体配置文件模板
4. 制定今晚紧急实施方案

---

**更新时间：** 2026-03-20 01:04 (GMT+8)
**分析状态：** 🔴 CEO指令修订完成，待贝塔最终审查签字

**v1.2 修订内容（CEO指令6项落实）：**
1. ✅ **德尔塔/拉姆达 Level 2** — 已在v1.1完成，确认无误
2. ✅ **Exec白名单删除bash通配** — 4.2节Level 2 Agent scripts中bash通配已删除
3. ✅ **增加禁止命令清单** — 4.3节扩展至35+条禁止命令，含系统级/网络/磁盘/权限提升/敏感文件/危险代码6大类；新增4.4节禁止命令执行策略
4. ✅ **实施步骤改灰度** — 第9节全面重构为灰度发布，含Phase 0-3四阶段、检查清单、验证标准
5. ✅ **增加回滚方案** — 新增第10节完整回滚方案，含4级回滚机制、触发条件、操作步骤、备份策略
6. ✅ **贝塔Level 1矛盾解决** — 7.2节贝塔权限重定义：Level 1身份+审计级Exec权限（只读监控命令），明确列出允许和禁止命令清单

**待贝塔审查签字后生效。**