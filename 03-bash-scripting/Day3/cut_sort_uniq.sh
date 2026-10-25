#!/bin/bash
echo "=== Only port lines using cut ==="
grep "port" config.txt | cut -d'=' -f1

echo ""
echo "=== Only values using cut ==="
grep "port" config.txt | cut -d'=' -f2

echo ""
echo "=== Sort config.txt ==="
sort config.txt

echo ""
echo "=== Unique log levels ==="
awk '{print $3}' app.log | sort | uniq

echo ""
echo "=== Count of each log level ==="
awk '{print $3}' app.log | sort | uniq -c
