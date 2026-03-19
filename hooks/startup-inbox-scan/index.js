/**
 * Hook handler for startup-inbox-scan
 * Trigger: gateway:startup
 * 
 * 当 Gateway 启动时，扫描所有 Agent 的 inbox 目录，
 * 发现未读消息后触发对应的 Agent 处理
 */
module.exports = async function handler(event) {
  // 只处理 gateway:startup 事件
  if (event.type !== 'gateway' || event.action !== 'startup') {
    return;
  }

  console.log('[startup-inbox-scan] Gateway 启动，开始扫描所有 Agent inbox...');

  try {
    const { exec } = require('child_process');
    const { promisify } = require('util');
    const execAsync = promisify(exec);

    // 所有 Agent 列表
    const agents = [
      'alpha', 'beta', 'gamma', 'delta', 'epsilon', 
      'zeta', 'eta', 'theta', 'iota', 'kappa', 'lambda'
    ];

    for (const agent of agents) {
      const workspace = `/home/gang/.openclaw/workspace-${agent}`;
      const inbox = `${workspace}/inbox`;
      const lastRead = `${inbox}/.last-read`;

      // 检查 inbox 目录是否存在
      try {
        await execAsync(`[ -d "${inbox}" ] && echo "exists" || echo "missing"`);
      } catch {
        // 目录不存在，跳过
        continue;
      }

      // 检查是否有 .last-read 文件
      let hasLastRead = false;
      try {
        await execAsync(`[ -f "${lastRead}" ] && echo "exists"`);
        hasLastRead = true;
      } catch {
        hasLastRead = false;
      }

      if (!hasLastRead) {
        // 检查是否有任何消息文件
        try {
          const { stdout } = await execAsync(`find "${inbox}" -name "msg-*.json" -maxdepth 1 2>/dev/null | head -1`);
          if (stdout.trim()) {
            console.log(`[startup-inbox-scan] ⚠️  ${agent}: 有消息但无 .last-read，创建初始指针`);
            await execAsync(`touch "${lastRead}"`);
          } else {
            continue;
          }
        } catch {
          continue;
        }
      }

      // 查找比 .last-read 新的消息文件
      try {
        const { stdout } = await execAsync(`find "${inbox}" -name "msg-*.json" -newer "${lastRead}" 2>/dev/null | head -1`);
        if (stdout.trim()) {
          console.log(`[startup-inbox-scan] 📬 ${agent}: 发现未读消息，触发处理`);
          
          // 调用 webhook 触发该 Agent
          const hooksToken = process.env.OPENCLAW_HOOKS_TOKEN || '8d54e4627c496b7c2c0fc8abab6fa5a8cbf4ddbb85cfa42e39b83c30e6b4d9a3';
          const webhookUrl = 'http://127.0.0.1:18789/hooks/agent';
          const payload = JSON.stringify({
            message: `Gateway 重启后扫描到未读消息，请检查 inbox/`,
            agentId: agent,
            name: 'StartupScan',
            deliver: false,
            timeoutSeconds: 30
          });

          await execAsync(`curl -s -X POST "${webhookUrl}" \
            -H "Authorization: Bearer ${hooksToken}" \
            -H "Content-Type: application/json" \
            -d '${payload}'`);
        } else {
          console.log(`[startup-inbox-scan] ✅ ${agent}: 无未读消息`);
        }
      } catch (error) {
        console.log(`[startup-inbox-scan] ⚠️  ${agent}: 扫描失败`, error.message);
      }
    }

    console.log('[startup-inbox-scan] 🎯 Gateway 启动扫描完成！');
  } catch (error) {
    console.error('[startup-inbox-scan] ❌ 扫描过程中出错:', error.message);
  }
};
