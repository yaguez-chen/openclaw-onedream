# qmd 技能研究笔记

## 基本信息
- **来源**：Tobias Lütke（Shopify CEO）开发
- **仓库**：https://github.com/tobi/qmd
- **已安装版本**：qmd 2.0.1（本地 `/home/gang/.bun/bin/qmd`）

## 核心功能
本地文件搜索和索引工具，支持三种搜索模式：

1. **BM25 关键词搜索** — `qmd search "query"`
2. **向量语义搜索** — `qmd vsearch "query"`
3. **混合搜索** — `qmd query "query"`（BM25 + 向量 + rerank）

## 索引管理
```bash
qmd collection add /path --name docs --mask "**/*.md"  # 添加集合
qmd update                                              # 更新索引
qmd status                                              # 查看状态
qmd get docs/path.md:10 -l 40                          # 获取文档片段
```

## 语义搜索相关（重点研究方向）

### 依赖
- Ollama（本地 `http://localhost:11434`）

### 当前状态
- ✅ qmd 已安装（BM25搜索可用）
- ❌ Ollama 未安装（语义搜索不可用）
- 📋 已列入待办：安装 Ollama + nomic-embed-text 模型

### 语义搜索原理
- 使用嵌入模型（embedding model）将文本转为向量
- 通过向量相似度匹配语义相近的内容
- 不需要精确关键词，能理解"意思"

### 索引存储
- 默认位置：`~/.cache/qmd`

### MCP 模式
- `qmd mcp` — 可作为 MCP 服务器提供给 AI agent 使用

## 建议研究方向

1. **嵌入模型选型**
   - nomic-embed-text 是否最优？
   - 有无更好的中文嵌入模型？

2. **性能评估**
   - 在当前机器（i5-8265U / 7.6GB RAM）上能索引多少文档？
   - 搜索响应时间如何？

3. **中文支持**
   - qmd 对中文分词和语义搜索的效果如何？
   - 是否需要额外的中文处理？

4. **MCP 集成**
   - 如何把 qmd mcp 集成到 OpenClaw 的 skill 系统？
   - 能否作为通用搜索服务提供给所有 agent？

5. **与现有工具对比**
   - 和 grep、ripgrep、以及其他语义搜索方案的优劣
   - 适用场景分析

## 待办事项
- [ ] 安装 Ollama（需 sudo 权限）
- [ ] 拉取 nomic-embed-text 模型
- [ ] 测试语义搜索功能
- [ ] 评估中文支持效果
- [ ] 研究 MCP 集成方案

---

*整理时间：2026-03-18 12:52 GMT+8*
*整理人：伽马 🔧*
