#!/bin/bash
echo "=== Original config.txt ==="
cat config.txt

echo ""
echo "=== Replace port 8080 with 9090 ==="
sed 's/8080/9090/' config.txt

echo ""
echo "=== Delete all comment lines ==="
sed '/^#/d' config.txt

echo ""
echo "=== Only lines containing port ==="
sed -n '/port/p' config.txt
