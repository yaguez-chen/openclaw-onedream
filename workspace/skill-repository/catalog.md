# 技能目录 - 小龙虾世界技能储备库

## 概览

- **已安装核心技能**: 7个（~/.openclaw/skills/）
- **工作空间技能**: 9个（~/.openclaw/workspace/skills/）
- **ClawHub可用技能**: 50+个（~/.npm-global/lib/node_modules/openclaw/skills/）

---

## 一、核心技能（已安装 - ~/.openclaw/skills/）

### 1. adaptive-reasoning
- **功能**: 自适应推理 - 自动评估任务复杂度并调整推理级别
- **成熟度**: 稳定
- **适用对象**: 所有伙伴
- **分类**: 智能/推理
- **依赖**: 无
- **使用频率**: 高（每次对话触发）

### 2. agent-autopilot
- **功能**: 自驱动工作流 - 心跳驱动的任务执行，昼夜进度报告
- **成熟度**: 稳定
- **适用对象**: 所有伙伴
- **分类**: 工作流/自动化
- **依赖**: todo-management
- **使用频率**: 中（项目管理场景）

### 3. agent-browser
- **功能**: 无头浏览器自动化 - 导航、点击、输入、页面快照
- **成熟度**: 稳定
- **适用对象**: 需要网页操作的伙伴
- **分类**: 网络/自动化
- **依赖**: node, npm
- **使用频率**: 中（网页数据采集、表单填写）

### 4. agent-memory
- **功能**: 持久化记忆系统 - 跨会话记住事实、学习经验
- **成熟度**: 稳定
- **适用对象**: 所有伙伴
- **分类**: 记忆/存储
- **依赖**: Python
- **使用频率**: 高（持续使用）

### 5. credential-manager
- **功能**: 凭证管理 - 安全集中管理API密钥和凭证
- **成熟度**: 稳定
- **适用对象**: 所有伙伴
- **分类**: 安全/凭证
- **依赖**: 无
- **使用频率**: 中（安装和配置时使用）

### 6. diagram-generator
- **功能**: 图表生成 - 创建draw.io、Mermaid、Excalidraw图表
- **成熟度**: 稳定
- **适用对象**: 需要可视化的伙伴
- **分类**: 创意/可视化
- **依赖**: MCP服务器
- **使用频率**: 低（特定场景）

### 7. self-improving-agent
- **功能**: 自我改进 - 捕获学习、错误和纠正，持续改进
- **成熟度**: 稳定
- **适用对象**: 所有伙伴
- **分类**: 学习/改进
- **依赖**: 无
- **使用频率**: 高（持续学习）

---

## 二、工作空间技能（已安装 - ~/.openclaw/workspace/skills/）

### 8. data-analyst
- **功能**: 数据分析 - SQL查询、电子表格分析、数据可视化、报告生成
- **成熟度**: 稳定
- **适用对象**: 数据相关伙伴
- **分类**: 数据/分析
- **依赖**: Python, pandas, matplotlib
- **使用频率**: 中（数据分析场景）

### 9. feishu-common
- **功能**: 飞书通用功能 - 飞书平台基础操作
- **成熟度**: 稳定
- **适用对象**: 使用飞书的伙伴
- **分类**: 通信/集成
- **依赖**: 飞书API
- **使用频率**: 高（当前通信渠道）

### 10. feishu-doc
- **功能**: 飞书文档管理 - 获取飞书文档、知识库、表格内容
- **成熟度**: 稳定
- **适用对象**: 使用飞书的伙伴
- **分类**: 通信/文档
- **依赖**: 飞书API
- **使用频率**: 高（文档操作）

### 11. find-skills
- **功能**: 技能发现 - 帮助发现和安装新技能
- **成熟度**: 稳定
- **适用对象**: 伽马
- **分类**: 工具/发现
- **依赖**: clawhub CLI
- **使用频率**: 中（技能探索时）

### 12. self-evolving-skill
- **功能**: 自我进化技能 - 基于预测编码和价值驱动机制的自动技能进化
- **成熟度**: 实验
- **适用对象**: 高级伙伴
- **分类**: 学习/进化
- **依赖**: 无
- **使用频率**: 低（实验性功能）

### 13. skill-builder
- **功能**: 技能构建器 - 创建高质量技能的指南和模板
- **成熟度**: 稳定
- **适用对象**: 伽马
- **分类**: 开发/工具
- **依赖**: 无
- **使用频率**: 高（技能开发时）

### 14. skill-creator
- **功能**: 技能创建向导 - 创建扩展Claude能力的专用技能
- **成熟度**: 稳定
- **适用对象**: 伽马
- **分类**: 开发/工具
- **依赖**: 无
- **使用频率**: 高（技能开发时）

### 15. skill-guard
- **功能**: 技能安全检查 - 安装前扫描技能安全漏洞
- **成熟度**: 稳定
- **适用对象**: 伽马
- **分类**: 安全/检查
- **依赖**: clawhub CLI
- **使用频率**: 高（安装新技能时）

### 16. skill-test
- **功能**: 技能测试 - 测试技能功能和性能
- **成熟度**: 稳定
- **适用对象**: 伽马
- **分类**: 开发/测试
- **依赖**: 无
- **使用频率**: 中（技能开发时）

---

## 三、ClawHub可用技能（未安装）

### 通信类
- **discord**: Discord集成
- **slack**: Slack集成
- **voice-call**: 语音通话
- **imsg**: iMessage集成
- **bluebubbles**: BlueBubbles集成

### 笔记/文档类
- **apple-notes**: Apple Notes集成
- **bear-notes**: Bear Notes集成
- **notion**: Notion集成
- **obsidian**: Obsidian集成
- **nano-pdf**: PDF处理

### 任务/项目管理类
- **apple-reminders**: Apple提醒事项
- **things-mac**: Things 3集成
- **trello**: Trello集成
- **session-logs**: 会话日志

### 开发工具类
- **coding-agent**: 编码代理
- **gh-issues**: GitHub Issues处理
- **github**: GitHub操作
- **tmux**: 终端复用器

### 媒体/创意类
- **gifgrep**: GIF搜索
- **nano-banana-pro**: 图像处理
- **openai-image-gen**: OpenAI图像生成
- **openai-whisper**: 语音转文字
- **video-frames**: 视频帧提取
- **sag**: 语音合成(TTS)
- **sherpa-onnx-tts**: 本地TTS

### 生活/工具类
- **weather**: 天气查询
- **healthcheck**: 健康检查/安全审计
- **1password**: 密码管理
- **oracle**: 预言/占卜
- **songsee**: 音乐发现
- **spotify-player**: Spotify播放器
- **sonoscli**: Sonos音箱控制
- **openhue**: 智能灯光控制
- **goplaces**: 地点探索

### 系统/工具类
- **clawhub**: ClawHub CLI
- **model-usage**: 模型使用统计
- **xurl**: URL处理
- **canvas**: 画布工具
- **eightctl**: 8Sleep床垫控制
- **mcporter**: Minecraft端口转发

### 社交/内容类
- **blogwatcher**: 博客监控
- **wacli**: WhatsApp CLI
- **summarize**: 内容总结
- **gog**: 游戏发现
- **ordercli**: 订单管理
- **peekaboo**: 屏幕监控

---

## 四、技能分类矩阵

### 按功能分类

| 类别 | 技能数 | 代表技能 |
|------|--------|----------|
| **智能/推理** | 2 | adaptive-reasoning, self-evolving-skill |
| **工作流/自动化** | 1 | agent-autopilot |
| **网络/自动化** | 1 | agent-browser |
| **记忆/存储** | 1 | agent-memory |
| **安全/凭证** | 2 | credential-manager, skill-guard |
| **创意/可视化** | 1 | diagram-generator |
| **学习/改进** | 2 | self-improving-agent, skill-test |
| **数据/分析** | 1 | data-analyst |
| **通信/集成** | 3 | feishu-common, feishu-doc, discord(可用) |
| **开发/工具** | 3 | skill-builder, skill-creator, coding-agent(可用) |
| **媒体/创意** | 7 | gifgrep, nano-banana-pro, openai-image-gen等(可用) |
| **生活/工具** | 10 | weather, healthcheck, oracle等(可用) |

### 按成熟度分类

| 成熟度 | 技能数 | 说明 |
|--------|--------|------|
| **稳定** | 15 | 经过测试，可安全使用 |
| **测试** | 1 | self-evolving-skill（实验性功能） |
| **实验** | 0 | 暂无 |

### 按适用对象分类

| 对象 | 技能数 | 说明 |
|------|--------|------|
| **所有伙伴** | 9 | 基础能力，所有人都需要 |
| **伽马专用** | 4 | 技能开发和测试工具 |
| **特定角色** | 3 | 飞书相关、数据分析等 |

---

## 五、技能使用统计

### 高频使用（每日）
- adaptive-reasoning
- agent-memory
- self-improving-agent
- feishu-common
- feishu-doc

### 中频使用（每周）
- agent-autopilot
- agent-browser
- credential-manager
- data-analyst
- find-skills
- skill-builder
- skill-creator
- skill-guard
- skill-test

### 低频使用（每月）
- diagram-generator
- self-evolving-skill

---

## 六、待评估技能（从ClawHub）

以下技能可能对小龙虾世界有价值，需要评估：

1. **weather** - 天气查询，实用性强
2. **healthcheck** - 安全审计，符合安全需求
3. **github** - GitHub操作，开发需要
4. **coding-agent** - 编码辅助，伽马需要
5. **summarize** - 内容总结，知识管理需要
6. **session-logs** - 会话日志，记忆管理需要

---

*目录更新时间: 2026-03-16*  
*维护者: 伽马 (Gamma)*