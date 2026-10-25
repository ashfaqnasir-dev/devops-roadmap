#!/bin/bash
add() {
    echo $(( $1 + $2 ))
}
subtract() {
    echo $(( $1 - $2 ))
}
multiply() {
    echo $(( $1 * $2 ))
}

read -p "Pehla number: " NUM1
read -p "Doosra number: " NUM2

echo ""
echo "Sum: $(add $NUM1 $NUM2)"
echo "Difference: $(subtract $NUM1 $NUM2)"
echo "Product: $(multiply $NUM1 $NUM2)"
