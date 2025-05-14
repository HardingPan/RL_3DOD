#!/bin/bash

# 设置日志文件
LOG_FILE="/media/sdb2/K-Radar/process_$(date +%Y%m%d_%H%M%S).log"
BASE_DIR="/media/sdb2/K-Radar"
TARGET_DIR="/media/sdb2/K-Radar/kradar"

# 创建一个 100GB ramdisk 作为临时解压目录
RAMDISK="/mnt/ramdisk"
if [ ! -d "$RAMDISK" ]; then
    sudo mkdir -p "$RAMDISK"
    sudo mount -t tmpfs -o size=1t tmpfs "$RAMDISK"
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
log "使用 100GB ramdisk 作为临时目录: $RAMDISK"

# 处理1到58的文件夹
for folder in $(seq 13 13); do
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
    
    # 处理 {}_cam 文件夹或压缩包
    CAM_FOLDER="${FOLDER_PATH}/${folder}_cam"
    CAM_ZIP=$(find "$FOLDER_PATH" -name "${folder}_cam*.zip" -type f | head -n 1)
    
    if [ -d "$CAM_FOLDER" ]; then
        log "找到已解压的cam文件夹 $CAM_FOLDER"
        if [ -d "${CAM_FOLDER}/cam-front" ]; then
            log "使用rsync复制 cam-front 文件夹..."
            rsync_copy "${CAM_FOLDER}/cam-front/" "$TARGET_FOLDER/cam-front/"
        else
            log "警告: ${CAM_FOLDER}/cam-front 不存在"
        fi
    elif [ -n "$CAM_ZIP" ]; then
        log "找到cam压缩包 $CAM_ZIP，解压中..."
        # 使用 ramdisk 作为临时解压目录
        unzip -q "$CAM_ZIP" -d "$TEMP_DIR/cam"
        
        # 寻找 cam-front 文件夹
        CAM_FRONT=$(find "$TEMP_DIR/cam" -name "cam-front" -type d | head -n 1)
        
        if [ -n "$CAM_FRONT" ]; then
            log "使用rsync复制 cam-front 文件夹..."
            rsync_copy "$CAM_FRONT/" "$TARGET_FOLDER/cam-front/"
        else
            log "警告: 在解压的cam压缩包中未找到 cam-front 文件夹"
        fi
        
        log "清理临时cam文件..."
        clean_dir "$TEMP_DIR/cam"
    else
        log "警告: 未找到 ${folder}_cam 文件夹或压缩包"
    fi
    
    # 处理 {}_meta 文件夹或压缩包
    META_FOLDER="${FOLDER_PATH}/${folder}_meta"
    META_ZIP=$(find "$FOLDER_PATH" -name "${folder}_meta*.zip" -type f | head -n 1)
    
    if [ -d "$META_FOLDER" ]; then
        log "找到已解压的meta文件夹 $META_FOLDER"
        for file in "description.txt" "info_calib" "info_label" "time_info"; do
            if [ -e "${META_FOLDER}/$file" ]; then
                log "使用rsync复制 $file..."
                rsync_copy "${META_FOLDER}/$file" "$TARGET_FOLDER/"
            else
                log "警告: ${META_FOLDER}/$file 不存在"
            fi
        done
    elif [ -n "$META_ZIP" ]; then
        log "找到meta压缩包 $META_ZIP，解压中..."
        # 使用 ramdisk 作为临时解压目录
        unzip -q "$META_ZIP" -d "$TEMP_DIR/meta"
        
        # 寻找元数据文件
        for file in "description.txt" "info_calib" "info_label" "time_info"; do
            FILE_PATH=$(find "$TEMP_DIR/meta" -name "$file" | head -n 1)
            if [ -n "$FILE_PATH" ]; then
                log "使用rsync复制 $file..."
                rsync_copy "$FILE_PATH" "$TARGET_FOLDER/"
            else
                log "警告: 在解压的meta压缩包中未找到 $file"
            fi
        done
        
        log "清理临时meta文件..."
        clean_dir "$TEMP_DIR/meta"
    else
        log "警告: 未找到 ${folder}_meta 文件夹或压缩包"
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