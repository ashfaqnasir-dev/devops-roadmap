#!/bin/bash
COUNT=0

while IFS= read -r server; do
    COUNT=$((COUNT + 1))
    echo "$COUNT. $server"
done < servers.txt

echo ""
echo "Total servers: $COUNT"
