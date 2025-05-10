#!/bin/bash

BASE_DIR="/media/sdb2/K-Radar/kradar"

# 创建临时目录
TEMP_DIR="/tmp/kradar_pcd_check"
mkdir -p "$TEMP_DIR"

# 定义我们发现的相同description.txt的组
GROUP1="16 17"                                    # 哈希值 6107e9a69882513350ed4e11323ea718
GROUP2="5 14 15 18 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58"  # 哈希值 7152b6bc9d9ec08ec71b70a6a9114e9a
GROUP3="9 10 11 12"                               # 哈希值 778ef4585f2821afbed0b7b3e754f969
GROUP4="2 3 4"                                    # 哈希值 ae8b838b30b8b584efcb4ae1e1e3fb27
GROUP5="1 6"                                      # 哈希值 f1ca2612c93f750dee6b93fcfbdfc571

# 检查函数 - 针对特定组内的第一个PCD文件进行MD5比较
check_group() {
    local group=$1
    local group_name=$2
    
    echo "检查 $group_name 组内的PCD文件是否相同..."
    
    # 取组内第一个目录作为参考
    local first_dir=$(echo $group | awk '{print $1}')
    local first_pcd=""
    
    # 查找第一个PCD文件
    if [ -d "$BASE_DIR/$first_dir/os2-64" ]; then
        first_pcd=$(ls "$BASE_DIR/$first_dir/os2-64" | head -n 1)
        if [ -n "$first_pcd" ]; then
            echo "参考文件: $first_dir/os2-64/$first_pcd"
            # 计算参考文件的MD5
            md5sum "$BASE_DIR/$first_dir/os2-64/$first_pcd" > "$TEMP_DIR/${group_name}_${first_dir}_${first_pcd}.md5"
            
            # 对组内其他目录的同名文件进行比较
            for dir in $group; do
                if [ "$dir" != "$first_dir" ] && [ -f "$BASE_DIR/$dir/os2-64/$first_pcd" ]; then
                    md5sum "$BASE_DIR/$dir/os2-64/$first_pcd" > "$TEMP_DIR/${group_name}_${dir}_${first_pcd}.md5"
                fi
            done
            
            # 检查组内此文件的MD5是否相同
            echo "组 $group_name 中 $first_pcd 文件的MD5对比:"
            cat "$TEMP_DIR/${group_name}"_*_"${first_pcd}.md5"
            
            # 检查是否完全相同
            local md5_count=$(cat "$TEMP_DIR/${group_name}"_*_"${first_pcd}.md5" | awk '{print $1}' | sort | uniq | wc -l)
            if [ "$md5_count" -eq 1 ]; then
                echo "结果: 组 $group_name 中所有目录的 $first_pcd 文件内容完全相同"
            else
                echo "结果: 组 $group_name 中的 $first_pcd 文件内容不完全相同"
            fi
            echo ""
        else
            echo "警告: $first_dir/os2-64 目录中没有找到PCD文件"
        fi
    else
        echo "警告: $first_dir/os2-64 目录不存在"
    fi
}

# 检查每个组
check_group "$GROUP1" "GROUP1"
check_group "$GROUP2" "GROUP2"
check_group "$GROUP3" "GROUP3"
check_group "$GROUP4" "GROUP4"
check_group "$GROUP5" "GROUP5"

# 清理临时目录
rm -rf "$TEMP_DIR"