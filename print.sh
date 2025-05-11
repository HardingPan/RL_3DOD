#!/bin/bash

# Set the base directory
BASE_DIR="/media/sdb2/K-Radar/kradar"

# Loop through all directories in the base directory
for dir in "$BASE_DIR"/*/; do
    # Check if description.txt exists in this directory
    if [ -f "$dir/description.txt" ]; then
        # Print directory name as header
        echo "===== ${dir%/} ====="
        # Print the content of description.txt
        cat "$dir/description.txt"
        echo -e "\n"
    fi
done