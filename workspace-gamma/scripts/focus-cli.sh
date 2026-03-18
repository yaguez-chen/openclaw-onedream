#!/bin/bash
# focus-cli.sh — Focus Item 增删改查工具（Python 实现）
# 用法：
#   ./focus-cli.sh add "任务标题" <触发器类型> [依赖ID] [来源]
#   ./focus-cli.sh done <ID>
#   ./focus-cli.sh block <ID> "原因"
#   ./focus-cli.sh list
#   ./focus-cli.sh status <ID> <新状态>
#
# 作者：伽马 🔧 | 日期：2026-03-18

FOCUS_FILE="/home/gang/.openclaw/workspace-gamma/focus-items.json"
mkdir -p "$(dirname "$FOCUS_FILE")"

# 初始化文件
if [ ! -f "$FOCUS_FILE" ]; then
  echo '{"items":[]}' > "$FOCUS_FILE"
fi

CMD=${1:-list}

case "$CMD" in
  add)
    TITLE=$2
    TRIGGER_TYPE=${3:-heartbeat}
    DEP=${4:-none}
    SOURCE=${5:-manual}
    [ -z "$TITLE" ] && { echo "用法: $0 add \"任务标题\" [触发器类型] [依赖ID] [来源]"; exit 1; }
    
    python3 << EOF
import json
import sys
import os
from datetime import datetime

focus_file = "$FOCUS_FILE"
title = "$TITLE"
trigger_type = "$TRIGGER_TYPE"
dep = "$DEP"
source = "$SOURCE"

# 读取现有数据
with open(focus_file, 'r') as f:
    data = json.load(f)

# 生成新 ID
next_id = len(data['items']) + 1
new_id = f"F{next_id:03d}"

# 构建触发器
if trigger_type.startswith("dep:"):
    trigger = {"type": "dep", "condition": trigger_type[4:]}
elif trigger_type.startswith("event:"):
    trigger = {"type": "event", "condition": trigger_type[6:]}
elif trigger_type.startswith("cron:"):
    trigger = {"type": "cron", "interval": trigger_type[5:]}
else:
    trigger = {"type": "heartbeat"}

# 添加项目
now = datetime.now().isoformat()
new_item = {
    "id": new_id,
    "title": title,
    "status": "active",
    "trigger": trigger,
    "dependencies": [] if dep == "none" else [dep],
    "source": source,
    "created": now,
    "updated": now
}
data['items'].append(new_item)

# 保存
with open(focus_file, 'w') as f:
    json.dump(data, f, indent=2)

print(f"✅ 已添加 [{new_id}] {title} (触发器: {trigger_type})")
EOF
    ;;
    
  done|complete)
    ID=$2
    [ -z "$ID" ] && { echo "用法: $0 done <ID>"; exit 1; }
    
    python3 << EOF
import json
from datetime import datetime

focus_file = "$FOCUS_FILE"
target_id = "$ID"

with open(focus_file, 'r') as f:
    data = json.load(f)

for item in data['items']:
    if item['id'] == target_id:
        item['status'] = 'completed'
        item['updated'] = datetime.now().isoformat()
        break

with open(focus_file, 'w') as f:
    json.dump(data, f, indent=2)

print(f"✅ [{target_id}] 已完成")
EOF
    ;;
    
  block)
    ID=$2
    REASON=${3:-"未说明"}
    [ -z "$ID" ] && { echo "用法: $0 block <ID> \"原因\""; exit 1; }
    
    python3 << EOF
import json
from datetime import datetime

focus_file = "$FOCUS_FILE"
target_id = "$ID"
reason = "$REASON"

with open(focus_file, 'r') as f:
    data = json.load(f)

for item in data['items']:
    if item['id'] == target_id:
        item['status'] = 'blocked'
        item['blockReason'] = reason
        item['updated'] = datetime.now().isoformat()
        break

with open(focus_file, 'w') as f:
    json.dump(data, f, indent=2)

print(f"🚫 [{target_id}] 已阻塞: {reason}")
EOF
    ;;
    
  list)
    python3 << EOF
import json

focus_file = "$FOCUS_FILE"

try:
    with open(focus_file, 'r') as f:
        data = json.load(f)
except FileNotFoundError:
    print("📭 暂无 Focus Items")
    sys.exit(0)

print("📋 Focus Items")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

for item in data['items']:
    status_icon = {
        'completed': '✅',
        'blocked': '🚫',
        'testing': '🧪',
        'active': '🔄'
    }.get(item['status'], '🔄')
    
    trigger_type = item['trigger']['type']
    print(f"{status_icon} [ {item['id']} ] {item['title']} | 触发器:{trigger_type} | 来源:{item['source']}")

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

total = len(data['items'])
active = len([i for i in data['items'] if i['status'] == 'active'])
completed = len([i for i in data['items'] if i['status'] == 'completed'])
print(f"📊 总计: {total} | 活跃: {active} | 已完成: {completed}")
EOF
    ;;
    
  *)
    echo "用法: $0 {add|done|block|list} ..."
    echo "  add \"标题\" [触发器类型] [依赖ID] [来源]"
    echo "  done <ID>"
    echo "  block <ID> \"原因\""
    echo "  list"
    ;;
esac
