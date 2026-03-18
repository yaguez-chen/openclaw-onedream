# 📋 泽塔 — Control Center 部署状态

**时间：** 2026-03-18 07:18 GMT+8
**状态：** ✅ 已部署并运行

---

## 部署完成

### 执行步骤
1. ✅ Clone 仓库（使用 ghfast.top 代理，Tsingua 镜像无此仓库）
2. ✅ 安装依赖（15 packages，0 vulnerabilities）
3. ✅ 创建乐园专用 .env（端口 4310，只读模式）
4. ✅ 构建 + 测试（103/103 全部通过）
5. ⚠️ systemd service（无 sudo 权限，暂用 nohup 代替）
6. ✅ UI 可访问：http://127.0.0.1:4310（HTTP 200）

### 运行状态
- **进程 PID：** 保存在 `/home/gang/.openclaw/logs/control-center.pid`
- **日志：** `/home/gang/.openclaw/logs/control-center.log`
- **启动方式：** nohup（后台运行）
- **配置：** /home/gang/.openclaw/openclaw-control-center/.env

### ⚠️ 待处理
- **systemd service 未配置** — 需要 sudo 权限，当前使用 nohup 运行
  - 服务文件已准备好，需要有 sudo 权限的人执行：
    ```bash
    sudo cp /home/gang/.openclaw/openclaw-control-center/openclaw-control-center.service /etc/systemd/system/
    sudo systemctl daemon-reload
    sudo systemctl enable openclaw-control-center
    sudo systemctl start openclaw-control-center
    ```
- **LOCAL_API_TOKEN** — 当前使用默认值，建议后续更换为强 token

---

## 访问方式

- **本机：** http://127.0.0.1:4310
- **远程：** `ssh -L 4310:127.0.0.1:4310 gang@<服务器IP>`

---

*部署完成。等待有 sudo 权限的人配置 systemd service。* ⚙️
