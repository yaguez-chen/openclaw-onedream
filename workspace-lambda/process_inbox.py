#!/usr/bin/env python3
import os
import json
import glob
import shutil
import datetime
from pathlib import Path

def process_inbox_scan():
    """扫描所有workspace的inbox目录，处理未读消息"""
    
    # 所有workspace路径
    workspaces = [
        "alpha", "beta", "gamma", "delta", "epsilon", "zeta",
        "eta", "theta", "iota", "kappa", "lambda"
    ]
    
    base_path = "/home/gang/.openclaw/workspace-{}/inbox"
    
    total_processed = 0
    total_unread = 0
    results = []
    
    for workspace in workspaces:
        inbox_path = base_path.format(workspace)
        
        # 确保archive目录存在
        archive_path = os.path.join(inbox_path, "archive")
        os.makedirs(archive_path, exist_ok=True)
        
        # 查找所有msg-*.json文件
        msg_pattern = os.path.join(inbox_path, "msg-*.json")
        msg_files = glob.glob(msg_pattern)
        
        workspace_unread = 0
        workspace_processed = 0
        
        for msg_file in msg_files:
            try:
                with open(msg_file, 'r', encoding='utf-8') as f:
                    msg_data = json.load(f)
                
                # 检查是否为未读消息
                if msg_data.get('read', True) == False:
                    workspace_unread += 1
                    total_unread += 1
                    
                    # 处理消息（这里简单打印）
                    msg_id = msg_data.get('id', 'unknown')
                    from_agent = msg_data.get('from', 'unknown')
                    to_agent = msg_data.get('to', 'unknown')
                    content = msg_data.get('content', '')
                    
                    print(f"[处理] {workspace}: {msg_id} from {from_agent} to {to_agent}")
                    print(f"      内容: {content[:100]}..." if len(content) > 100 else f"      内容: {content}")
                    
                    # 标记为已读
                    msg_data['read'] = True
                    msg_data['read_at'] = datetime.datetime.now().isoformat()
                    
                    # 如果需要确认，创建ack文件
                    if msg_data.get('ack_required', False):
                        ack_data = {
                            'id': f"ack-{msg_id}",
                            'original_msg_id': msg_id,
                            'from': to_agent,  # 接收方确认
                            'to': from_agent,  # 发送给原发送方
                            'content': f"消息 {msg_id} 已收到",
                            'ack_at': datetime.datetime.now().isoformat(),
                            'status': 'received'
                        }
                        
                        # 找到发送方的inbox路径
                        sender_workspace = from_agent.split('-')[0] if '-' in from_agent else from_agent
                        sender_inbox = base_path.format(sender_workspace)
                        
                        if os.path.exists(sender_inbox):
                            ack_file = os.path.join(sender_inbox, f"ack-{msg_id}.json")
                            with open(ack_file, 'w', encoding='utf-8') as f:
                                json.dump(ack_data, f, indent=2, ensure_ascii=False)
                            print(f"      已发送确认到 {sender_workspace}")
                    
                    # 保存更新后的消息文件
                    with open(msg_file, 'w', encoding='utf-8') as f:
                        json.dump(msg_data, f, indent=2, ensure_ascii=False)
                    
                    # 归档消息
                    archive_file = os.path.join(archive_path, os.path.basename(msg_file))
                    shutil.move(msg_file, archive_file)
                    
                    workspace_processed += 1
                    total_processed += 1
                    
            except Exception as e:
                print(f"[错误] 处理文件 {msg_file} 时出错: {e}")
        
        # 检查ack-*.json文件并更新outbox/sent-log.jsonl
        ack_pattern = os.path.join(inbox_path, "ack-*.json")
        ack_files = glob.glob(ack_pattern)
        
        for ack_file in ack_files:
            try:
                with open(ack_file, 'r', encoding='utf-8') as f:
                    ack_data = json.load(f)
                
                # 更新outbox/sent-log.jsonl
                outbox_path = f"/home/gang/.openclaw/workspace-{workspace}/outbox"
                sent_log_path = os.path.join(outbox_path, "sent-log.jsonl")
                
                os.makedirs(outbox_path, exist_ok=True)
                
                log_entry = {
                    'timestamp': datetime.datetime.now().isoformat(),
                    'type': 'ack_received',
                    'ack_id': ack_data.get('id'),
                    'original_msg_id': ack_data.get('original_msg_id'),
                    'from': ack_data.get('from'),
                    'to': ack_data.get('to')
                }
                
                with open(sent_log_path, 'a', encoding='utf-8') as f:
                    f.write(json.dumps(log_entry, ensure_ascii=False) + '\n')
                
                # 归档ack文件
                archive_ack = os.path.join(archive_path, os.path.basename(ack_file))
                shutil.move(ack_file, archive_ack)
                
            except Exception as e:
                print(f"[错误] 处理ack文件 {ack_file} 时出错: {e}")
        
        if workspace_unread > 0:
            results.append(f"{workspace}: 发现 {workspace_unread} 条未读消息，处理了 {workspace_processed} 条")
    
    # 汇总结果
    print(f"\n=== 扫描完成 ===")
    print(f"总共发现 {total_unread} 条未读消息")
    print(f"总共处理了 {total_processed} 条消息")
    
    for result in results:
        print(result)
    
    return total_processed

if __name__ == "__main__":
    processed = process_inbox_scan()
    print(f"\n处理完成，共处理了 {processed} 条消息")