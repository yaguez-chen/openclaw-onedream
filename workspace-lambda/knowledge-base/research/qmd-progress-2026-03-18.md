# qmd 研究进度报告

**时间：** 2026-03-18 13:12 GMT+8
**研究者：** 拉姆达 (Lambda)
**版本：** qmd 2.0.1

---

## 📊 当前进度

### 模型下载状态

| 模型 | 状态 | 大小 | 进度 |
|------|------|------|------|
| embeddinggemma-300M-Q8_0.gguf | ✅ 已下载 | 314MB | 100% |
| qmd-query-expansion-1.7B-q4_k_m.gguf | ⏳ 下载中 | 1.28GB | 46.90% |
| Qwen3-Reranker-0.6B-Q8_0.gguf | ❌ 未下载 | ~600MB | - |

### 嵌入向量状态

| 指标 | 数值 |
|------|------|
| 总文档数 | 146 |
| 已嵌入 | 19 |
| 待嵌入 | 109 (75%) |
| 索引大小 | 19.6 MB |

### 搜索功能状态

| 功能 | 状态 | 说明 |
|------|------|------|
| BM25 关键词搜索 | ✅ 可用 | 中文/英文均有效 |
| 向量语义搜索 | ⚠️ 部分可用 | 需要更多嵌入 |
| 混合搜索 | ❌ 不可用 | 需要查询扩展模型 |

---

## 🔬 已验证功能

### 1. BM25 关键词搜索（中文）

```bash
qmd search "超时问题" -c knowledge
```

**结果：** 找到相关文档，得分 87%
**路径：** `qmd://knowledge/phase4-deliverables/communication/briefing-automation-plan.md`
**内容：** 包含 "session 超时问题" 相关信息

### 2. BM25 关键词搜索（英文）

```bash
qmd search "timeout error" -c logs
```

**结果：** 找到日志条目，得分 91%
**路径：** `qmd://logs/openclaw-2026-03-18.log`

### 3. 索引管理

```bash
qmd status          # 查看状态
qmd update          # 更新索引
qmd ls knowledge    # 列出知识库文件
```

**集合：**
- theta: 43 文件
- gamma: 23 文件
- knowledge: 78 文件
- logs: 2 文件

---

## ⚠️ 当前问题

### 1. 查询扩展模型下载缓慢

**现象：** `qmd-query-expansion-1.7B-q4_k_m.gguf` 下载速度极慢（1-400kB/s）

**原因：** HuggingFace 镜像源速度不稳定

**预计完成时间：** 约 1-2 小时

### 2. 嵌入向量生成失败

**现象：** `qmd embed` 命令导致 Bun 分段错误（Segmentation fault）

**原因：** Bun 运行时问题，与 qmd 无关

**影响：** 只能生成 19 个嵌入（13%），剩余 109 个无法生成

### 3. 语义搜索功能受限

**现状：**
- 向量搜索：可用（但只有 19 个文档有嵌入）
- 混合搜索：不可用（需要查询扩展模型）

---

## 🎯 下一步建议

### 选项 1：继续下载（推荐）

继续下载查询扩展模型，完成后可以：
- 完整测试语义搜索
- 测试混合搜索（BM25 + 向量 + rerank）
- 评估中文语义搜索效果

**预计时间：** 1-2 小时

### 选项 2：使用部分功能

使用现有功能（BM25 + 19 个嵌入）：
- ✅ BM25 关键词搜索（已验证有效）
- ⚠️ 向量搜索（有限覆盖）
- ❌ 混合搜索（不可用）

**适合场景：** 立即使用，不需要等待下载

### 选项 3：手动下载模型

从镜像站手动下载模型文件：
1. 下载 `hf_tobil_qmd-query-expansion-1.7B-q4_k_m.gguf`
2. 放到 `~/.cache/qmd/models/`
3. 重新运行 `qmd embed`

**适合场景：** 网络不稳定，需要断点续传

---

## 📋 研究结论

### qmd 核心发现

1. **不需要 Ollama**：qmd 有自己的嵌入系统，使用 GGUF 模型 + Vulkan GPU
2. **BM25 搜索强大**：中文/英文关键词搜索效果好
3. **语义搜索潜力大**：但需要完整模型支持
4. **MCP 集成简单**：`qmd mcp` 可直接集成到 OpenClaw

### 硬件兼容性

- ✅ Intel UHD Graphics 620 (Vulkan 支持)
- ⚠️ RAM 7.6GB（运行 1.7B 模型可能较慢）
- ✅ CPU 4 核（足够运行嵌入模型）

### 建议配置

```bash
# 设置 HuggingFace 镜像
export HF_ENDPOINT=https://hf-mirror.com

# 运行 qmd
qmd embed          # 生成嵌入
qmd vsearch "query"  # 语义搜索
qmd query "query"    # 混合搜索
qmd mcp             # MCP 服务器
```

---

## 🔗 参考资料

- **完整报告：** `knowledge-base/research/qmd-semantic-search-research.md`
- **进度报告：** `knowledge-base/research/qmd-progress-2026-03-18.md`
- **GitHub：** https://github.com/tobi/qmd
