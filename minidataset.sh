#!/bin/bash

# Define source and destination directories
SRC_DIR="/media/sdb2/K-Radar/kradar"
DEST_DIR="/media/sdb2/K-Radar/minikradar"

# Create destination directory if it doesn't exist
mkdir -p "$DEST_DIR"

# Counter for progress display
total_folders=$(find "$SRC_DIR" -maxdepth 1 -type d | wc -l)
processed=0

echo "Searching for folders containing required files..."
echo "Total folders to search: $total_folders"

# Check each numbered folder
for folder in "$SRC_DIR"/*; do
    if [ -d "$folder" ]; then
        folder_name=$(basename "$folder")
        
        # Skip if not a numbered folder
        if ! [[ "$folder_name" =~ ^[0-9]+$ ]]; then
            continue
        fi
        
        # Update progress
        processed=$((processed + 1))
        echo -ne "Checking folder $folder_name ($processed/$total_folders)... \r"
        
        # Check if folder contains all required files/directories
        if [ -d "$folder/cam-front" ] && 
           [ -f "$folder/description.txt" ] && 
           [ -d "$folder/os2-64" ] && 
           [ -d "$folder/radar_zyx_cube" ]; then
            
            echo "Found matching folder: $folder_name"
            echo "Copying $folder_name to destination..."
            
            # Create destination folder with same name
            mkdir -p "$DEST_DIR/$folder_name"
            
            # Use rsync to copy the folder
            # rsync -av --info=progress2 "$folder/cam-front" "$folder/description.txt" "$folder/os2-64" "$folder/radar_zyx_cube" "$DEST_DIR/$folder_name/"
            rsync -av --info=progress2 "$folder/info_calib" "$folder/time_info" "$folder/info_label" "$DEST_DIR/$folder_name/"
            
            echo "Completed copying folder $folder_name"
        fi
    fi
done

echo "All folders checked. Copy process completed."