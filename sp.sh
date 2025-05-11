#!/bin/bash

# 设置日志文件
LOG_FILE="/media/sdb2/K-Radar/process_$(date +%Y%m%d_%H%M%S).log"
BASE_DIR="/media/sdb2/K-Radar"
TARGET_DIR="/media/sdb2/K-Radar/kradar"

# 创建一个 1TB ramdisk 作为临时解压目录
RAMDISK="/mnt/ramdisk"
if [ ! -d "$RAMDISK" ]; then
    sudo mkdir -p "$RAMDISK"
    sudo mount -t tmpfs -o size=5t tmpfs "$RAMDISK"
    sudo chmod 777 "$RAMDISK"
fi

# 创建目标目录
mkdir -p "$TARGET_DIR"

# 记录日志的函数
log() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" | tee -a "$LOG_FILE"
}

# 高效清理目录函数
clean_dir() {
    local dir="$1"
    if [ -d "$dir" ]; then
        find "$dir" -mindepth 1 -delete
    fi
}

# 使用rsync进行高效复制
rsync_copy() {
    local src="$1"
    local dst="$2"
    
    if [ -e "$src" ]; then
        rsync -a --info=progress2 "$src" "$dst"
        return $?
    else
        return 1
    fi
}

log "开始处理数据..."
log "目标目录: $TARGET_DIR"
log "使用 1TB ramdisk 作为临时目录: $RAMDISK"

# 处理1到58的文件夹
for folder in $(seq 1 58); do
    FOLDER_PATH="$BASE_DIR/$folder"
    TARGET_FOLDER="$TARGET_DIR/$folder"
    TEMP_DIR="$RAMDISK/$folder"
    
    if [ ! -d "$FOLDER_PATH" ]; then
        log "文件夹 $folder 不存在，跳过"
        continue
    fi
    
    log "处理文件夹 $folder..."
    
    # 清理并重新创建临时目录
    clean_dir "$TEMP_DIR"
    mkdir -p "$TEMP_DIR"
    mkdir -p "$TARGET_FOLDER"

    # 处理 {}_rt 文件夹或压缩包
    RT_FOLDER="${FOLDER_PATH}/${folder}_rt"
    RT_ZIP=$(find "$FOLDER_PATH" -name "${folder}_rt*.zip" -type f | head -n 1)
    
    if [ -d "$RT_FOLDER" ]; then
        log "找到已解压的rt文件夹 $RT_FOLDER"
        if [ -d "${RT_FOLDER}/radar_zyx_cube" ]; then
            log "使用rsync复制 radar_zyx_cube 文件夹..."
            rsync_copy "${RT_FOLDER}/radar_zyx_cube/" "$TARGET_FOLDER/radar_zyx_cube/"
        else
            log "警告: ${RT_FOLDER}/radar_zyx_cube 不存在"
        fi
    elif [ -n "$RT_ZIP" ]; then
        log "找到rt压缩包 $RT_ZIP，解压中..."
        # 使用 ramdisk 作为临时解压目录
        unzip -q "$RT_ZIP" -d "$TEMP_DIR/rt"
        
        # 寻找 radar_zyx_cube 文件夹
        RADAR_CUBE=$(find "$TEMP_DIR/rt" -name "radar_zyx_cube" -type d | head -n 1)
        
        if [ -n "$RADAR_CUBE" ]; then
            log "使用rsync复制 radar_zyx_cube 文件夹..."
            rsync_copy "$RADAR_CUBE/" "$TARGET_FOLDER/radar_zyx_cube/"
        else
            log "警告: 在解压的rt压缩包中未找到 radar_zyx_cube 文件夹"
        fi
        
        log "清理临时rt文件..."
        clean_dir "$TEMP_DIR/rt"
    else
        log "警告: 未找到 ${folder}_rt 文件夹或压缩包"
    fi
    
    log "完成处理文件夹 $folder"
    
    # 每处理完一个文件夹就清理一次临时目录，减少内存占用
    clean_dir "$TEMP_DIR"
done

# 清理临时目录
clean_dir "$RAMDISK"

log "所有数据处理完成!"

# 显示结果统计
PROCESSED_FOLDERS=$(find "$TARGET_DIR" -mindepth 1 -maxdepth 1 -type d | wc -l)
log "共处理了 $PROCESSED_FOLDERS 个文件夹"

# 可选：卸载ramdisk
sudo umount "$RAMDISK"
sudo rmdir "$RAMDISK"