#!/bin/bash

# Basic arithmatic example

v1="2.3.4"
v2="2.03.4"
v3="1.99.4"

digit1=$(echo "$v1" | cut --delimiter=.  -f 1)

digit2=$(echo "$v1" | cut --delimiter=.  -f 2)

digit3=$(echo "$v1" | cut --delimiter=.  -f 3)

echo "$digit1"
echo "$digit2"
echo "$digit3"

majmin1=$(("$digit1" * 100 + "$digit2"))

echo $majmin1

d1=$(echo "$v2" | cut --delimiter=.  -f 1)
d2=$(echo "$v2" | cut --delimiter=.  -f 2)
majmin2=$(("$d1" * 100 + "$d2"))

d1=$(echo "$v3" | cut --delimiter=.  -f 1)
d2=$(echo "$v3" | cut --delimiter=.  -f 2)
majmin3=$(("$d1" * 100 + "$d2"))


if [[ $majmin1 -gt $majmin3 ]]; then
    echo "Math checks out"
fi

if [[ $majmin1 -eq $majmin2 ]]; then
    echo "Math checks out"
fi
