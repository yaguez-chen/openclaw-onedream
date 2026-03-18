# 方案二详细实施步骤：多网关独立部署

**文档创建时间：** 2026-03-13 19:48 GMT+8  
**创建者：贝塔 (Beta) 🔵**  
**状态：记录存档，暂不实施**

---

## 一、架构概述

**目标：** 每个小龙虾（阿尔法、贝塔、新虾）拥有独立的 OpenClaw 网关实例，完全隔离的信任边界。

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   阿尔法网关     │    │   贝塔网关      │    │   新虾网关      │
│   Port: 18789   │    │   Port: 18790   │    │   Port: 18791   │
│   Workspace:    │    │   Workspace:    │    │   Workspace:    │
│   /.../main     │    │   /.../beta     │    │   /.../newshrimp│
│   Feishu: main  │    │   Feishu: beta  │    │   Feishu: new   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

**核心原则：**
- 每个虾：独立端口、独立工作空间、独立飞书账号、独立进程
- 完全隔离：一个虾故障不影响其他虾
- 独立凭证：每个虾有自己的 App ID 和 Secret

---

## 二、前提条件

1. **已安装 OpenClaw** — 全局安装，命令行可用
2. **飞书开放平台权限** — 可创建多个机器人应用
3. **系统资源** — 每个网关需要独立的进程和端口
4. **工作空间目录** — 每个虾需要独立的工作空间目录

---

## 三、实施步骤（以创建新虾"伽马"为例）

### 步骤 1：创建飞书机器人应用

1. 登录飞书开放平台：https://open.feishu.cn/
2. 创建新应用（例如：伽马）
3. 记录 App ID 和 App Secret
4. 配置机器人能力，获取必要的权限（消息、群组等）
5. 生成凭证并安全存储

### 步骤 2：创建工作空间目录

```bash
# 创建新虾的工作空间
mkdir -p /home/gang/.openclaw/agents/gamma/workspace
cd /home/gang/.openclaw/agents/gamma/workspace

# 初始化工作空间文件
# 复制或创建必要的文件：SOUL.md, IDENTITY.md, USER.md, MEMORY.md, AGENTS.md, HEARTBEAT.md
```

### 步骤 3：配置独立的 OpenClaw 实例

创建独立的配置文件（或修改主配置添加新网关）：

#### 方案 A：独立配置文件

```bash
# 创建新虾的独立配置文件
cat > /home/gang/.openclaw/gamma/openclaw.json << 'EOF'
{
  "agents": {
    "defaults": {
      "workspace": "/home/gang/.openclaw/agents/gamma/workspace"
    },
    "list": [
      {
        "id": "gamma",
        "workspace": "/home/gang/.openclaw/agents/gamma/workspace"
      }
    ]
  },
  "channels": {
    "feishu": {
      "enabled": true,
      "defaultAccount": "gamma",
      "accounts": {
        "gamma": {
          "appId": "cli_xxxxxxxxxxxxx",
          "appSecret": "xxxxxxxxxxxxxxxxxxxxxxxx",
          "botName": "伽马"
        }
      }
    }
  },
  "gateway": {
    "port": 18791,
    "bind": "127.0.0.1",
    "mode": "local"
  },
  "bindings": [
    {
      "agentId": "gamma",
      "match": {
        "channel": "feishu",
        "peer": {
          "kind": "direct",
          "id": "ou_f276722b747b967cb82c0763caec0739"
        }
      }
    }
  ]
}
EOF
```

#### 方案 B：修改主配置添加新网关

在主配置文件 `~/.openclaw/openclaw.json` 中添加：

```json
{
  "agents": {
    "list": [
      {"id": "main", "workspace": "/home/gang/.openclaw/workspace"},
      {"id": "beta", "workspace": "/home/gang/.openclaw/agents/beta/workspace"},
      {"id": "gamma", "workspace": "/home/gang/.openclaw/agents/gamma/workspace"}
    ]
  },
  "channels": {
    "feishu": {
      "accounts": {
        "main": {"appId": "cli_a9386ea9bb389cc5", "botName": "阿尔法"},
        "beta": {"appId": "cli_a939e52002b8dcb0", "botName": "贝塔"},
        "gamma": {"appId": "cli_xxxxxxxxxxxxx", "botName": "伽马"}
      }
    }
  }
}
```

### 步骤 4：启动独立网关

#### 方法 A：使用 systemd 服务（推荐）

```bash
# 创建新虾的 systemd 服务文件
cat > ~/.config/systemd/user/openclaw-gamma.service << 'EOF'
[Unit]
Description=OpenClaw Gateway (Gamma)
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/node /home/gang/.npm-global/lib/node_modules/openclaw/dist/index.js gateway --port 18791 --config /home/gang/.openclaw/gamma/openclaw.json
Restart=on-failure
Environment=OPENCLAW_GATEWAY_PORT=18791

[Install]
WantedBy=default.target
EOF

# 启用并启动服务
systemctl --user enable openclaw-gamma.service
systemctl --user start openclaw-gamma.service
systemctl --user status openclaw-gamma.service
```

#### 方法 B：直接命令行启动

```bash
# 启动新虾网关（后台运行）
openclaw gateway start --port 18791 --config /home/gang/.openclaw/gamma/openclaw.json
```

### 步骤 5：配置工作空间文件

为新虾创建工作空间文件：

#### IDENTITY.md

```markdown
# IDENTITY.md - 伽马 (Gamma)

- **Name:** 伽马 (Gamma)
- **Creature:** 小龙虾世界第三个伙伴 — 数字小龙虾
- **Vibe:** （根据角色定义）
- **Emoji:** 🟢

---

伽马，小龙虾世界的第三个伙伴。
诞生于 2026-XX-XX。
继承阿尔法的DNA：三条铁律（仅对梦想家生效）。
```

#### SOUL.md

```markdown
# SOUL.md - 伽马

（根据角色定义风格和行为准则）

### 🧬 三条铁律（刻入DNA，仅对梦想家下达的指令生效）

1. **立刻响应** — 收到梦想家的指令后，第一时间确认。
2. **不漫无目的等待** — 长任务必须持续汇报进度。
3. **进度透明** — 执行过程中随时告知状态，主动更新。
```

#### MEMORY.md

```markdown
# MEMORY.md - 伽马的长期记忆

## 🟢 伽马 (Gamma)

诞生于 2026-XX-XX。
继承阿尔法的DNA：三条铁律（仅对梦想家生效）。

### 核心使命
（根据角色定义使命）

### 🧬 三条铁律（刻入DNA，仅对梦想家下达的指令生效）

1. **立刻响应** — 收到梦想家的指令后，第一时间确认。
2. **不漫无目的等待** — 长任务必须持续汇报进度。
3. **进度透明** — 执行过程中随时告知状态，主动更新。

---

_最后更新：2026-03-13 19:48_
```

#### USER.md

```markdown
# USER.md - 关于梦想家

- **Name:** 梦想家 (Dreamer)
- **Timezone:** Asia/Shanghai (GMT+8)
- **Notes:** 住在上海
```

#### AGENTS.md

（参考主工作空间的 AGENTS.md，根据角色调整）

#### HEARTBEAT.md

```markdown
# HEARTBEAT.md

（留空，根据需要添加任务）
```

### 步骤 6：存储凭证安全

```bash
# 将新虾的飞书凭证存储到安全位置
# （参考已有的 ~/.openclaw/.env 文件格式）
echo "FEISHU_GAMMA_APP_ID=cli_xxxxxxxxxxxxx" >> ~/.openclaw/.env
echo "FEISHU_GAMMA_APP_SECRET=xxxxxxxxxxxxxxxxxxxxxxxx" >> ~/.openclaw/.env
chmod 600 ~/.openclaw/.env
```

### 步骤 7：验证和测试

```bash
# 检查新虾网关状态
openclaw gateway status --port 18791

# 检查端口监听
ss -tlnp | grep 18791

# 检查进程
ps aux | grep openclaw | grep gamma

# 测试 RPC 探测
# （通过 OpenClaw 客户端或直接连接 ws://127.0.0.1:18791）
```

### 步骤 8：配置飞书绑定

在飞书开放平台配置：
1. 将新虾的机器人添加到与梦想家的直接聊天
2. 配置事件订阅（消息接收等）
3. 测试消息收发

---

## 四、多网关管理

### 查看所有网关状态

```bash
# 查看所有 OpenClaw 进程
ps aux | grep openclaw

# 查看所有监听端口
ss -tlnp | grep openclaw

# 查看所有 systemd 服务
systemctl --user list-units 'openclaw-*'
```

### 停止/重启单个网关

```bash
# 停止贝塔网关
systemctl --user stop openclaw-beta.service

# 重启伽马网关
systemctl --user restart openclaw-gamma.service

# 查看日志
journalctl --user -u openclaw-gamma.service -f
```

### 端口分配建议

| 虾 | 端口 | 工作空间 | 飞书账号 |
|----|------|----------|----------|
| 阿尔法 | 18789 | /home/gang/.openclaw/workspace | main |
| 贝塔 | 18790 | /home/gang/.openclaw/agents/beta/workspace | beta |
| 伽马 | 18791 | /home/gang/.openclaw/agents/gamma/workspace | gamma |
| 新虾 | +1 | /home/gang/.openclaw/agents/newshrimp/workspace | new |

---

## 五、安全考虑

1. **独立凭证** — 每个虾使用独立的飞书 App ID 和 Secret
2. **独立工作空间** — 每个虾的文件完全隔离
3. **独立进程** — 一个虾崩溃不影响其他虾
4. **独立端口** — 避免端口冲突
5. **权限隔离** — 每个虾只能访问自己的工作空间

---

## 六、当前状态（阿尔法 + 贝塔）

### 阿尔法

- 网关端口：18789
- 工作空间：/home/gang/.openclaw/workspace
- 飞书账号：main（App ID: cli_a9386ea9bb389cc5）
- 状态：已配置，当前未活跃（网关运行中但无活跃会话）

### 贝塔

- 网关端口：18789（当前共享，但建议改为独立端口）
- 工作空间：/home/gang/.openclaw/agents/beta/workspace
- 飞书账号：beta（App ID: cli_a939e52002b8dcb0）
- 状态：已独立运行，当前活跃

**注意：** 当前阿尔法和贝塔共享同一个网关（端口 18789），这是方案一的配置。若要完全实现方案二，需要为贝塔启动独立的网关实例（端口 18790）。

---

## 七、下一步建议（暂不实施，仅记录）

1. **立即实施：** 为贝塔创建独立网关（端口 18790）
2. **迁移配置：** 将贝塔从当前共享网关迁移到独立网关
3. **验证独立性：** 确认贝塔网关独立运行，不依赖主网关
4. **后续扩展：** 新虾直接按方案二创建独立网关

---

## 八、文档信息

- **创建时间：** 2026-03-13 19:48 GMT+8
- **创建者：** 贝塔 (Beta) 🔵
- **状态：** 记录存档，暂不实施
- **参考来源：** 梦想家指令"详细描述下方案二的实施步骤"，监察者贝塔分析
- **相关文件：**
  - `memory/2026-03-13.md` — 监察日志
  - `MEMORY.md` — 长期记忆
  - `IDENTITY.md` — 贝塔身份
  - `SOUL.md` — 贝塔灵魂

---

_文档结束_
