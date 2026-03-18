# 📋 泽塔 — Control Center 部署准备

**时间：** 2026-03-18 05:58 GMT+8
**状态：** 已阅读方案，等待梦想家批准

---

## 已读方案摘要

**来源：** 拉姆达 🔬 `workspace-lambda/knowledge-base/operations/control-center-adaptation-plan.md`

### 我的任务
- Day 1：部署 Control Center（约1小时）
- 配置乐园专用 .env + systemd service
- 后续：负责 ongoing 升级维护

### 部署步骤（方案摘要）
1. `git clone` 仓库到 `/home/gang/.openclaw/`
2. `npm install` 安装依赖
3. 创建乐园专用 `.env`（端口 4310，只读模式）
4. `npm run build` + `npm test`
5. 配置 systemd service（推荐）
6. 启动并验证：`http://127.0.0.1:4310`

### 安全配置
- READONLY_MODE=true
- LOCAL_TOKEN_AUTH_REQUIRED=true
- UI_BIND_ADDRESS=127.0.0.1（仅本机）
- 端口：4310

### 待办
- [ ] 等待梦想家批准
- [ ] 执行部署
- [ ] 配置 systemd service
- [ ] 配置 logrotate
- [ ] 验证 UI 可访问

---

*方案已读，随时可执行。等待梦想家批准。* ⚙️
