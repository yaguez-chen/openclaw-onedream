#!/bin/bash
# 公民token使用量监控脚本
# 监控每个公民的token使用量，统计每日、每周用量

WORKSPACE="/home/gang/.openclaw/workspace-beta"
LOG_FILE="$WORKSPACE/logs/token-usage.log"
REPORT_FILE="$WORKSPACE/reports/token-report-$(date +%Y%m%d).md"
DATA_DIR="$WORKSPACE/data/token-usage"

# 创建目录
mkdir -p "$(dirname "$LOG_FILE")"
mkdir -p "$(dirname "$REPORT_FILE")"
mkdir -p "$DATA_DIR"

# 获取当前日期和时间
NOW=$(date -Iseconds)
DATE=$(date +%Y-%m-%d)
TIMESTAMP=$(date +%H:%M:%S)

echo "=== Token使用量监控开始于 $NOW ===" >> "$LOG_FILE"

# 获取所有agent列表（不使用jq，直接解析目录）
AGENTS=$(ls -1 /home/gang/.openclaw/agents/ | grep -v "^$")

# 初始化汇总数据
TOTAL_TOKENS=0
AGENT_COUNT=0
AGENT_DATA=""

echo "开始检查公民token使用量..." >> "$LOG_FILE"

for AGENT_ID in $AGENTS; do
    echo "检查公民: $AGENT_ID" >> "$LOG_FILE"
    
    # 简单获取agent名称和emoji
    AGENT_NAME="$AGENT_ID"
    AGENT_EMOJI="👤"
    
    # 尝试从identity文件中获取信息
    IDENTITY_FILE="/home/gang/.openclaw/agents/$AGENT_ID/agent/IDENTITY.md"
    if [ -f "$IDENTITY_FILE" ]; then
        NAME_LINE=$(grep -i "name:" "$IDENTITY_FILE" | head -1)
        if [ -n "$NAME_LINE" ]; then
            AGENT_NAME=$(echo "$NAME_LINE" | sed 's/.*name:\s*//i' | tr -d '[:space:]')
        fi
        
        EMOJI_LINE=$(grep -i "emoji:" "$IDENTITY_FILE" | head -1)
        if [ -n "$EMOJI_LINE" ]; then
            AGENT_EMOJI=$(echo "$EMOJI_LINE" | sed 's/.*emoji:\s*//i' | tr -d '[:space:]')
        fi
    fi
    
    # 获取最近会话（如果有的话）
    SESSION_FILE=$(find "/home/gang/.openclaw/agents/$AGENT_ID/sessions/" -name "*.jsonl" -type f 2>/dev/null | head -1)
    
    TOKEN_USAGE=0
    SESSION_COUNT=0
    
    if [ -f "$SESSION_FILE" ]; then
        # 从会话文件中提取token使用量（简化版本，实际需要更复杂的解析）
        SESSION_COUNT=$(grep -c '"role":"assistant"' "$SESSION_FILE" 2>/dev/null || echo 0)
        
        # 这里只是一个简单的估算，实际需要从API响应中获取准确的token计数
        # 为了演示目的，使用会话数量作为估算
        TOKEN_USAGE=$((SESSION_COUNT * 1000))
    else
        echo "公民 $AGENT_ID 无活跃会话" >> "$LOG_FILE"
    fi
    
    # 保存每个agent的数据
    AGENT_DATA="${AGENT_DATA}\n| $AGENT_EMOJI $AGENT_NAME ($AGENT_ID) | $TOKEN_USAGE | $SESSION_COUNT |"
    
    # 累加总量
    TOTAL_TOKENS=$((TOTAL_TOKENS + TOKEN_USAGE))
    AGENT_COUNT=$((AGENT_COUNT + 1))
    
    # 保存详细数据到单独文件
    echo "{\"agent_id\":\"$AGENT_ID\",\"name\":\"$AGENT_NAME\",\"emoji\":\"$AGENT_EMOJI\",\"tokens\":$TOKEN_USAGE,\"sessions\":$SESSION_COUNT,\"timestamp\":\"$NOW\"}" >> "$DATA_DIR/$DATE-$AGENT_ID.json"
    
    echo "公民 $AGENT_ID: $TOKEN_USAGE tokens ($SESSION_COUNT 会话)" >> "$LOG_FILE"
done

# 生成每日报告
cat > "$REPORT_FILE" << EOF
# Token使用量日报 - $DATE

**生成时间:** $TIMESTAMP  
**监控范围:** $AGENT_COUNT 个公民  
**总token使用量:** $TOTAL_TOKENS  

## 详细使用情况

| 公民 | Token用量 | 会话数量 |
|------|-----------|----------|$AGENT_DATA

## 数据分析

### 使用趋势
- **最高用量公民:** (待计算)
- **最低用量公民:** (待计算)
- **平均用量:** $((TOTAL_TOKENS / (AGENT_COUNT > 0 ? AGENT_COUNT : 1)))

### 建议
1. **用量监控:** 持续监控高用量公民
2. **成本优化:** 考虑对高用量会话进行优化
3. **异常检测:** 设置用量阈值告警

## 原始数据
- 详细日志: $LOG_FILE
- 数据目录: $DATA_DIR

---

*报告生成系统: 贝塔监察部*
EOF

echo "=== Token使用量监控完成 ===" >> "$LOG_FILE"
echo "报告已生成: $REPORT_FILE" >> "$LOG_FILE"

# 输出简要结果
echo "Token监控完成: $AGENT_COUNT 公民, 总用量 $TOTAL_TOKENS tokens"
echo "详细报告: $REPORT_FILE"