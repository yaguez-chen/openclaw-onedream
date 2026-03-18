# qmd 语义搜索研究报告

**研究时间：** 2026-03-18 13:02 GMT+8
**研究者：** 拉姆达 (Lambda)
**版本：** qmd 2.0.1

---

## 📋 执行摘要

qmd 是一个强大的本地文件搜索/索引工具，支持三种搜索模式。**重大发现：qmd 不需要 Ollama！** 它有自己的内置嵌入系统，使用 GGUF 模型通过 Vulkan GPU 加速。

**当前状态：**
- ✅ BM25 关键词搜索 — 可用
- ❌ 向量语义搜索 — 需要嵌入向量（未生成）
- ❌ 混合搜索 — 需要嵌入向量（未生成）

---

## 🔬 核心发现

### 1. qmd 不需要 Ollama！

**之前的理解（错误）：**
- 语义搜索需要 Ollama (localhost:11434)
- 需要安装 nomic-embed-text 模型

**实际情况（qmd 2.0.1）：**
- qmd 使用 **自己的嵌入系统**，通过 Vulkan GPU 加速
- 模型以 GGUF 格式从 HuggingFace 下载
- **三个内置模型：**

| 用途 | 模型 | 大小 |
|------|------|------|
| 嵌入 (Embedding) | embeddinggemma-300M-GGUF | ~300M |
| 重排序 (Reranking) | Qwen3-Reranker-0.6B-Q8_0-GGUF | ~600M |
| 查询扩展 (Generation) | qmd-query-expansion-1.7B-gguf | ~1.7B |

### 2. 硬件支持

**GPU 加速：**
- ✅ Vulkan 支持：Intel UHD Graphics 620 (WHL GT2)
- ✅ GPU 卸载：yes
- VRAM：2.3 GB free / 5.7 GB total

**CPU/RAM：**
- CPU：Intel Core i5-8265U @ 1.60GHz (4 cores)
- RAM：7.6GB 总计，~2.6GB 可用

**评估：** 硬件足够运行嵌入模型（300M + 600M），但 1.7B 的查询扩展模型可能较慢。

### 3. 当前索引状态

**集合（Collections）：**

| 集合 | 路径 | 文件数 |
|------|------|--------|
| theta | workspace-theta | 43 |
| gamma | workspace-gamma | 23 |
| alpha | workspace-alpha | 0 |
| knowledge | shared-knowledge | 78 |
| logs | /tmp/openclaw | 2 |
| **总计** | — | **146** |

**索引大小：** 19.6 MB (SQLite)
**嵌入向量：** 0 / 119 待生成

### 4. 搜索能力测试

**BM25 搜索（中文）：**
```
qmd search "超时问题" -c knowledge
✅ 成功！找到相关文档，得分 87%
```

**BM25 搜索（英文）：**
```
qmd search "timeout error" -c logs
✅ 成功！找到日志条目，得分 91%
```

**向量搜索：**
```
qmd vsearch "如何解决超时问题"
❌ 无结果（需要先生成嵌入向量）
```

**混合搜索：**
```
qmd query "LLM timeout context window"
⚠️ 卡在 "Gathering information"（需要下载模型）
```

---

## ⚠️ 当前问题

### 问题 1：嵌入生成卡住

**现象：** `qmd embed` 命令卡在 "Gathering information" 阶段

**可能原因：**
1. 需要从 HuggingFace 下载模型（网络问题？）
2. 模型下载失败但没有错误提示
3. 内存不足（只有 2.6GB 可用）

**已验证：**
- 模型文件未下载到 `~/.cache/qmd/models/`
- 未找到任何 .gguf 文件
- HuggingFace 连接未验证（curl 超时）

### 问题 2：模型存储位置不明

qmd 的模型存储位置不明确。`~/.cache/qmd/` 只有 SQLite 索引文件，没有模型文件。

---

## 🔧 搜索模式详解

### 1. BM25 关键词搜索 (`qmd search`)
- ✅ 当前可用
- 基于词频的文本匹配
- 支持中文分词
- 不需要嵌入向量
- 速度快，资源消耗低

### 2. 向量语义搜索 (`qmd vsearch`)
- ❌ 需要嵌入向量
- 基于语义理解，不需要精确关键词
- 依赖 embeddinggemma-300M 模型
- 需要 Vulkan GPU 或 CPU 推理

### 3. 混合搜索 (`qmd query`)
- ❌ 需要嵌入向量 + 模型
- BM25 + 向量 + rerank 结合
- 自动查询扩展
- 最强大但资源消耗最大

### 查询语法（高级）
```bash
# 单行查询（自动扩展）
qmd query "how does auth work"

# 多行结构化查询
qmd query $'lex: CAP theorem\nvec: consistency'

# 带引号的精确匹配
qmd query $'lex: "exact matches" sports -baseball'

# HyDE 查询（假设答案）
qmd query $'hyde: Hypothetical answer text'

# 带意图的查询
qmd query $'intent: find auth code\nlex: login\nvec: authentication'
```

---

## 🔌 MCP 集成

**MCP 模式：** `qmd mcp` — stdio 传输

**用法：**
```bash
qmd mcp                    # stdio 模式
qmd mcp --http ...         # HTTP 模式
qmd mcp --http --daemon    # 守护进程模式
```

**与 OpenClaw 集成思路：**
1. 在 OpenClaw 配置中添加 MCP 服务器
2. 或者通过 skill 系统封装 qmd 命令
3. 或者直接调用 qmd CLI（当前方式）

**Skill 安装：**
```bash
qmd skill install          # 安装到 ./.agents/skills/qmd
qmd skill install --global # 安装到 ~/.agents/skills/qmd
```

---

## 📊 性能评估

### 索引性能
- 146 个文件，索引大小 19.6 MB
- 更新时间：~30 分钟前
- 索引速度：快（分钟级）

### 搜索性能
- BM25 搜索：< 1 秒
- 向量搜索：未测试（需要嵌入）
- 混合搜索：未测试（需要模型）

### 资源消耗
- 索引存储：19.6 MB
- 模型存储：~2.7 GB（三个模型总计）
- 运行时内存：待测试
- GPU 显存：2.3 GB 可用

---

## 🎯 建议下一步

### 短期（立即可做）
1. **解决模型下载问题**
   - 检查网络连接到 HuggingFace
   - 尝试手动下载模型
   - 或配置镜像源

2. **测试 BM25 搜索的实际效果**
   - 中文关键词匹配测试
   - 日志搜索测试
   - 知识库搜索测试

### 中期（模型就绪后）
3. **测试语义搜索效果**
   - 中文语义搜索准确度
   - 英文语义搜索准确度
   - 混合搜索质量评估

4. **集成到 OpenClaw**
   - 配置 qmd MCP 服务器
   - 创建 qmd skill
   - 添加到 Agent 工具链

### 长期（优化）
5. **嵌入模型选型评估**
   - embeddinggemma-300M vs 其他中文嵌入模型
   - 是否需要微调
   - 多语言支持

6. **性能优化**
   - 索引更新策略
   - 增量嵌入
   - 缓存策略

---

## 🔗 参考资料

- **GitHub:** https://github.com/tobi/qmd
- **作者:** Tobias Lütke (Shopify CEO)
- **安装路径:** `/home/gang/.bun/bin/qmd`
- **索引位置:** `~/.cache/qmd/index.sqlite`
- **配置文件:** `~/.config/qmd/index.yml`
- **Skill 文件:** `/home/gang/.openclaw/workspace/skills/qmd/SKILL.md`
