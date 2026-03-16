#!/bin/bash
# 回退 Anthropic SDK 补丁 - message_delta 事件缓冲
# 用法: bash rollback-sdk-patch.sh
BACKUP="/home/gang/.npm-global/lib/node_modules/openclaw/node_modules/@anthropic-ai/sdk/lib/MessageStream.js.bak"
TARGET="/home/gang/.npm-global/lib/node_modules/openclaw/node_modules/@anthropic-ai/sdk/lib/MessageStream.js"
if [ -f "$BACKUP" ]; then
    cp "$BACKUP" "$TARGET"
    echo "✅ 已回退 SDK 补丁。重启 gateway 生效: openclaw gateway restart"
else
    echo "❌ 备份文件不存在: $BACKUP"
fi
