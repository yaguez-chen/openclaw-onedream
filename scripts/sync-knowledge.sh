#!/bin/bash
cd /home/gang/.openclaw/workspace/shared-knowledge
git add -A
git diff --cached --quiet && exit 0
git commit -m "知识库自动同步: $(date '+%Y-%m-%d %H:%M')"
git push origin main 2>&1
