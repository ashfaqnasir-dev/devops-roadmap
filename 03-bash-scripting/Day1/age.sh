#!/bin/bash
read -p "Apni age batayein: " AGE

if [ $AGE -ge 18 ]; then
    echo "Aap adult hain"
elif [ $AGE -ge 13 ]; then
    echo "Aap teenager hain"
else
    echo "Aap bachay hain"
fi
