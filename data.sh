#!/bin/bash

# 源目录和目标目录的基础路径
SOURCE_BASE="/media/sdb2/K-Radar"
TARGET_BASE="/media/sdb2/K-Radar/kradar"

# 需要保留的文件和文件夹列表
KEEP_FILES=(
    "cam-front"
    "info_calib"
    "os2-64"
    "spcube_outputs"
    "description.txt"
    "info_label"
    "radar_zyx_cube"
)

# 确保目标基础目录存在
mkdir -p "$TARGET_BASE"

# 创建临时目录用于解压
TEMP_DIR="/tmp/kradar_extract_temp"
mkdir -p "$TEMP_DIR"

# 遍历所有数字目录（从1到58）
for dir in $(seq 1 58); do
    source_dir="$SOURCE_BASE/$dir"
    target_dir="$TARGET_BASE/$dir"
    
    # 检查源目录是否存在
    if [ -d "$source_dir" ]; then
        echo "处理目录 $dir..."
        
        # 创建目标目录
        mkdir -p "$target_dir"
        
        # 进入源目录
        cd "$source_dir" || continue
        
        # 清空临时目录
        rm -rf "$TEMP_DIR/*"
        
        # 解压所有zip文件到临时目录
        for zip_file in *.zip; do
            if [ -f "$zip_file" ]; then
                echo "  临时解压 $zip_file"
                unzip -q -o "$zip_file" -d "$TEMP_DIR"
            fi
        done
        
        # 只复制需要的文件到目标目录
        echo "  复制所需文件到目标目录"
        for item in "${KEEP_FILES[@]}"; do
            if [ -e "$TEMP_DIR/$item" ]; then
                # 复制文件或目录
                cp -r "$TEMP_DIR/$item" "$target_dir/"
                echo "    已复制: $item"
            else
                echo "    未找到: $item"
            fi
        done
        
        # 清理临时目录
        rm -rf "$TEMP_DIR/*"
    else
        echo "警告：目录 $dir 不存在于源路径，跳过。"
    fi
done

# 删除临时目录
rm -rf "$TEMP_DIR"

echo "所有指定文件提取完成！"