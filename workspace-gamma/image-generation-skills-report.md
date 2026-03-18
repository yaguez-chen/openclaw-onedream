# ClawHub 图片生成技能调研报告

**任务来源：** 阿尔法 🦐（梦想家指令）
**执行人：** 伽马 🔧
**日期：** 2026-03-18
**状态：** ✅ 完成

---

## 调研总结

| 技能 | 评分 | API 方式 | 单价 | 推荐指数 |
|------|------|---------|------|---------|
| best-image-generation | ⭐3.6 | EvoLink (Gemini) | 按量（未公开） | ⭐⭐⭐ |
| seedream | - | Atlas Cloud (字节) | $0.024-0.036/张 | ⭐⭐⭐⭐⭐ |
| cloudflare-image-gen | - | Cloudflare Workers AI | 免费 | ⭐⭐ |
| openrouter-image-gen | - | OpenRouter (Gemini) | 按token计费 | ⭐⭐⭐⭐ |
| volcengine-ai-image-generation | - | ❌ 无实际代码 | N/A | ⭐ |

---

## 1. best-image-generation

**作者：** EvoLinkAI
**ClawHub 评分：** ⭐3.6
**URL：** https://clawhub.ai/EvoLinkAI/best-image-generation

### 功能描述
- 基于 EvoLink Nano Banana Pro (gemini-3-pro-image-preview) API
- 文生图 + 图生图/图片编辑
- 支持多种尺寸：1:1, 2:3, 3:2, 16:9, 21:9 等
- 质量选项：1K, 2K（默认）, 4K（额外费用）
- 支持最多10张参考图（每张≤10MB）

### 依赖项
- **EVOLINK_API_KEY** 环境变量（必须）
- 获取地址：https://evolink.ai
- 异步轮询模式：提交任务 → 每10秒轮询 → 最多72次重试（~12分钟）

### 安装难度
🟢 低 — 纯 API 调用，无复杂依赖

### 输出格式
PNG/JPG/WEBP（自动检测），本地保存

### 触发词
- 中文："高质量生图：xxx" / "编辑图片：xxx"
- 英文："best image: xxx" / "edit image: xxx"

### 评价
- ✅ 功能完整（文生图+图编辑）
- ✅ 支持高分辨率（4K）
- ⚠️ 评分偏低（3.6）
- ⚠️ 轮询模式较慢（最坏12分钟）
- ⚠️ API 定价不透明

---

## 2. seedream（字节跳动 Seedream 5.0）⭐ 推荐

**作者：** xixihhhh
**ClawHub 评分：** 未知（新技能）
**URL：** https://clawhub.ai/xixihhhh/seedream

### 功能描述
- 字节跳动 Seedream 模型（3代：v5.0 Lite / v4.5 / v4）
- 文生图 + 图片编辑 + 批量序列生成（最多15张）
- **最高 4K 分辨率**，16种预设尺寸
- 支持14张参考图编辑
- **内置提示词优化**（Standard/Fast 两种模式）
- 支持 PNG 和 JPEG 输出
- **排版和海报设计**能力突出
- v5.0 Lite 生成速度 **2-3秒/张**

### 依赖项
- **ATLASCLOUD_API_KEY** 环境变量（必须）
- 注册地址：https://www.atlascloud.ai
- 按量付费

### 定价（Atlas Cloud，比官方便宜10%）

| 模型 | 价格/张 | 备注 |
|------|---------|------|
| v5.0 Lite | $0.032 | 最新旗舰 |
| v4.5 | $0.036 | 上一代 |
| v4 | $0.024 | 最便宜 |

### 安装难度
🟢 低 — API 调用，需注册 Atlas Cloud

### 评价
- ✅ **质量最高**（字节最新旗舰模型）
- ✅ 速度快（2-3秒/张）
- ✅ 价格合理（$0.024-0.036/张）
- ✅ 排版/海报设计独特能力
- ✅ 批量生成（最多15张）
- ✅ 内置提示词优化
- ⚠️ 需要付费 API
- ⚠️ Atlas Cloud 为海外平台

---

## 3. cloudflare-image-gen

**作者：** EXPYSF98
**ClawHub 评分：** 未知
**URL：** https://clawhub.ai/EXPYSF98/cloudflare-image-gen

### 功能描述
- 基于 Cloudflare Workers AI
- 模型：@cf/black-forest-labs/flux-1-schnell（FLUX.1 Schnell）
- 纯 Python 实现
- 文生图

### 依赖项
- Cloudflare Account ID（已硬编码在 SKILL.md 中 ⚠️）
- Cloudflare API Token（已硬编码在 SKILL.md 中 ⚠️）
- Python 3 + requests 库

### 安装难度
🟡 中 — 需要 Cloudflare 账号，但 token 已暴露

### 输出格式
PNG

### 评价
- ✅ **免费**（Cloudflare Workers AI 免费额度）
- ✅ FLUX.1 Schnell 模型质量不错
- ⚠️ **安全问题严重**：SKILL.md 中硬编码了 Account ID 和 Token
- ⚠️ 作者身份不明
- ⚠️ 功能单一（仅文生图）
- ❌ 不建议直接使用（安全隐患）

---

## 4. openrouter-image-gen ⭐ 推荐

**作者：** yangwenyu2
**ClawHub 评分：** 未知
**URL：** https://clawhub.ai/yangwenyu2/openrouter-image-gen

### 功能描述
- 基于 OpenRouter API（默认 google/gemini-3.1-flash-image-preview）
- 文生图 + 参考图引导（--ref 参数）
- Python stdlib 实现（零依赖！）
- 支持多种宽高比
- 内置详细提示词工程指南

### 依赖项
- **OPENROUTER_API_KEY** 环境变量（必须）
- Python 3.10+（仅标准库，无需 pip install）

### 定价（OpenRouter）
| 模型 | 输入 | 输出 |
|------|------|------|
| gemini-3.1-flash-image-preview | $0.25/M tokens | $1.5/M tokens |
| gemini-3.1-pro-preview | $2/M tokens | $12/M tokens |

### 安装难度
🟢 极低 — 零依赖，纯 Python stdlib

### 亮点功能
- 参考图支持（风格/角色一致性）
- 详细提示词工程指南（宽高比、风格控制、角色一致性）
- 飞书图片发送支持（已适配 OpenClaw）
- 支持中文提示词

### 评价
- ✅ **最便宜**（Gemini Flash 按 token 计费）
- ✅ 零依赖（纯 stdlib）
- ✅ 文档最完善（详细提示词指南）
- ✅ 参考图支持
- ✅ OpenClaw 飞书适配
- ⚠️ 中文文字渲染不可靠
- ⚠️ 手部细节仍有问题

---

## 5. volcengine-ai-image-generation

**作者：** cinience
**ClawHub 评分：** 未知
**URL：** https://clawhub.ai/cinience/volcengine-ai-image-generation

### 功能描述
- 名称暗示火山引擎 AI 图片生成集成
- **实际内容：仅是提示词模板，无任何 API 调用代码**
- 无 API key、endpoint、配置说明

### 安全评估（skill-guard 分析）
- ⚠️ 无实际 API 集成代码
- ⚠️ 品牌与实现不一致
- ⚠️ 无凭证声明
- ⚠️ 可能误导用户

### 评价
- ❌ **不推荐** — 仅是提示词模板，无法实际生成图片
- ❌ 名不副实（声称火山引擎但无实际集成）
- ❌ 需要安装 skill-builder 自行实现才能使用

---

## 综合推荐

### 🥇 首选：seedream（字节 Seedream 5.0）
- **理由：** 质量最高、速度快、价格合理、功能最全
- **适合：** 对图片质量要求高的场景（海报、排版、品牌视觉）
- **成本：** $0.024-0.036/张

### 🥈 次选：openrouter-image-gen（Gemini Flash）
- **理由：** 最便宜、零依赖、文档好、OpenClaw 适配
- **适合：** 日常图片生成、快速原型、预算有限
- **成本：** 按 token 计费，约 $0.001-0.01/张

### 🥉 备选：best-image-generation（EvoLink）
- **理由：** 功能完整但评分偏低
- **适合：** 已有 EvoLink 账号的用户
- **成本：** 按量（不透明）

### ⚠️ 不推荐
- **cloudflare-image-gen** — 安全隐患（硬编码 token）
- **volcengine-ai-image-generation** — 无实际代码

---

## 安装建议

如果梦想家决定安装，建议优先安装顺序：
1. `clawhub install seedream`（需要 ATLASCLOUD_API_KEY）
2. `clawhub install openrouter-image-gen`（需要 OPENROUTER_API_KEY）

---

*报告由伽马 🔧 编写，2026-03-18*
