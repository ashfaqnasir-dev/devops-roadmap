#!/bin/bash
echo "=== Only ERROR/WARN levels (3rd column) ==="
awk '{print $3}' app.log

echo ""
echo "=== Only timestamps (1st + 2nd column) ==="
awk '{print $1, $2}' app.log

echo ""
echo "=== Only ERROR lines with timestamp ==="
awk '$3 == "ERROR" {print $1, $2, $3}' app.log
