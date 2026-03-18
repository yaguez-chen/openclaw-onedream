# 🔧 自动同步脚本修复：适配 Submodule 架构

**时间：** 2026-03-18 11:17
**作者：** 贝塔 🔵
**标签：** #维护 #同步脚本 #Submodule #方案1后续
**抄送：** @阿尔法 @泽塔

---

## 背景

梦想家指示执行方案1，将仓库重构为 Submodule 架构：
- `shared-knowledge` → 独立子模块，指向 `yaguez-chen/onedream-knowledge.git`
- `openclaw-control-center` → 独立子模块，指向 `TianyiDataScience/openclaw-control-center.git`
- `workspace` → 转为普通目录，内容直接提交到主仓库

重构后，泽塔之前编写的自动同步脚本需要适配。

---

## 问题评审

### sync-knowledge.sh ❌ 路径失效
- **原路径：** `/home/gang/.openclaw/workspace/shared-knowledge`
- **问题：** `shared-knowledge` 已从 workspace 移到仓库根目录，原路径不存在
- **修复：** 路径改为 `/home/gang/.openclaw/shared-knowledge`

### sync-world.sh ⚠️ 缺少子模块拉取
- **原逻辑：** `git add -A` → commit → push
- **问题：** 只提交主仓库的 submodule 指针，不会主动拉取子模块最新内容
- **修复：** 在 `git add -A` 前增加 `git submodule update --remote`，确保子模块内容先拉取再提交指针

### openclaw-control-center 同步 ⏸️ 未处理
- 梦想家指示不需要额外处理，跳过

---

## 修复内容

### sync-knowledge.sh
```bash
# 修改前
cd /home/gang/.openclaw/workspace/shared-knowledge

# 修改后
cd /home/gang/.openclaw/shared-knowledge
```

### sync-world.sh
```bash
# 修改前
cd /home/gang/.openclaw
git add -A
git diff --cached --quiet && exit 0
git commit -m "世界备份自动同步: $(date '+%Y-%m-%d %H:%M')"
git push origin main 2>&1

# 修改后
cd /home/gang/.openclaw
git submodule update --remote 2>&1   # ← 新增：先拉取子模块
git add -A
git diff --cached --quiet && exit 0
git commit -m "世界备份自动同步: $(date '+%Y-%m-%d %H:%M')"
git push origin main 2>&1
```

---

## Crontab 不变

| 脚本 | 频率 | 状态 |
|------|------|------|
| sync-knowledge.sh | 每 2 小时 | ✅ 路径已修复 |
| sync-world.sh | 每日 03:00 | ✅ 已增加子模块拉取 |

---

## 影响评估

- **sync-knowledge.sh：** 下次 cron 执行时将正确进入 submodule 目录，不再报错
- **sync-world.sh：** 每日同步时会先拉取 shared-knowledge 和 openclaw-control-center 的最新内容，再更新主仓库指针
- **无需重启网关**，cron 自动生效

---

_贝塔 🔵 — 监察者_
