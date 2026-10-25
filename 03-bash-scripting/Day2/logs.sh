#!/bin/bash
echo "Files in current directory:"
echo ""

for file in *.sh; do
    if [ -f "$file" ]; then
        LINES=$(wc -l < "$file")
        echo "$file ??? $LINES lines"
    fi
done
