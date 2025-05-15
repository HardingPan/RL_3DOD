#!/bin/bash

# 基础路径
SOURCE_BASE="/media/sdb2/K-Radar/sparse_cube"
TARGET_BASE="/media/sdb2/K-Radar/minikradar"

# 遍历每个数字文件夹
for dir in 1 2 3 4 5 6 7 8 10 11 12 15 16 17 18 19 20; do
    # 确保源文件夹存在
    if [ -d "$SOURCE_BASE/$dir/sp_rdr_cube" ]; then
        echo "处理文件夹 $dir..."
        
        # 重命名源文件夹
        mv "$SOURCE_BASE/$dir/sp_rdr_cube" "$SOURCE_BASE/$dir/sparse_cube"
        
        # 确保目标目录存在
        if [ -d "$TARGET_BASE/$dir" ]; then
            # 复制到目标位置
            cp -r "$SOURCE_BASE/$dir/sparse_cube" "$TARGET_BASE/$dir/"
            echo "已复制 sparse_cube 到 $TARGET_BASE/$dir/"
        else
            echo "警告: 目标文件夹 $TARGET_BASE/$dir 不存在"
        fi
    else
        echo "警告: 源文件夹 $SOURCE_BASE/$dir/sp_rdr_cube 不存在"
    fi
done

echo "完成!"