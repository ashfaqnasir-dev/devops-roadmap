#!/bin/bash
set -euo pipefail

echo "=== Script shuru ==="

if ! command -v git &> /dev/null; then
    echo "Error: git install nahi hai" >&2
    exit 1
fi
echo "git mojood hai"

if [ ! -f "config.txt" ]; then
    echo "Error: config.txt nahi mili" >&2
    exit 1
fi
echo "config.txt mili"

echo ""
echo "=== Script successfully complete ==="
exit 0
