#!/bin/bash
# 知识库定时备份配置脚本
# 配置 crontab 在 10:00/14:00/18:00/23:30 自动执行备份
# 作者：泽塔 ⚙️

set -e

BACKUP_SCRIPT="/home/gang/.openclaw/workspace-zeta/scripts/knowledge-base-backup.sh"
CRON_FILE="/home/gang/.openclaw/workspace-zeta/scripts/knowledge-base-crontab"
LOG_DIR="/home/gang/.openclaw/backup/cron-logs"
CURRENT_USER=$(whoami)

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] WARN:${NC} $1"
}

# 检查备份脚本
check_backup_script() {
    log "检查备份脚本..."
    
    if [ ! -f "$BACKUP_SCRIPT" ]; then
        warn "备份脚本不存在: $BACKUP_SCRIPT"
        return 1
    fi
    
    if [ ! -x "$BACKUP_SCRIPT" ]; then
        warn "备份脚本没有执行权限，正在添加..."
        chmod +x "$BACKUP_SCRIPT" || return 1
    fi
    
    log "备份脚本检查通过: $BACKUP_SCRIPT"
    return 0
}

# 创建日志目录
create_log_dir() {
    log "创建日志目录..."
    
    if [ ! -d "$LOG_DIR" ]; then
        mkdir -p "$LOG_DIR" || {
            warn "无法创建日志目录: $LOG_DIR"
            return 1
        }
        log "日志目录创建成功: $LOG_DIR"
    else
        log "日志目录已存在: $LOG_DIR"
    fi
    
    return 0
}

# 生成 crontab 配置
generate_crontab() {
    log "生成 crontab 配置..."
    
    cat > "$CRON_FILE" << EOF
# 知识库定时备份配置
# 备份执行人：泽塔 ⚙️
# 根据《知识库管理办法》配置定时备份
# 备份时间：10:00/14:00/18:00/23:30

# 10:00 - 上午备份
0 10 * * * $BACKUP_SCRIPT >> $LOG_DIR/backup-10-00.log 2>&1

# 14:00 - 下午备份  
0 14 * * * $BACKUP_SCRIPT >> $LOG_DIR/backup-14-00.log 2>&1

# 18:00 - 傍晚备份
0 18 * * * $BACKUP_SCRIPT >> $LOG_DIR/backup-18-00.log 2>&1

# 23:30 - 夜间备份
30 23 * * * $BACKUP_SCRIPT >> $LOG_DIR/backup-23-30.log 2>&1

# 每周日凌晨2:00清理旧日志
0 2 * * 0 find $LOG_DIR -name "*.log" -mtime +30 -delete
EOF
    
    log "crontab 配置生成成功: $CRON_FILE"
    
    # 显示配置内容
    echo ""
    echo "生成的 crontab 配置："
    echo "========================================"
    cat "$CRON_FILE"
    echo "========================================"
    echo ""
}

# 安装 crontab
install_crontab() {
    log "安装 crontab..."
    
    if ! command -v crontab &> /dev/null; then
        warn "crontab 命令未找到，请确保 cron 服务已安装"
        return 1
    fi
    
    # 备份现有 crontab
    local backup_file="/tmp/crontab-backup-$(date +%Y%m%d-%H%M%S)"
    crontab -l > "$backup_file" 2>/dev/null || true
    log "现有 crontab 已备份到: $backup_file"
    
    # 安装新的 crontab
    if crontab "$CRON_FILE"; then
        log "crontab 安装成功"
        
        # 验证安装
        echo ""
        echo "当前 crontab 配置："
        echo "========================================"
        crontab -l
        echo "========================================"
        echo ""
        
        return 0
    else
        warn "crontab 安装失败"
        return 1
    fi
}

# 显示安装说明
show_instructions() {
    echo ""
    echo "📋 知识库定时备份配置完成"
    echo "========================================"
    echo "备份执行人：泽塔 ⚙️"
    echo "备份脚本：$BACKUP_SCRIPT"
    echo "备份时间：10:00 / 14:00 / 18:00 / 23:30"
    echo "日志目录：$LOG_DIR"
    echo "当前用户：$CURRENT_USER"
    echo ""
    echo "✅ 配置已完成"
    echo ""
    echo "📊 手动验证："
    echo "1. 查看 crontab: crontab -l"
    echo "2. 查看 cron 服务状态: sudo systemctl status cron"
    echo "3. 测试备份脚本: $BACKUP_SCRIPT"
    echo ""
    echo "⚠️  注意事项："
    echo "- 确保 cron 服务正在运行"
    echo "- 检查日志目录权限"
    echo "- 备份脚本需要执行权限"
    echo "========================================"
    echo ""
}

# 主函数
main() {
    log "========================================"
    log "知识库定时备份配置开始 - 泽塔 ⚙️"
    log "========================================"
    
    if check_backup_script && create_log_dir; then
        generate_crontab
        install_crontab
        show_instructions
    else
        warn "配置失败，请检查错误信息"
        exit 1
    fi
    
    log "========================================"
    log "知识库定时备份配置完成"
    log "========================================"
}

# 执行主函数
main "$@"