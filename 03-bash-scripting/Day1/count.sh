#!/bin/bash
echo "=== 1 se 10 tak ==="
for i in {1..10}; do
    echo "Number: $i"
done

echo ""
echo "=== Even numbers ==="
for i in {1..10}; do
    if [ $((i % 2)) -eq 0 ]; then
        echo "$i even hai"
    fi
done
