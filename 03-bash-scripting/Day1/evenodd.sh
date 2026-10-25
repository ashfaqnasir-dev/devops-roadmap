#!/bin/bash
read -p "Enter a number: " NUM

if [ $((NUM % 2)) -eq 0 ]; then
    echo "$NUM is an even number"
else
    echo "$NUM is an odd number"
fi
