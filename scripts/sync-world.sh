#!/bin/bash
cd /home/gang/.openclaw
# 先拉取子模块最新内容
git submodule update --remote 2>&1
# 再同步主仓库
git add -A
git diff --cached --quiet && exit 0
git commit -m "世界备份自动同步: $(date '+%Y-%m-%d %H:%M')"
git push origin main 2>&1
