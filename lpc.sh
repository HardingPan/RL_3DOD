#!/bin/bash

# 设置日志文件
LOG_FILE="/media/sdb2/K-Radar/lpc_process_$(date +%Y%m%d_%H%M%S).log"
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

log "开始处理LPC数据..."
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
    
    # 处理 LPC 文件夹或压缩包
    LPC_FOLDER="${FOLDER_PATH}/${folder}_lpc"
    LPC_ZIP=$(find "$FOLDER_PATH" -name "${folder}_lpc*.zip" -type f | head -n 1)
    
    if [ -d "$LPC_FOLDER" ]; then
        log "找到已解压的lpc文件夹 $LPC_FOLDER"
        # 查找os2-64文件夹
        OS2_64_FOLDER=$(find "$LPC_FOLDER" -name "os2-64" -type d | head -n 1)
        
        if [ -n "$OS2_64_FOLDER" ]; then
            log "使用rsync复制 os2-64 文件夹..."
            rsync_copy "$OS2_64_FOLDER/" "$TARGET_FOLDER/os2-64/"
        else
            log "警告: 未在 $LPC_FOLDER 中找到 os2-64 文件夹"
        fi
    elif [ -n "$LPC_ZIP" ]; then
        log "找到lpc压缩包 $LPC_ZIP，解压中..."
        # 使用 ramdisk 作为临时解压目录
        unzip -q "$LPC_ZIP" -d "$TEMP_DIR/lpc"
        
        # 寻找 os2-64 文件夹
        OS2_64_FOLDER=$(find "$TEMP_DIR/lpc" -name "os2-64" -type d | head -n 1)
        
        if [ -n "$OS2_64_FOLDER" ]; then
            log "使用rsync复制 os2-64 文件夹..."
            rsync_copy "$OS2_64_FOLDER/" "$TARGET_FOLDER/os2-64/"
        else
            log "警告: 在解压的lpc压缩包中未找到 os2-64 文件夹"
        fi
        
        log "清理临时lpc文件..."
        clean_dir "$TEMP_DIR/lpc"
    else
        log "警告: 未找到 ${folder}_lpc 文件夹或压缩包"
    fi
    
    log "完成处理文件夹 $folder"
    
    # 每处理完一个文件夹就清理一次临时目录，减少内存占用
    clean_dir "$TEMP_DIR"
done

# 清理临时目录
clean_dir "$RAMDISK"

log "所有LPC数据处理完成!"

# 显示结果统计
PROCESSED_FOLDERS=$(find "$TARGET_DIR" -mindepth 1 -maxdepth 1 -type d | wc -l)
log "共处理了 $PROCESSED_FOLDERS 个文件夹"

# 可选：卸载ramdisk
sudo umount "$RAMDISK"
sudo rmdir "$RAMDISK"