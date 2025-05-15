import argparse
import re
import random
import pandas as pd
from collections import defaultdict

def parse_filename(filename):
    """从文件名中提取编号信息"""
    match = re.match(r'(\d+),(\d+)_(\d+)\.txt', filename.strip())
    if match:
        category_id = int(match.group(1))
        primary_id = match.group(2)
        secondary_id = match.group(3)
        return category_id, primary_id, secondary_id
    return None

def split_data_by_category(file_list, train_ratio=0.8, seed=42):
    """按类别划分数据集，确保每个类别的划分比例相同"""
    random.seed(seed)
    
    # 按类别组织文件
    category_files = defaultdict(list)
    for file in file_list:
        parsed = parse_filename(file)
        if parsed:
            category_id, _, _ = parsed
            category_files[category_id].append(file)
    
    train_files = []
    test_files = []
    
    # 对每个类别进行划分
    for category_id, files in category_files.items():
        # 确保文件列表的随机性
        random.shuffle(files)
        
        # 计算划分点
        split_idx = int(len(files) * train_ratio)
        
        # 添加到训练集和测试集
        train_files.extend(files[:split_idx])
        test_files.extend(files[split_idx:])
    
    return train_files, test_files

def main():
    # 设置命令行参数
    parser = argparse.ArgumentParser(description='将文件列表按类别划分为训练集和测试集')
    parser.add_argument('input_file', default='resources/split_copy/train.txt', help='包含文件名列表的文本文件路径')
    parser.add_argument('--train_ratio', type=float, default=0.8, help='训练集比例 (默认: 0.8)')
    parser.add_argument('--seed', type=int, default=42, help='随机种子 (默认: 42)')
    parser.add_argument('--train_output', default='train_files.txt', help='训练集输出文件 (默认: train_files.txt)')
    parser.add_argument('--test_output', default='test_files.txt', help='测试集输出文件 (默认: test_files.txt)')
    parser.add_argument('--stats_output', default='split_statistics.csv', help='统计信息输出文件 (默认: split_statistics.csv)')
    
    args = parser.parse_args()
    
    # 读取输入文件名列表
    try:
        with open(args.input_file, 'r') as f:
            all_files = [line.strip() for line in f if line.strip()]
    except FileNotFoundError:
        print(f"错误: 找不到文件 '{args.input_file}'")
        return
    except IOError as e:
        print(f"错误: 无法读取文件 '{args.input_file}': {e}")
        return
    
    # 过滤有效的文件名
    valid_files = []
    for file in all_files:
        if parse_filename(file):
            valid_files.append(file)
        else:
            print(f"警告: 忽略无效的文件名格式: {file}")
    
    if not valid_files:
        print("错误: 未找到有效的文件名")
        return
    
    # 划分数据集
    train_files, test_files = split_data_by_category(valid_files, args.train_ratio, args.seed)
    
    # 保存划分结果
    with open(args.train_output, 'w') as f:
        for file in sorted(train_files):
            f.write(f"{file}\n")
    
    with open(args.test_output, 'w') as f:
        for file in sorted(test_files):
            f.write(f"{file}\n")
    
    # 保存统计信息
    category_stats = defaultdict(lambda: {'train': 0, 'test': 0, 'total': 0})
    
    for file in train_files:
        parsed = parse_filename(file)
        if parsed:
            category_id, _, _ = parsed
            category_stats[category_id]['train'] += 1
            category_stats[category_id]['total'] += 1
    
    for file in test_files:
        parsed = parse_filename(file)
        if parsed:
            category_id, _, _ = parsed
            category_stats[category_id]['test'] += 1
            category_stats[category_id]['total'] += 1
    
    # 创建统计DataFrame
    stats_data = []
    for category_id, counts in sorted(category_stats.items()):
        train_count = counts['train']
        test_count = counts['test']
        total = counts['total']
        train_ratio = train_count / total if total > 0 else 0
        test_ratio = test_count / total if total > 0 else 0
        
        stats_data.append({
            '类别ID': category_id,
            '训练集数量': train_count,
            '测试集数量': test_count,
            '总数': total,
            '训练集比例': f"{train_ratio:.2%}",
            '测试集比例': f"{test_ratio:.2%}"
        })
    
    stats_df = pd.DataFrame(stats_data)
    
    # 输出统计信息
    print("数据集划分结果:")
    print(f"总文件数: {len(valid_files)}")
    print(f"训练集: {len(train_files)} 文件 ({len(train_files)/len(valid_files):.2%})")
    print(f"测试集: {len(test_files)} 文件 ({len(test_files)/len(valid_files):.2%})")
    print("\n按类别划分统计:")
    print(stats_df.to_string(index=False))
    
    # 保存统计信息到CSV
    stats_df.to_csv(args.stats_output, index=False, encoding='utf-8-sig')
    print(f"\n统计信息已保存到 {args.stats_output}")
    print(f"训练集文件列表已保存到 {args.train_output}")
    print(f"测试集文件列表已保存到 {args.test_output}")

if __name__ == "__main__":
    main()