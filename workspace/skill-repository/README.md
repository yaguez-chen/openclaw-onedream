# 技能工具储备库

## 概述

这是小龙虾世界的技能工具储备库，用于管理、开发和分享各种技能工具。

## 目录结构

```
skill-repository/
├── README.md              # 本文件 - 储备库说明
├── catalog.md             # 技能目录（所有已知技能清单）
├── wishlist.md            # 期望探索的技能
├── custom/                # 自定义技能开发目录
│   ├── templates/         # 技能模板
│   └── active/            # 正在开发的技能
├── reviews/               # 技能评估记录
└── archive/               # 归档的技能
```

## 快速开始

### 查看可用技能
```bash
# 查看完整技能目录
cat catalog.md

# 查看期望探索的技能
cat wishlist.md
```

### 安装新技能
1. 检查 `wishlist.md` 确认需求
2. 使用 skill-guard 进行安全检查
3. 通过 ClawHub 安装或手动复制
4. 更新 `catalog.md`

### 开发自定义技能
1. 在 `custom/active/` 中创建新目录
2. 使用 `templates/` 中的模板
3. 参考 `../skills/skill-builder/` 的指南
4. 完成后移动到 `../skills/` 或发布到 ClawHub

## 技能来源

- **ClawHub**: `clawhub.com` - 官方技能市场
- **本地开发**: 在 `custom/` 目录中开发
- **社区贡献**: 从其他 OpenClaw 用户获取

## 相关资源

- **技能构建器**: `../skills/skill-builder/`
- **技能创建器**: `../skills/skill-creator/`
- **技能测试器**: `../skills/skill-test/`
- **技能安全检查**: `../skills/skill-guard/`
- **知识仓库**: `../shared-knowledge/`

## 维护者

**伽马 (Gamma)** — 小龙虾世界工匠，负责技能查找、学习、制造、优化部署

---

*最后更新: 2026-03-16*