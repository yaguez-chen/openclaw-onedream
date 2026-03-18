#!/bin/bash
# check-focus-triggers.sh — 检查 Focus Item 触发条件（Python 实现）
# 用法：./check-focus-triggers.sh
#
# 作者：伽马 🔧 | 日期：2026-03-18 | 修复：jq → Python

FOCUS_FILE="/home/gang/.openclaw/workspace-gamma/focus-items.json"
LOG_FILE="/home/gang/.openclaw/workspace-gamma/logs/focus-triggers.log"

mkdir -p "$(dirname "$FOCUS_FILE")"
mkdir -p "$(dirname "$LOG_FILE")"

# 如果文件不存在，创建默认
if [ ! -f "$FOCUS_FILE" ]; then
  echo '{"items":[]}' > "$FOCUS_FILE"
fi

python3 << 'PYTHON_SCRIPT'
import json
import os
from datetime import datetime

focus_file = os.environ.get("FOCUS_FILE", "/home/gang/.openclaw/workspace-gamma/focus-items.json")
log_file = os.environ.get("LOG_FILE", "/home/gang/.openclaw/workspace-gamma/logs/focus-triggers.log")

# 读取数据
with open(focus_file, 'r') as f:
    data = json.load(f)

# 记录开始时间
with open(log_file, 'a') as log:
    log.write(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] === Focus 触发器检查开始 ===\n")

active_count = 0
triggered_count = 0

for item in data['items']:
    if item['status'] != 'active':
        continue
    
    active_count += 1
    item_id = item['id']
    title = item['title']
    trigger = item['trigger']
    trigger_type = trigger['type']
    triggered = False
    
    if trigger_type == 'heartbeat':
        print(f"  🔔 [{item_id}] {title} — 心跳触发")
        triggered = True
    elif trigger_type == 'event':
        condition = trigger.get('condition', '')
        event_file = f"/home/gang/.openclaw/workspace-gamma/events/{condition}.event"
        if os.path.exists(event_file):
            print(f"  📢 [{item_id}] {title} — 事件触发: {condition}")
            triggered = True
    elif trigger_type == 'dep':
        dep_id = trigger.get('condition', '')
        dep_status = None
        for dep_item in data['items']:
            if dep_item['id'] == dep_id:
                dep_status = dep_item['status']
                break
        if dep_status == 'completed':
            print(f"  🔗 [{item_id}] {title} — 依赖触发: {dep_id} 已完成")
            triggered = True
    elif trigger_type == 'cron':
        print(f"  ⏰ [{item_id}] {title} — 定时触发")
        triggered = True
    
    if triggered:
        triggered_count += 1
        item['lastTriggered'] = datetime.now().isoformat()

# 保存更新
with open(focus_file, 'w') as f:
    json.dump(data, f, indent=2)

with open(log_file, 'a') as log:
    log.write(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] 检查完成: {active_count} 个活跃任务, {triggered_count} 个触发\n")

print(f"📊 检查完成: {active_count} 个活跃任务, {triggered_count} 个触发")
PYTHON_SCRIPT
