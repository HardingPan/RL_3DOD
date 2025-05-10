#!/bin/bash

# 基础目录
BASE_DIR="/media/sdb2/K-Radar/kradar"

# 创建临时目录来存放所有图片
TEMP_DIR="/tmp/kradar_cam_front_samples"
mkdir -p "$TEMP_DIR"

# 定义我们发现的相同description.txt的组
GROUP1="16 17"
GROUP2="5 14 15 18 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58"
GROUP3="9 10 11 12"
GROUP4="2 3 4"
GROUP5="1 6"

# 所有组合并
ALL_DIRS="$GROUP1 $GROUP2 $GROUP3 $GROUP4 $GROUP5"

# 复制每个目录中的第一张图片到临时目录
for dir in $ALL_DIRS; do
  if [ -f "$BASE_DIR/$dir/cam-front/cam-front_00001.png" ]; then
    cp "$BASE_DIR/$dir/cam-front/cam-front_00001.png" "$TEMP_DIR/cam-front_${dir}_00001.png"
    echo "已复制: $dir/cam-front/cam-front_00001.png"
  else
    echo "警告: $dir/cam-front/cam-front_00001.png 不存在"
  fi
done

# 压缩临时目录
cd /tmp
tar -czf kradar_cam_front_samples.tar.gz -C /tmp kradar_cam_front_samples

echo "所有图片已收集到 /tmp/kradar_cam_front_samples.tar.gz"