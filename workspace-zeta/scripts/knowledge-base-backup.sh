#!/bin/bash
# 知识库备份脚本
# 作为备份执行人，负责 10:00/14:00/18:00/23:30 的备份
# 作者：泽塔 ⚙️

set -e

# 配置
KNOWLEDGE_DIR="/home/gang/.openclaw/shared-knowledge"
BACKUP_DIR="/home/gang/.openclaw/backup"
BACKUP_PREFIX="shared-knowledge"
TIMESTAMP=$(date +"%Y%m%d-%H%M")
BACKUP_FILE="${BACKUP_DIR}/${BACKUP_PREFIX}-${TIMESTAMP}.tar.gz"
LOG_FILE="${BACKUP_DIR}/backup-${TIMESTAMP}.log"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1" | tee -a "$LOG_FILE"
    exit 1
}

warn() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] WARN:${NC} $1" | tee -a "$LOG_FILE"
}

# 检查目录是否存在
check_directories() {
    log "检查目录..."
    
    if [ ! -d "$KNOWLEDGE_DIR" ]; then
        error "知识库目录不存在: $KNOWLEDGE_DIR"
    fi
    
    if [ ! -d "$BACKUP_DIR" ]; then
        warn "备份目录不存在，创建中: $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR" || error "无法创建备份目录"
    fi
    
    log "目录检查完成"
}

# 检查知识库内容
check_knowledge_content() {
    log "检查知识库内容..."
    
    local file_count=$(find "$KNOWLEDGE_DIR" -type f -name "*.md" | wc -l)
    if [ "$file_count" -eq 0 ]; then
        warn "知识库中没有找到 .md 文件"
    else
        log "找到 $file_count 个 .md 文件"
    fi
    
    # 检查关键文件
    local key_files=(
        "$KNOWLEDGE_DIR/charter/knowledge-base-management-policy.md"
        "$KNOWLEDGE_DIR/operations/knowledge-base-management-policy.md"
    )
    
    for file in "${key_files[@]}"; do
        if [ -f "$file" ]; then
            log "关键文件存在: $(basename "$file")"
        else
            warn "关键文件不存在: $(basename "$file")"
        fi
    done
    
    log "内容检查完成"
}

# 执行备份
perform_backup() {
    log "开始备份..."
    
    # 创建备份
    cd "$(dirname "$KNOWLEDGE_DIR")" || error "无法切换到父目录"
    tar -czf "$BACKUP_FILE" "$(basename "$KNOWLEDGE_DIR")" 2>/dev/null || error "备份失败"
    
    # 检查备份文件
    if [ -f "$BACKUP_FILE" ]; then
        local backup_size=$(du -h "$BACKUP_FILE" | cut -f1)
        log "备份成功: $BACKUP_FILE ($backup_size)"
    else
        error "备份文件未创建"
    fi
    
    log "备份完成"
}

# 清理旧备份（保留最近7天）
cleanup_old_backups() {
    log "清理旧备份（保留最近7天）..."
    
    local backup_files=($(find "$BACKUP_DIR" -name "${BACKUP_PREFIX}-*.tar.gz" -type f))
    local total_files=${#backup_files[@]}
    
    if [ "$total_files" -gt 7 ]; then
        local files_to_delete=$(($total_files - 7))
        log "找到 $total_files 个备份文件，删除 $files_to_delete 个旧文件"
        
        # 按时间排序，删除最旧的
        find "$BACKUP_DIR" -name "${BACKUP_PREFIX}-*.tar.gz" -type f -printf '%T@ %p\n' | \
            sort -n | \
            head -n "$files_to_delete" | \
            cut -d' ' -f2- | \
            while read -r old_file; do
                rm -f "$old_file"
                log "删除旧备份: $(basename "$old_file")"
            done
    else
        log "备份文件数量 ($total_files) 不超过7个，无需清理"
    fi
    
    log "清理完成"
}

# 生成备份报告
generate_report() {
    log "生成备份报告..."
    
    local report_file="${BACKUP_DIR}/backup-report-${TIMESTAMP}.md"
    
    cat > "$report_file" << EOF
# 知识库备份报告

**备份时间：** $(date '+%Y-%m-%d %H:%M:%S')
**执行者：** 泽塔 ⚙️ (备份执行人)
**备份目录：** $KNOWLEDGE_DIR
**备份文件：** $(basename "$BACKUP_FILE")

## 备份详情

### 文件统计
- 备份文件大小：$(du -h "$BACKUP_FILE" | cut -f1)
- 知识库目录大小：$(du -sh "$KNOWLEDGE_DIR" | cut -f1)
- .md 文件数量：$(find "$KNOWLEDGE_DIR" -type f -name "*.md" | wc -l)

### 关键文件检查
EOF
    
    # 检查关键文件
    local key_files=(
        "$KNOWLEDGE_DIR/charter/knowledge-base-management-policy.md"
        "$KNOWLEDGE_DIR/operations/knowledge-base-management-policy.md"
        "$KNOWLEDGE_DIR/charter/disaster-recovery-policy.md"
        "$KNOWLEDGE_DIR/operations/disaster-recovery-policy.md"
    )
    
    for file in "${key_files[@]}"; do
        if [ -f "$file" ]; then
            echo "- ✅ $(basename "$file") - 存在" >> "$report_file"
        else
            echo "- ❌ $(basename "$file") - 缺失" >> "$report_file"
        fi
    done
    
    cat >> "$report_file" << EOF

### 备份历史
EOF
    
    # 列出最近的备份
    find "$BACKUP_DIR" -name "${BACKUP_PREFIX}-*.tar.gz" -type f -printf '%T@ %p\n' | \
        sort -rn | \
        head -n 5 | \
        cut -d' ' -f2- | \
        while read -r backup; do
            local size=$(du -h "$backup" | cut -f1)
            local name=$(basename "$backup")
            echo "- $name ($size)" >> "$report_file"
        done
    
    cat >> "$report_file" << EOF

## 状态
- **备份状态：** ✅ 成功
- **下次备份：** 根据备份计划 (10:00/14:00/18:00/23:30)

---

*备份执行人：泽塔 ⚙️*  
*根据《知识库管理办法》执行定时备份职责*
EOF
    
    log "备份报告生成: $(basename "$report_file")"
}

# 主函数
main() {
    log "========================================"
    log "知识库备份开始 - 泽塔 ⚙️"
    log "========================================"
    
    check_directories
    check_knowledge_content
    perform_backup
    cleanup_old_backups
    generate_report
    
    log "========================================"
    log "知识库备份完成"
    log "========================================"
    
    # 通知（可选）
    # echo "知识库备份完成: $BACKUP_FILE" | 发送到通知系统
}

# 执行主函数
main "$@"