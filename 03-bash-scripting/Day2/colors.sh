#!/bin/bash
COLORS=("Red" "Green" "Blue" "Yellow" "Purple")

echo "Total colors: ${#COLORS[@]}"
echo ""

for color in "${COLORS[@]}"; do
    echo "Color: $color"
done
