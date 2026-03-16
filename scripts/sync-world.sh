#!/bin/bash
cd /home/gang/.openclaw
git add -A
git diff --cached --quiet && exit 0
git commit -m "世界备份自动同步: $(date '+%Y-%m-%d %H:%M')"
git push origin main 2>&1
