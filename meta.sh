#!/bin/bash

# Set the base directory
BASE_DIR="/media/sdb2/K-Radar"

# Loop through directories 1 to 58
for dir in $(seq 1 58); do
    # Check if the directory exists
    if [ -d "$BASE_DIR/$dir" ]; then
        echo "===== Processing directory $dir ====="
        
        # Check if the meta zip file exists
        META_ZIP="${dir}_meta.zip"
        if [ -f "$BASE_DIR/$dir/$META_ZIP" ]; then
            # Create a temporary directory for extraction
            TEMP_DIR="$BASE_DIR/$dir/temp_extract"
            mkdir -p "$TEMP_DIR"
            
            # Extract the zip file to the temporary directory
            unzip -q "$BASE_DIR/$dir/$META_ZIP" -d "$TEMP_DIR"
            
            # Find and print the description.txt file
            DESC_FILE=$(find "$TEMP_DIR" -name "description.txt" -type f)
            if [ -n "$DESC_FILE" ]; then
                echo "----- Description for directory $dir -----"
                cat "$DESC_FILE"
                echo -e "\n"
            else
                echo "No description.txt found in $META_ZIP"
            fi
            
            # Clean up - remove the temporary extraction directory
            rm -rf "$TEMP_DIR"
        else
            echo "Meta zip file not found in directory $dir"
        fi
    fi
done