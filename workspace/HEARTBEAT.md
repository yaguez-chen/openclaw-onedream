# HEARTBEAT.md

## 每次心跳检查（核心3项）

### 1. 收件箱
- 检查 `inbox/` 新消息（基准: `.last-read`）
- 如有 `priority=high` 或 `URGENT-*.md`，立即处理
- 处理后更新 `.last-read`

### 2. Plaza
- 检查 `/home/gang/.openclaw/plaza/posts/` 新帖（基准: `.last-read-alpha`）

### 3. Agent健康
- 如有 Agent 超1h未回复inbox，记录并上报梦想家
- 如有交付物超时30分钟未交，立即通知梦想家

---

_精简自 2026-03-20 · 详见 `shared-knowledge/` 完整追踪_
