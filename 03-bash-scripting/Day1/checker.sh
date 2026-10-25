#!/bin/bash
read -p "Enter file name: " FILENAME

if [ -f "$FILENAME" ]; then
    echo "File found: $FILENAME"
else
    echo "File not found: $FILENAME"
fi
