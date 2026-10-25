#!/bin/bash
echo "=== All ERROR lines ==="
grep "ERROR" app.log

echo ""
echo "=== Total ERROR count ==="
grep -c "ERROR" app.log

echo ""
echo "=== All WARN lines ==="
grep "WARN" app.log
