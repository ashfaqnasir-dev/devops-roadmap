#!/bin/bash
TOTAL=0

for file in *.sh; do
    if [ -f "$file" ]; then
        LINES=$(wc -l < "$file")
        echo "$file: $LINES lines"
        TOTAL=$((TOTAL + LINES))
    fi
done

echo ""
echo "Total lines in all scripts: $TOTAL"
