#!/bin/bash
echo "Reading servers from servers.txt:"
echo ""

while IFS= read -r server; do
    echo "  ??? Checking: $server"
done < servers.txt

echo ""
echo "Done!"
