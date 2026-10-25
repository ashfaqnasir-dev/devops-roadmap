#!/bin/bash
FRUITS=("Apple" "Banana" "Mango" "Orange")

echo "Total fruits: ${#FRUITS[@]}"
echo "First fruit: ${FRUITS[0]}"
echo "Second fruit: ${FRUITS[1]}"
echo ""
echo "All fruits:"

for fruit in "${FRUITS[@]}"; do
    echo "  - $fruit"
done
