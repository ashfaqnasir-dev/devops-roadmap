#!/bin/bash
read -p "Enter your name: " NAME
read -p "Enter your age: " AGE

echo "Assalam-o-Alaikum $NAME, you are $AGE years old"

if [ $AGE -lt 18 ]; then
    echo "You are not an adult yet"
else
    echo "You are an adult"
fi
