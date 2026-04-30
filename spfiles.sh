#!/bin/bash

# Get the folder path from the first argument
TARGET_DIR="./downloads"

# Check if a directory was provided
if [ -z "$TARGET_DIR" ]; then
    echo "Usage: $0 /path/to/folder"
    exit 1
fi

# Loop through all MP4 files in the target folder
for file in "$TARGET_DIR"/*.mp4; do
    # Skip if no MP4 files are found
    [ -e "$file" ] || continue

    size=$(stat -c%s "$file")
    limit=$((100 * 1024 * 1024))

    if [ "$size" -gt "$limit" ]; then
        echo "Splitting '$file'..."
        # ffmpeg splits and keeps parts in the same folder as the source
        ffmpeg -i "$file" -f segment -segment_chunk_size 50M -c copy "${file%.mp4}_part%03d.mp4"
        rm "$file" && echo "Successfully split and deleted: $(basename "$file")"
    else
        echo "Skipping '$(basename "$file")' (under 100MB)"
    fi
done
